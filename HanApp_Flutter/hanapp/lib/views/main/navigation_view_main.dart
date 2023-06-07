import 'dart:async';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import '../../firebase_options.dart';
import 'pages/home_main.dart';
import 'pages/report_main.dart';
import 'pages/nearby_main.dart';
import 'pages/notification_main.dart';
import 'pages/update_main.dart';
import 'pages/report_pages/p1_classifier.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
// import 'package:google_maps_flutter/google_maps_flutter.dart';

int REPORT_RETRIEVAL_INTERVAL = 1;
int REPORT_RETRIEVAL_RADIUS = 3000;
bool firstRetrieve = true;

class NavigationField extends StatefulWidget {
  const NavigationField({super.key});

  @override
  State<NavigationField> createState() => _NavigationFieldState();
}

int selectedIndex = 0;

class _NavigationFieldState extends State<NavigationField> {
  final notificationRef = FirebaseDatabase.instance.ref('Notifications');
  final userUid = FirebaseAuth.instance.currentUser!.uid;
  void navigateToProfile() {
    setState(() {
      selectedIndex = 1;
    });
  }

  LocationData? currentLocation;
  LatLng? sourceLocation;
  late StreamSubscription<LocationData> _locationSubscription;
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');
  late dynamic _reports = {};
  late Map<dynamic, dynamic> nearbyVerifiedReports = {};
  int reportLen = 0;
  late StreamSubscription _reportsSubscription;
  dynamic hiddenReports = {};
  Map<dynamic, dynamic>? reportsClean;

  List<double> extractDoubles(String input) {
    RegExp regExp = RegExp(r"[-+]?\d*\.?\d+");
    List<double> doubles = [];
    Iterable<RegExpMatch> matches = regExp.allMatches(input);
    for (RegExpMatch match in matches) {
      doubles.add(double.parse(match.group(0)!));
    }
    return doubles;
  }

  retrieveHiddenReports() async {
    final snapshot = await notificationRef.child(userUid).once();
    hiddenReports = snapshot.snapshot.value ?? {};
    print('PRINT HIDDEN: ${hiddenReports.keys.toList()}');
  }

  bool serviceEnabled = false;
  continuallyCheckLocationService() async {
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // print('no sir no sir');
        continuallyCheckLocationService();
      } else {
        setState(() {});
        // print('yes sir yes sir');
        await _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    final reportsStream = dbRef2.onValue;
    final notificationsStream = notificationRef.onValue;
    await getCurrentLocation();
    StreamGroup.merge([reportsStream, notificationsStream])
        .listen((event) async {
      if (event.snapshot.ref.path == dbRef2.ref.path) {
        print('Snapshot came from dbRef2');
        setState(() {
          _reports = event.snapshot.value ?? {};
        });
        // print number of reports
        int reportCount = 0;
        int verifiedReportCount = 0;
        if (sourceLocation != null) {
          _reports.forEach((key, value) {
            reportCount += 1;
            var userUid = key;
            value.forEach((key2, value2) {
              List latlng;
              var reportKey = '${key2}_$userUid';
              var lastSeenLoc = value2['p5_lastSeenLoc'] ?? '';
              var reportValidity = value2['status'] ?? '';
              if (lastSeenLoc != '' && reportValidity == 'Verified') {
                latlng = extractDoubles(lastSeenLoc);
                LatLng reportLatLng = LatLng(latlng[0], latlng[1]);
                num distance = SphericalUtil.computeDistanceBetween(
                    sourceLocation!, reportLatLng);
                print('$reportKey distance from you: $distance');
                if (distance <= REPORT_RETRIEVAL_RADIUS) {
                  verifiedReportCount += 1;
                  nearbyVerifiedReports[reportKey] = value2;
                }
              }
            });
          });
          print(
              '[DATA FETCHED] Total reports: $reportCount, Nearby verified reports: $verifiedReportCount, radius: ${REPORT_RETRIEVAL_RADIUS}m');
        }
      } else if (event.snapshot.ref.path == notificationRef.ref.path) {
        print('Snapshot came from notificationRef');
        await retrieveHiddenReports();
        reportsClean =
            Map.from(nearbyVerifiedReports); // make a copy of reportsUnclean

        for (var key in hiddenReports.keys.toList()) {
          reportsClean!.remove(key);
        }
        if (reportsClean != null) {
          widgetOptions = <Widget>[
            HomeMain(
              onReportPressed: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              onNearbyPressed: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
            ),
            ReportMain(
              onReportSubmissionDone: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
            ),
            const NearbyMain(),
            NotificationMain(
              reports: reportsClean!,
              missingPersonTap: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
            ),
            const UpdateMain(),
          ];
        }
      } else {
        print('Nonee');
      }
    });
  }

