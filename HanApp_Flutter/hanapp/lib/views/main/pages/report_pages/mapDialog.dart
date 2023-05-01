import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hanapp/main.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapDialog extends StatefulWidget {
  const MapDialog({Key? key}) : super(key: key);

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  late GoogleMapController mapController;
  late LatLng _center = LatLng(999999999, 999999999);
  bool isMarkerPresent = false;

  Set<Marker> _markers = {};
  Uint8List? _mapSnapshot;

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(4, 4)),
        'assets/images/currect_marker.png')
        .then((icon) => currentLocationIcon = icon);
  }

  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getCurrentLocation() async {
    await Location().getLocation();

    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
  }

  void _addMarker(LatLng position) {
    Marker marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      icon: currentLocationIcon,
    );
    setState(() {
      _markers = Set<Marker>.of([marker]);
    });
    print('marker location: ${marker.position}');
    isMarkerPresent = true;
  }

  void _onMapTap(LatLng position) async {
    if (_markers.isEmpty || _markers.first.position != position) {
      setState(() {
        _center = position;
        _addMarker(position);
      });
    }
    await mapController.animateCamera(CameraUpdate.newLatLng(_center));
  }

  void _onConfirmPressed(BuildContext context) async {
    try {
      // await mapController.moveCamera(_center as CameraUpdate);
      await mapController.moveCamera(CameraUpdate.newLatLng(_center));
      await mapController.takeSnapshot().then((image) {
        setState(() {
          _mapSnapshot = image;
        });
      });
      // PRINT CHECK: convert _mapSnapshot as bytes
      String? _mapSnapshotString = _mapSnapshot?.toString();
      print('mapSnapshot: $_mapSnapshotString');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('p5_locSnapshot', base64Encode(_mapSnapshot!));
    } catch (e) {
      print('[takeSnapshot error] $e');
    }

    Navigator.of(context).pop({
      'location': _center,
      'image': _mapSnapshot,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location'),
      content: _center != const LatLng(999999999, 999999999)
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    onTap: _onMapTap,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 14,
                    ),
                    markers: _markers,
                  ),
                  if (_mapSnapshot != null)
                    Positioned.fill(
                      child: Image.memory(_mapSnapshot!, fit: BoxFit.cover),
                    ),
                ],
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    const Text(
                      'Getting current location...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SpinKitCubeGrid(
                      color: Palette.indigo,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            onPressed: isMarkerPresent ? () => _onConfirmPressed(context) : null,
            // {
            //   if (isMarkerPresent) {
            //     _onConfirmPressed(context);
            //   } else {
            //     null;
            //   }
            // },
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.indigo,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }
}

// Container(
// height: 35,
// decoration: BoxDecoration(
// color: Palette.indigo,
// border: Border.all(width: 0.5),
// borderRadius: const BorderRadius.all(Radius.circular(5))
// ),
// child: ElevatedButton(
// onPressed: () {
// Navigator.of(context).pop();
// setState(() {
// _selectedIndex = index;
// });
// // if user is on report page and wants to navigate away
// // clear the prefs
// clearPrefs();
// },
// child: const Text('Discard', style: TextStyle(color: Colors.white),),