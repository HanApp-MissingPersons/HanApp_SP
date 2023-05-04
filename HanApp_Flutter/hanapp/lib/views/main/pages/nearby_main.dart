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
  LatLng? sourceLocation;
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
            const ImageConfiguration(size: Size(6, 6)),   //decrease if too large
            'assets/images/mp_marker.png')
        .then((icon) => sourceIcon = icon);
    // BitmapDescriptor.fromAssetImage(
    //         const ImageConfiguration(size: Size(20, 20)),
    //         'assets/images/login.png')
    //     .then((icon) => destinationIcon = icon);
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(10, 10)),
            'assets/images/position_marker.png')
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
      body: (_reports.isEmpty || _reports == null || currentLocation == null)
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
              onMapCreated: (controller) => {_controller.complete(controller),
              controller.setMapStyle(Utils.mapStyle)},
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
    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          icon: currentLocationIcon,
          infoWindow: const InfoWindow(
            title: 'You',
          ),
        ),
      );
    }
    _reports.forEach((key, value) {
      dynamic uid = key;
      value.forEach((key, value) {
        final report = value as Map<dynamic, dynamic>;
        if (report['status'] == 'Verified') {
          final firstName = report['p3_mp_firstName'] ?? '';
          final lastName = report['p3_mp_lastName'] ?? '';
          final reportID = '${uid}_$key';
          final location = report['p5_lastSeenLoc'] ?? '';

          // Snippet
          final heightFeet = report['p4_mp_height_inches'] ?? '';
          final heightInches = report['p4_mp_height_feet'] ?? '';
          final sex = report['p3_mp_sex'] ?? '';
          final clothing = report['p4_mp_last_clothing'] ?? '';
          final description = report['p5_incidentDetails'] ?? '';

          final coordinates = extractDoubles(location.toString());
          final reportLocation = LatLng(coordinates[0], coordinates[1]);
          final marker = Marker(
            markerId: MarkerId(reportID),
            position: reportLocation,
            icon: sourceIcon,
            infoWindow: InfoWindow(
              title: '$firstName $lastName',
              snippet:
              "Sex: $sex \n Height: $heightFeet'$heightInches \n Clothing: $clothing",
              onTap: () {
                print('tapping on marker $reportID');
              },
            ),
          );
          markers.add(marker);
        }
      });
    });
    return markers;
  }
}

class Utils {
  static String mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.attraction",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "color": "#79919d"
      },
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.government",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.government",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi.medical",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi.school",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
  ''';
}