  bool isLocationCoarse = false;
  getCurrentLocation() async {
    Location location = Location();
    perm.PermissionStatus permissionStatus =
        await perm.Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      var permissionType = await perm.Permission.location.serviceStatus;
      if (!(permissionType == ServiceStatus.disabled ||
          permissionType == ServiceStatus.enabled)) {
        setState(() {
          isLocationCoarse = true;
        });
      }
      await location.getLocation().then((locationData) {
        setState(() {
          currentLocation = locationData;
          sourceLocation =
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        });
      });

      Geolocator.getServiceStatusStream().listen((status) {
        if (status == ServiceStatus.enabled) {
          setState(() {});
          print('[LOC LOC LOC] HAS BEEN ENABLED!');
        }
      });
      if (currentLocation != null && mounted) {
        _locationSubscription =
            location.onLocationChanged.listen((newLocation) {
          setState(() {
            currentLocation = newLocation;
            sourceLocation =
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
          });
        });
      }
    } else {
      // Handle the case where the user denied or didn't grant location permission
      // You can show an error message or request the permission again based on your app's requirements.
      print('Location permission denied');
    }
  }

  void _onItemTapped(int index) {
    if (selectedIndex == 1 && index != 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            'Discard Report',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure? You will lose all the progress of your report',
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                          color: Palette.indigo,
                          border: Border.all(width: 0.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            selectedIndex = index;
                          });
                          // if user is on report page and wants to navigate away
                          // clear the prefs
                          clearPrefs();
                        },
                        child: const Text(
                          'Discard',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  } // end onItemTapped

  late final Future<FirebaseApp> _firebaseInit;
  @override
  void initState() {
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // getCurrentLocation();
    checkLocationPermission();
    // _fetchData();
    Location().getLocation();
    continuallyCheckLocationService();
    super.initState();
  }

  bool? locationPermission;
  checkLocationPermission() async {
    if (!(await perm.Permission.location.isDenied ||
        await perm.Permission.location.isRestricted ||
        await perm.Permission.location.isPermanentlyDenied)) {
      setState(() {
        locationPermission = true;
      });
    } else {
      setState(() {
        locationPermission = false;
      });
    }
    // print(locationPermission);
  }

  List<Widget>? widgetOptions;
  @override
  Widget build(BuildContext context) {
    // checkLocationPermission();
    // print('reportsClean length: ${reportsClean?.length}');
    // print('widgetOptions length: ${widgetOptions?.length}');
    return locationPermission == null
        ? const Scaffold(
            body: Center(
              child: SpinKitCubeGrid(color: Palette.indigo, size: 40),
            ),
          )
        : locationPermission!
            ? (reportsClean != null && widgetOptions != null)
                ? Scaffold(
                    body: FutureBuilder(
                      future: _firebaseInit,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          switch (snapshot.connectionState) {
                            // if there is no connection, return a text widget
                            case ConnectionState.none:
                              return const Center(child: Text('None oh no'));
                            // if there is a connection, return a text widget
                            case ConnectionState.waiting:
                              return Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    const SpinKitCubeGrid(
                                        color: Palette.indigo, size: 40),
                                    // const SizedBox(height: 50),
                                    // const Center(child: Text('Nearly there...')),
                                    // const SizedBox(height: 50),
                                    //Image.asset('assets/images/hanappLogo.png', width: 50)
                                  ],
                                ),
                              );
                            // if the connection is active, return a text widget
                            case ConnectionState.active:
                              return const Center(
                                  child: Text('App loading in...'));
                            // if the connection is done, return a text widget
                            case ConnectionState.done:
                              return Stack(
                                children: [
                                  Positioned(
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: selectedIndex == 2
                                            ? widgetOptions!
                                                .elementAt(selectedIndex)
                                            // else if maps, do not place in singlechildscroll view
                                            : selectedIndex == 1
                                                ? widgetOptions!
                                                    .elementAt(selectedIndex)
                                                : Center(
                                                    child: SingleChildScrollView(
                                                        child: widgetOptions!
                                                            .elementAt(
                                                                selectedIndex)))),
                                  ),
                                ],
                              );
                            // : const NearbyMain();
                          }
                        }
                      },
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.white,
                      items: <BottomNavigationBarItem>[
                        const BottomNavigationBarItem(
                            icon: Icon(Icons.home_outlined),
                            activeIcon: Icon(Icons.home_rounded),
                            label: 'Home'),
                        //backgroundColor: Colors.white),
                        const BottomNavigationBarItem(
                            icon: Icon(Icons.summarize_outlined),
                            activeIcon: Icon(Icons.summarize_rounded),
                            label: 'Report'),
                        const BottomNavigationBarItem(
                            icon: Icon(Icons.near_me_outlined),
                            activeIcon: Icon(Icons.near_me_rounded),
                            label: 'Nearby'),
                        (reportsClean != null)
                            ? (reportsClean!.isNotEmpty)
                                ? BottomNavigationBarItem(
                                    icon: Stack(
                                      children: [
                                        const Icon(
                                            Icons.notifications_outlined),
                                        Positioned(
                                          // draw a red marble
                                          top: 0.0,
                                          right: 0.0,
                                          // ignore: prefer_const_constructors, unnecessary_new
                                          child: new Icon(Icons.brightness_1,
                                              size: 9.0,
                                              color: Colors.redAccent),
                                        )
                                      ],
                                    ),
                                    activeIcon: Stack(
                                      children: [
                                        const Icon(Icons.notifications),
                                        Positioned(
                                          // draw a red marble
                                          top: 0.0,
                                          right: 0.0,
                                          // ignore: unnecessary_new, prefer_const_constructors
                                          child: new Icon(Icons.brightness_1,
                                              size: 9.0,
                                              color: Colors.redAccent),
                                        )
                                      ],
                                    ),
                                    label: 'Notifications')
                                : const BottomNavigationBarItem(
                                    icon: Icon(Icons.notifications_outlined),
                                    activeIcon: Icon(Icons.notifications),
                                    label: 'Notifications')
                            : const BottomNavigationBarItem(
                                icon: Icon(Icons.notifications_outlined),
                                activeIcon: Icon(Icons.notifications),
                                label: 'Notifications'),
                        const BottomNavigationBarItem(
                            icon: Icon(Icons.tips_and_updates_outlined),
                            activeIcon: Icon(Icons.tips_and_updates_rounded),
                            label: 'Updates'),
                      ],
                      currentIndex: selectedIndex,
                      selectedFontSize: 9,
                      selectedItemColor: Palette.indigo,
                      unselectedItemColor: Colors.black26,
                      showUnselectedLabels: false,
                      onTap: _onItemTapped,
                    ),
                  )
                //
                : Scaffold(
                    body: Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width * .75,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Setting things up...',
                                style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                textAlign: TextAlign.center,
                              ),
                              const Text(
                                '\nHanApp requires Location Access and Internet Connection in order to better facilitate Missing Persons reports',
                                textAlign: TextAlign.center,
                                textScaleFactor: 0.70,
                              ),
                              const Text(
                                '\nMake sure your location service is turned on',
                                textAlign: TextAlign.center,
                                textScaleFactor: 0.70,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const SpinKitCubeGrid(
                                color: Palette.indigo,
                                size: 25,
                              ),
                            ],
                          )),
                    ),
                    // bottomNavigationBar: BottomNavigationBar(
                    //   type: BottomNavigationBarType.fixed,
                    //   backgroundColor: Colors.white,
                    //   selectedItemColor: Colors.white10,
                    //   unselectedItemColor: Colors.white10,
                    //   showSelectedLabels: false,
                    //   showUnselectedLabels: false,
                    //   onTap: null,
                    //   items: const [
                    //     BottomNavigationBarItem(
                    //         icon: Icon(Icons.home_outlined), label: 'Home'),
                    //     BottomNavigationBarItem(
                    //         icon: Icon(Icons.summarize_outlined), label: 'Reports'),
                    //     BottomNavigationBarItem(
                    //         icon: Icon(Icons.near_me_outlined), label: 'Near Me'),
                    //     BottomNavigationBarItem(
                    //         icon: Icon(Icons.notifications_outlined),
                    //         label: 'Notifications'),
                    //     BottomNavigationBarItem(
                    //         icon: Icon(Icons.tips_and_updates_outlined),
                    //         label: 'Updates'),
                    //   ],
                    // ),
                  )
            : Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: StreamBuilder<perm.PermissionStatus>(
                      stream: perm.Permission.location.status.asStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          checkLocationPermission();
                        }
                        return Container(
                          width: MediaQuery.of(context).size.width * .75,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset("assets/lottie/noLocation.json",
                                    animate: true,
                                    width: MediaQuery.of(context).size.width *
                                        0.9),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                    'Location Permission is approximate, or is turned off',
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    textAlign: TextAlign.center),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  '\nHanApp requires your location to facilitate reports',
                                  textScaleFactor: 0.8,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text.rich(
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 0.8,
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              'Make sure that location permission is enabled and is '),
                                      TextSpan(
                                        text: 'set to Precise',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Palette.indigo),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),
                                TextButton(
                                  onPressed: () {
                                    perm.openAppSettings();
                                  },
                                  child: const Text(
                                    'Go to app settings',
                                    style: TextStyle(color: Palette.indigo),
                                  ),
                                ),
                                // !isLocationCoarse
                                //     ? TextButton(
                                //         onPressed: () {
                                //           setState(() {
                                //             locationPermission = true;
                                //           });
                                //         },
                                //         child: const Text(
                                //           'Proceed without location access',
                                //           style:
                                //               TextStyle(color: Palette.indigo),
                                //         ),
                                //       )
                                //     : const SizedBox()
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              );
  }
}
