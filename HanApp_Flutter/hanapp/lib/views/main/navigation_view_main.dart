import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';
import 'package:location/location.dart';
import '../../firebase_options.dart';
import 'pages/home_main.dart';
import 'pages/report_main.dart';
import 'pages/nearby_main.dart';
import 'pages/companion_main.dart';
import 'pages/update_main.dart';
import 'pages/report_pages/p1_classifier.dart';

class NavigationField extends StatefulWidget {
  const NavigationField({super.key});

  @override
  State<NavigationField> createState() => _NavigationFieldState();
}

class _NavigationFieldState extends State<NavigationField> {
  LocationData? currentLocation;
  LatLng? sourceLocation;
  late StreamSubscription<LocationData> _locationSubscription;
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');
  late dynamic _reports = {};
  int reportLen = 0;
  late StreamSubscription _reportsSubscription;

  Future<void> _fetchData() async {
    final snapshot = await dbRef2.once();
    setState(() {
      _reports = snapshot.snapshot.value ?? {};
    });
    print(
        '[DATA FETCHED] reports: ${_reports.length}'); // print number of reports
    _reportsSubscription = dbRef2.onValue.listen((event) {
      setState(() {
        _reports = event.snapshot.value ?? {};
      });
      print('[DATA UPDATED] reports: ${_reports.length}');
      reportLen = _reports.length; // print number of reports
    });
  }

  void getCurrentLocation() async {
    Location location = Location();

    await location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    });
    if (currentLocation != null) {
      _locationSubscription = location.onLocationChanged.listen((newLocation) {
        setState(() {
          currentLocation = newLocation;
          sourceLocation =
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        });
      });
    }
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    if (_selectedIndex == 1 && index != 1) {
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
                            _selectedIndex = index;
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
        _selectedIndex = index;
      });
    }
  } // end onItemTapped

  late final Future<FirebaseApp> _firebaseInit;
  @override
  void initState() {
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    getCurrentLocation();
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomeMain(),
      ReportMain(),
      NearbyMain(),
      CompanionMain(
        reportLen: reportLen.toString(),
      ),
      UpdateMain(),
    ];
    return Scaffold(
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
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      //const Text('Loading . . .'),
                      const Center(
                        child: SpinKitCubeGrid(
                          color: Palette.indigo,
                          size: 50.0,
                        ),
                      ),
                    ],
                  ),
                );
              // if the connection is active, return a text widget
              case ConnectionState.active:
                return const Center(child: Text('App loading in...'));
              // if the connection is done, return a text widget
              case ConnectionState.done:
                return Stack(
                  children: [
                    Positioned(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: _selectedIndex != 2
                              ? Center(
                                  child: SingleChildScrollView(
                                      child: _widgetOptions
                                          .elementAt(_selectedIndex)))
                              // else if maps, do not place in singlechildscroll view
                              : _widgetOptions.elementAt(_selectedIndex)),
                    ),
                    Positioned(
                      // position the user profile button
                      top: MediaQuery.of(context).size.height * .090,
                      right: MediaQuery.of(context).size.width * .080,
                      child: FloatingActionButton(
                        onPressed: () {
                          // sign out the user
                          // FirebaseAuth.instance.signOut();
                          // navigate to the login page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileMain(),
                            ),
                          );
                        },
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    // _widgetOptions.elementAt(_selectedIndex)
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
          reportLen != 0
              ? const BottomNavigationBarItem(
                  icon: Icon(Icons.notification_important_outlined),
                  activeIcon: Icon(Icons.notification_important),
                  label: 'Notifications')
              : const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_paused_outlined),
                  activeIcon: Icon(Icons.notifications_paused),
                  label: 'Notifications'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_outlined),
              activeIcon: Icon(Icons.tips_and_updates_rounded),
              label: 'Updates'),
        ],
        currentIndex: _selectedIndex,
        selectedFontSize: 9,
        selectedItemColor: Palette.indigo,
        unselectedItemColor: Colors.black26,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}
