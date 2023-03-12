import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class NearbyMain extends StatefulWidget {
  const NearbyMain({super.key});

  @override
  State<NearbyMain> createState() => _NearbyMainState();
}

class _NearbyMainState extends State<NearbyMain> {
  LatLng sourceLocation = const LatLng(37.33500926, -122.03272188);
  LocationData? currentLocation;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
        sourceLocation =
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
      ),
      body: currentLocation == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Center(child: Text('Loading...')),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 14.4746,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('sourcePin'),
                  position: sourceLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                )
              },
            ),
    );
  }
}
