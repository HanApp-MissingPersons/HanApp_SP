import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hanapp/main.dart';
import 'package:location/location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NearbyMain extends StatefulWidget {
  const NearbyMain({super.key});

  @override
  State<NearbyMain> createState() => _NearbyMainState();
}

class _NearbyMainState extends State<NearbyMain> {
  final Completer<GoogleMapController> _controller = Completer();
  late StreamSubscription<LocationData> _locationSubscription;

  LatLng sourceLocation = const LatLng(37.33500926, -122.03272188);
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    });

    GoogleMapController mapController = await _controller.future;
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
                      'internet connection',
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
              onMapCreated: (mapController) =>
                  _controller.complete(mapController),
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 20,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  // icon: currentLocationIcon,
                )
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          recenterToUser();
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
