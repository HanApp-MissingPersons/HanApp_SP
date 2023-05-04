import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class NotificationMain extends StatefulWidget {
  final String reportLen;
  const NotificationMain({super.key, required this.reportLen});

  @override
  State<NotificationMain> createState() => _NotificationMain();
}

class _NotificationMain extends State<NotificationMain> {
  LocationData? currentLocation;
  LatLng? sourceLocation;
  late StreamSubscription<LocationData> _locationSubscription;
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');
  late dynamic _reports = {};
  late StreamSubscription _reportsSubscription;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription.cancel();
    _reportsSubscription.cancel();
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
      print(
          '[DATA UPDATED] reports: ${_reports.length}'); // print number of reports
    });
  }

  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return currentLocation != null
        ? Text(
            'Index 3: Report Len ${widget.reportLen}',
            style: optionStyle,
          )
        : SpinKitCubeGrid(
            color: Colors.indigo,
            size: 50.0,
          );
  }
}
