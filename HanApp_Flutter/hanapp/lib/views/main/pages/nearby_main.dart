import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NearbyMain extends StatefulWidget {
  const NearbyMain({super.key});

  @override
  State<NearbyMain> createState() => _NearbyMain();
}

class _NearbyMain extends State<NearbyMain> {
  late GoogleMapController mapController;

  late LatLng currentPostion;

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition();

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation();
  }

  final List<Marker> _markers = <Marker>[
    const Marker(
      markerId: MarkerId('1'), // initial position
      // position: LatLng(10.645429951059262, 122.24244498334156),
      // infoWindow: InfoWindow(title: 'ISAT-U Miagao')
    )
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getUserLocation();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          markers: Set<Marker>.of(_markers),
          onMapCreated: _onMapCreated,
          // ignore: prefer_const_constructors
          initialCameraPosition:
              // original code (uncomment this, and comment out the cameraPosition below)
              // CameraPosition(target: currentPostion, zoom: 14.5),
              CameraPosition(
                  // setting up initial position (ISAT-U Miagao), to prevent error while waiting to fetch current location
                  target: LatLng(10.645429951059262, 122.24244498334156),
                  zoom: 14.5),
        ),
        floatingActionButton: FloatingActionButton(
          // put botton on upper right corner
          child: const Icon(Icons.add_location),
          // position the button on the upper right corner:
          onPressed: () {
            _getCurrentLocation().then((value) async {
              _markers.add(Marker(
                markerId: const MarkerId('2'),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: const InfoWindow(title: 'My current location'),
              ));
              CameraPosition cameraPosition = CameraPosition(
                target:
                    LatLng(currentPostion.latitude, currentPostion.longitude),
                zoom: 16,
              );
              final GoogleMapController controller = await mapController;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          },
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }
}
