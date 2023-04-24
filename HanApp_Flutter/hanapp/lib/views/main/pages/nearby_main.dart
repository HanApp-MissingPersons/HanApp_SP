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
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');
  late dynamic _reports = {};
  int timesWidgetBuilt = 0;
  LatLng sourceLocation = const LatLng(37.33500926, -122.03272188);
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor greenPin =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  BitmapDescriptor yellowPin =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);

  Future<void> _fetchData() async {
    final snapshot = await dbRef2.once();
    setState(() {
      _reports = snapshot.snapshot.value ?? {};
    });
    print(
        '[DATA FETCHED] [DATA FETCHED] [DATA FETCHED] [DATA FETCHED] [DATA FETCHED]');
  }

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
    _fetchData();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_reports.isEmpty || _reports == null)
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
          : GoogleMap(
              markers: _buildMarkers(),
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 20,
              ),
              onMapCreated: (controller) => _controller.complete(controller),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'nearbyMain',
        onPressed: () {
          recenterToUser();
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    markers.add(
      Marker(
        markerId: MarkerId('currentLocation'),
        position:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        icon: greenPin,
      ),
    );
    _reports.forEach((key, value) {
      dynamic uid = key;
      value.forEach((key, value) {
        final reportLatLng = value['p5_lastSeenLoc'];
        final reportVerification = value['status'];
        value['keyUid'] = '${key}__$uid';
        final lastSeenLocList = extractDoubles(reportLatLng);
        final lastSeenLocLat = lastSeenLocList[0];
        final lastSeenLocLong = lastSeenLocList[1];
        final lastSeenLocLatLng = LatLng(lastSeenLocLat, lastSeenLocLong);
        if (reportVerification == 'Verified') {
          markers.add(
            Marker(
              markerId: MarkerId(value['keyUid']),
              position: lastSeenLocLatLng,
              icon: yellowPin,
            ),
          );
          // print('[marker added] Marker position: $lastSeenLocLatLng');
        } else {
          // print(
          // '[marker not added] ${value['keyUid']} status: ${value['status']}');
        }
      });
    });
    timesWidgetBuilt += 1;
    print(
        '[widget built times] $timesWidgetBuilt'); // count the times the widget rebuilds (does not consume download quota)
    return markers;
  }
}
