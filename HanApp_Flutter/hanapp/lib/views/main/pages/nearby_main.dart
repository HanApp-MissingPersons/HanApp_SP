import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanapp/main.dart';
import 'package:location/location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';

class NearbyMain extends StatefulWidget {
  const NearbyMain({super.key});

  @override
  State<NearbyMain> createState() => _NearbyMainState();
}

class _NearbyMainState extends State<NearbyMain> {
  final Completer<GoogleMapController> _controller = Completer();
  late StreamSubscription<LocationData> _locationSubscription;
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');

  LatLng sourceLocation = const LatLng(37.33500926, -122.03272188);
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  List<double> extractDoubles(String input) {
    RegExp regExp = RegExp(r"[-+]?\d*\.?\d+");
    List<double> doubles = [];
    Iterable<RegExpMatch> matches = regExp.allMatches(input);
    for (RegExpMatch match in matches) {
      doubles.add(double.parse(match.group(0)!));
    }
    return doubles;
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    });
    _locationSubscription = location.onLocationChanged.listen((newLocation) {
      setState(() {
        currentLocation = newLocation;
        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    });
  }

  void recenterToUser() async {
    GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 20,
        ),
      ),
    );
  }

  void setCustomMarkerIcon() {
    // temporary images, just to show that it is possible
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(20, 20)),
            'assets/images/register.png')
        .then((icon) => sourceIcon = icon);
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(20, 20)),
            'assets/images/login.png')
        .then((icon) => destinationIcon = icon);
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(20, 20)),
            'assets/images/verify-email_2.png')
        .then((icon) => currentLocationIcon = icon);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMarkerIcon();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Center(child: Text('Google maps is loading...')),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      'Loading times may vary depending on your '
                      'internet connection. . .',
                      textAlign: TextAlign.center,
                      textScaleFactor: 0.67,
                    ),
                  ),
                ),
                Center(
                  child: SpinKitCubeGrid(
                    color: Palette.indigo,
                    size: 25.0,
                  ),
                )
              ],
            )
          : FutureBuilder(
              future: dbRef.once(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  dynamic values = snapshot.data?.snapshot.value;
                  // print(values);
                  if (values != null) {
                    Map<dynamic, dynamic> reports = values;
                    List<dynamic> latLngList = [];
                    reports.forEach((key, value) {
                      value.forEach((key, value) {
                        var reportLatLng = value['p5_lastSeenLoc'];
                        List<double> lastSeenLocList =
                            extractDoubles(reportLatLng);
                        double lastSeenLocLat = lastSeenLocList[0];
                        double lastSeenLocLong = lastSeenLocList[1];
                        LatLng lastSeenLocLatLng =
                            LatLng(lastSeenLocLat, lastSeenLocLong);
                        print(lastSeenLocLatLng);
                        latLngList.add(lastSeenLocLatLng);
                        // print(value[])
                      });
                    });
                    return GoogleMap(
                      onMapCreated: (mapController) =>
                          _controller.complete(mapController),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        zoom: 20,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('currentLocation'),
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          // icon: currentLocationIcon,
                        )
                      },
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Center(child: Text('Google maps is loading...')),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              'Getting Reports . . . ',
                              textAlign: TextAlign.center,
                              textScaleFactor: 0.67,
                            ),
                          ),
                        ),
                        Center(
                          child: SpinKitCubeGrid(
                            color: Palette.indigo,
                            size: 25.0,
                          ),
                        )
                      ],
                    );
                  }
                }
              }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'nearbyMain',
        onPressed: () {
          recenterToUser();
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
