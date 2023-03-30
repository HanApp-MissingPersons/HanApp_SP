import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';

class MapDialog extends StatefulWidget {
  const MapDialog({Key? key}) : super(key: key);

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  late GoogleMapController mapController;
  late LatLng _center = LatLng(999999999, 999999999);

  Set<Marker> _markers = {};
  Uint8List? _mapSnapshot;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getCurrentLocation() async {
    Location().getLocation();

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
    );
    setState(() {
      _markers = Set<Marker>.of([marker]);
    });
    print('marker location: ${marker.position}');
  }

  void _onMapTap(LatLng position) {
    if (_markers.isEmpty || _markers.first.position != position) {
      setState(() {
        _center = position;
        _addMarker(position);
      });
    }
  }

  void _onConfirmPressed(BuildContext context) async {
    try {
      await mapController.takeSnapshot().then((image) {
        setState(() {
          _mapSnapshot = image;
        });
      });
      // PRINT CHECK: convert _mapSnapshot as bytes
      String? _mapSnapshotString = _mapSnapshot?.toString();
      print('mapSnapshot: $_mapSnapshotString');
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
              height: 300,
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
              height: 300,
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
                        color: Color.fromARGB(255, 114, 166, 209),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SpinKitCubeGrid(
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _onConfirmPressed(context);
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
