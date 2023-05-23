import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanapp/main.dart';
import 'package:location/location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

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
          zoom: 14.25,
        ),
      ),
    );
  }

  void setCustomMarkerIcon() {
    // temporary images, just to show that it is possible
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(6, 6)), //decrease if too large
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
    _buildMarkers();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    _controller.future.then((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _sendEmail(var pnp_contactEmail) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: pnp_contactEmail,
      queryParameters: {'subject': 'Report\tInformation\tUpdate'},
    );
    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_reports.isEmpty || _reports == null || currentLocation == null)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Text('Google maps is loading...',
                        style: GoogleFonts.inter(
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w500)))),
                const Center(
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
                const Center(
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
                zoom: 14.25,
              ),
              onMapCreated: (controller) => {
                _controller.complete(controller),
                controller.setMapStyle(Utils.mapStyle)
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'nearbyMain',
        backgroundColor: Palette.indigo,
        elevation: 30,
        onPressed: () {
          recenterToUser();
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
      try {
        value.forEach((key, value) {
          final report = value as Map<dynamic, dynamic>;
          if (report['status'] == 'Verified') {
            try {
              final firstName = report['p3_mp_firstName'] ?? '';
              final lastName = report['p3_mp_lastName'] ?? '';
              final reportID = '${uid}_$key';
              final location = report['p5_lastSeenLoc'] ?? '';
              print('[TEST REPORT] $reportID NAME HERE CLEAR');
              // Snippet

              final description = report['p5_incidentDetails'] ?? '';
              print('[TEST REPORT] $reportID SNIPPET HERE CLEAR');
              print('[TEST REPORT] $reportID LOCATION: $location');
              final coordinates = extractDoubles(location.toString());
              final reportLocation = LatLng(coordinates[0], coordinates[1]);
              print('[TEST REPORT] $reportID LOCATION HERE CLEAR');

              final dateReported = report['p5_reportDate'] ?? '';
              final lastSeenLoc = report['p5_nearestLandmark'] ?? '';

              final pnp_contactNumber = report['pnp_contactNumber'] ?? '';
              final pnp_contactEmail = report['pnp_contactEmail'] ?? '';

              // Info window
              final mp_recentPhoto_LINK = report['mp_recentPhoto_LINK'];
              final heightFeet = report['p4_mp_height_inches'] ?? '';
              final heightInches = report['p4_mp_height_feet'] ?? '';
              final sex = report['p3_mp_sex'] ?? '';
              final age = report['p3_mp_age'] ?? '';
              final weight = report['p4_mp_weight'] ?? '';
              final scars = report['p4_mp_scars'] ?? '';
              final marks = report['p4_mp_marks'] ?? '';
              final tattoos = report['p4_mp_tattoos'] ?? '';
              final hairColor = report['p4_mp_hair_color'] ?? '';
              final eyeColor = report['p4_mp_eye_color'] ?? '';
              final prosthetics = report['p4_mp_prosthetics'] ?? '';
              final birthDefects = report['p4_mp_birth_defects'] ?? '';
              final clothingAccessories = report['p4_mp_last_clothing'] ?? '';
              final lastSeenDate = report['p5_lastSeenDate'] ?? '';
              final lastSeenTime = report['p5_lastSeenTime'] ?? '';

              bool minor = report['p1_isMinor'] ?? false;
              bool crime = report['p1_isVictimCrime'] ?? false;
              bool calamity = report['p1_isVictimNaturalCalamity'] ?? false;
              bool over24Hours = report['p1_isMissing24Hours'] ?? false;

              final marker = Marker(
                markerId: MarkerId(reportID),
                position: reportLocation,
                icon: sourceIcon,
                infoWindow: InfoWindow(
                  title: '$firstName $lastName',
                  snippet: 'Last Seen: $lastSeenDate, $lastSeenTime',
                ),
                onTap: () {
                  print('tapping on marker $reportID');
                  showModalBottomSheet(
                    context: context,
                    barrierColor: Colors.black12,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 1,
                        minChildSize: 0.98,
                        maxChildSize: 1,
                        snap: true,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.8,
                                                  ),
                                                  child: GestureDetector(
                                                    onScaleStart:
                                                        (ScaleStartDetails
                                                            details) {
                                                      // Handle scale start event if needed
                                                    },
                                                    onScaleUpdate:
                                                        (ScaleUpdateDetails
                                                            details) {
                                                      // Handle scale update event
                                                      // You can update the scale factor or do other transformations here
                                                    },
                                                    child: InteractiveViewer(
                                                      boundaryMargin:
                                                          EdgeInsets.all(0),
                                                      minScale: 0.5,
                                                      maxScale: 5.0,
                                                      child: Image.network(
                                                          mp_recentPhoto_LINK),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              alignment: Alignment.center,
                                              color: Colors.white,
                                              child: Image.network(
                                                  mp_recentPhoto_LINK,
                                                  fit: BoxFit.fill),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.search_outlined,
                                                  size: 15,
                                                  color: Palette.indigo),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$firstName $lastName',
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            'Date Reported: $dateReported',
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            child: Visibility(
                                              visible:
                                                  minor || crime || calamity,
                                              child: Wrap(
                                                children: [
                                                  Visibility(
                                                    visible: crime,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5, top: 5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors
                                                              .deepPurple),
                                                      //Retrieve the status here
                                                      child: const Text(
                                                        'Victim of Crime',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: calamity,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5, top: 5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors
                                                              .orangeAccent),
                                                      //Retrieve the status here
                                                      child: const Text(
                                                        'Victim of Calamity',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: over24Hours,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5, top: 5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.green),
                                                      child: const Text(
                                                        'Over 24 Hours',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: minor,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5, top: 5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color:
                                                              Colors.redAccent),
                                                      //Retrieve the status here
                                                      child: const Text(
                                                        'Minor',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.black12,
                                    height: 25,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("LAST SEEN DATE",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              lastSeenDate,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("LAST SEEN TIME",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              lastSeenTime,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("LAST TRACKED LOCATION",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 10,
                                              letterSpacing: 2,
                                              color: Colors.black54)),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.only(
                                            top: 5, bottom: 15),
                                        padding: const EdgeInsets.all(15),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 0.5),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15))),
                                        child: Text(
                                          lastSeenLoc,
                                          textAlign: TextAlign.center,
                                          style:
                                              const TextStyle(fontSize: 12.0),
                                        ),
                                      ),
                                      // const Text(
                                      //   'If you have any information about this person, please contact the nearest police station',
                                      //   style: const TextStyle(fontSize: 12.0),
                                      // ),
                                      // SelectableText(
                                      //   'call $pnp_contactNumber',
                                      //   style: const TextStyle(fontSize: 12.0),
                                      // ),
                                      // SelectableText(
                                      //   'or email $pnp_contactEmail',
                                      //   style: const TextStyle(fontSize: 12.0),
                                      // ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 10, left: 20),
                                            child: Icon(
                                              Icons.crisis_alert_outlined,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 230,
                                            child: Text(
                                                'If you locate a person or have information about this person. Call or email the police to notify immediately',
                                                textScaleFactor: 0.60,
                                                style: TextStyle(
                                                    color: Colors.black54)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                            onPressed: () async {
                                              final url = Uri.parse(
                                                  'tel:$pnp_contactNumber');
                                              if (Platform.isAndroid) {
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              }

                                              Clipboard.setData(ClipboardData(
                                                  text: pnp_contactNumber));
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'PNP number copied to clipboard'),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              child: Text('Call Police'),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )),
                                            onPressed: () async {
                                              if (Platform.isAndroid) {
                                                _sendEmail(pnp_contactEmail);
                                              }
                                            },
                                            child: Container(
                                              child: Text('Email Police'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ExpansionTile(
                                    title: Text('Physical Descriptions'),
                                    expandedAlignment: Alignment.centerLeft,
                                    //subtitle: Text('Missing person'),
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("HEIGHT",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 10,
                                                      letterSpacing: 2,
                                                      color: Colors.black54)),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 15),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.32,
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15))),
                                                child: Text(
                                                  "$heightFeet'$heightInches",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("WEIGHT",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 10,
                                                      letterSpacing: 2,
                                                      color: Colors.black54)),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 15),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.32,
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15))),
                                                child: Text(
                                                  '$weight kg',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("SEX",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 10,
                                                      letterSpacing: 2,
                                                      color: Colors.black54)),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 15),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.32,
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15))),
                                                child: Text(
                                                  sex,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("AGE",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 10,
                                                      letterSpacing: 2,
                                                      color: Colors.black54)),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 15),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.32,
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15))),
                                                child: Text(
                                                  age,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("SCARS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              scars,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("MARKS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              marks,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("TATTOOS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              tattoos,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("HAIR COLOR",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              hairColor,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("EYE COLOR",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              eyeColor,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("BIRTH DEFECTS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              birthDefects,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("PROSTHETICS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              prosthetics,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("CLOTHING AND ACCESSORIES",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                  letterSpacing: 2,
                                                  color: Colors.black54)),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 15),
                                            padding: const EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15))),
                                            child: Text(
                                              clothingAccessories,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 5),
                                    child: Text("Incident Details",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        )),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(
                                        top: 5, bottom: 15),
                                    padding: const EdgeInsets.all(18),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 0.5),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: Text(
                                      description,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
              markers.add(marker);
            } catch (e) {
              print('[NEARBY LOOP ERROR] $e');
            }
          }
        });
      } catch (e) {
        print('[NEARBY ERROR] $e');
      }
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
