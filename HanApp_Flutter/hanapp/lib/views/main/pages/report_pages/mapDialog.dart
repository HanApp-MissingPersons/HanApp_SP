import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hanapp/main.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MapDialog extends StatefulWidget {
  final String uid;
  final String reportCount;
  const MapDialog({Key? key, required this.uid, required this.reportCount})
      : super(key: key);

  @override
  _MapDialogState createState() => _MapDialogState();
}

class _MapDialogState extends State<MapDialog> {
  late GoogleMapController mapController;
  late LatLng _center = LatLng(999999999, 999999999);
  bool isMarkerPresent = false;
  bool isBtnDisabled = false;
  bool _showProgressIndicator = false;

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

  void _onConfirmPressed(
      BuildContext context, String uid, String reportCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    XFile? imageFile;
    try {
      // await mapController.moveCamera(_center as CameraUpdate);
      setState(() {
        isBtnDisabled = true;
        _showProgressIndicator = true;
      });
      await mapController.moveCamera(CameraUpdate.newLatLng(_center));
      await mapController.takeSnapshot().then((image) {
        setState(() {
          _mapSnapshot = image;
          imageFile = XFile.fromData(image!);
        });
      });
      if (imageFile != null) {
        try {
          final bytes = await imageFile?.readAsBytes();
          final file =
              File('${(await getTemporaryDirectory()).path}/image.png');
          await file.writeAsBytes(bytes!);
          await FirebaseStorage.instance
              .ref()
              .child('Reports')
              .child(uid)
              .child('report_$reportCount')
              .child('locSnapshot')
              .putFile(file)
              .whenComplete(() async {
            await FirebaseStorage.instance
                .ref()
                .child('Reports')
                .child(uid)
                .child('report_$reportCount')
                .child('locSnapshot')
                .getDownloadURL()
                .then((value) {
              print('GOT VALUE: $value');
              setState(() {
                prefs.setString('p5_locSnapshot_LINK', value);
              });
            });
          });
          print('[LOC SNAPSHOT] snapshot uploaded');
        } catch (e) {
          print('[ERROR] $e');
        }
      }
      // PRINT CHECK: convert _mapSnapshot as bytes
      String? _mapSnapshotString = _mapSnapshot?.toString();
      prefs.setString('p5_locSnapshot', base64Encode(_mapSnapshot!));
    } catch (e) {
      print('[takeSnapshot error] $e');
    }

    Navigator.of(context).pop({
      'location': _center,
      'image': _mapSnapshot,
    });
  }
  // _onconfirmpressed end

  @override
  Widget build(BuildContext context) {
    String uid = widget.uid;
    String reportCount = widget.reportCount;
    return AlertDialog(
      title: const Text('Select Location'),
      content: _center != const LatLng(999999999, 999999999)
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Stack(
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
                  if (_showProgressIndicator)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SpinKitFadingCircle(
                            color: Palette.indigo,
                            size: 60,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withOpacity(0.8),
                              // backgroundBlendMode: BlendMode.darken,
                            ),
                            child: const Text(
                              'Uploading selected location...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
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
          onPressed: !isBtnDisabled ? () => Navigator.of(context).pop() : null,
          child: const Text('Cancel'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            onPressed: isMarkerPresent && !isBtnDisabled
                ? () => _onConfirmPressed(context, uid, reportCount)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.indigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
