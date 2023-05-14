import 'dart:convert';
//import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:pnphanapp/main.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';

class reportsPNP extends StatefulWidget {
  final List<String> filterValue;
  const reportsPNP({Key? key, required this.filterValue}) : super(key: key);

  @override
  State<reportsPNP> createState() => _reportsPNPState();
}

class _reportsPNPState extends State<reportsPNP> {
  String cors_anywhere = 'https://cors-anywhere.herokuapp.com/';
  final user = FirebaseAuth.instance.currentUser;
  DatabaseReference pnpAccountsRef =
      FirebaseDatabase.instance.ref('PNP Accounts');
  DatabaseReference databaseReportsReference =
      FirebaseDatabase.instance.ref('Reports');
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');
  List<Map>? reportList = [];

  // REPORT DETAILS
  String firstName = '';
  String lastName = '';
  String middleName = '';
  String nickname = '';

  // MISSING PERSON DETAILS
  String heightFeet = '';
  String heightInches = '';
  String weight = '';
  String sex = '';
  String civilStatus = '';
  String age = '';
  String citizenship = '';
  String birthDate = '';
  String streetHouseNum = '';
  String villageSitio = '';
  String barangay = '';
  String city = '';
  String province = '';
  String region = '';

  // CONTACT INFORMATION
  String homePhone = '';
  String mobilePhone = '';
  String pinnedLocCityMun = '';
  String pinnedLocBarangay = '';
  String incidentDetails = '';

  // DESCRIPTIONS
  String scars = '';
  String marks = '';
  String tattoos = '';
  String hairColor = '';
  String eyeColor = '';
  String prosthetics = '';
  String birthDefects = '';
  String clothingAccessories = '';

  // imgs
  String mp_locationSnapshot_LINK = '';
  String mp_recentPhoto_LINK = '';
  String reportee_ID_Photo_LINK = '';
  String reportee_Signature_LINK = '';

  var userLat;
  var userLong;
  late LatLng userLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    print(user!.uid);
    _activateListeners();
  }

  void _activateListeners() {
    pnpAccountsRef.onValue.listen((event) {
      var pnpProfiles = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      pnpProfiles.forEach((key, value) {
        // print(value);
        if (value['uid'] == user!.uid) {
          setState(() {
            userLat = value['lat'] ?? '';
            userLong = value['long'] ?? '';
            if (userLat != '' && userLong != '') {
              userLatLng = LatLng(double.parse(userLat.toString()),
                  double.parse(userLong.toString()));
            } else {
              userLatLng = LatLng(999999, 999999);
            }
          });
        }
      });
    });
  }

  num calculateDistance(LatLng first, LatLng second) {
    return SphericalUtil.computeDistanceBetween(first, second);
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

  Widget listItem({required Map report}) {
    String importanceString = '';
    String lastSeenLoc = report['p5_lastSeenLoc'] ?? '';
    String lastSeenDate = report['p5_lastSeenDate'] ?? '';
    String lastSeenTime = report['p5_lastSeenTime'] ?? '';
    String dateReported = report['p5_reportDate'] ?? '';
    String nearestLandmark = report['p5_nearestLandmark'] ?? '';
    String totalHoursMissingString = report['p5_totalHoursSinceLastSeen'] ?? '';

    // img links
    mp_locationSnapshot_LINK = report['mp_locSnapshot_LINK'] ?? '';
    mp_recentPhoto_LINK = report['mp_recentPhoto_LINK'] ?? '';
    reportee_ID_Photo_LINK = report['reportee_ID_Photo_LINK '] ?? '';
    reportee_Signature_LINK = report['reportee_Signature_LINK'] ?? '';

    firstName = report['p3_mp_firstName'] ?? '';
    lastName = report['p3_mp_lastName'] ?? '';
    middleName = report['p3_mp_middleName'] ?? '';
    nickname = report['p3_mp_nickname'] ?? '';
    sex = report['p3_mp_sex'] ?? '';
    civilStatus = report['p3_mp_civilStatus'] ?? '';
    age = report['p3_mp_age'] ?? '';
    mobilePhone = report['p3_mp_contact_mobilePhone'] ?? '';
    homePhone = report['p3_mp_contact_homePhone'] ?? '';
    citizenship = report['p3_mp_citizenship'] ?? '';
    birthDate = report['p3_mp_birthDate'] ?? '';
    heightFeet = report['p4_mp_height_inches'] ?? '';
    heightInches = report['p4_mp_height_feet'] ?? '';
    weight = report['p4_mp_weight'] ?? '';
    scars = report['p4_mp_scars'] ?? '';
    marks = report['p4_mp_marks'] ?? '';
    tattoos = report['p4_mp_tattoos'] ?? '';
    hairColor = report['p4_mp_hair_color'] ?? '';
    eyeColor = report['p4_mp_eye_color'] ?? '';
    prosthetics = report['p4_mp_prosthetics'] ?? '';
    birthDefects = report['p4_mp_birth_defects'] ?? '';
    clothingAccessories = report['p4_mp_last_clothing'] ?? '';

    streetHouseNum = report['p3_mp_address_streetHouseNum'] ?? '';
    villageSitio = report['p3_mp_address_villageSitio'] ?? '';
    barangay = report['p3_mp_address_barangay'] ?? '';
    city = report['p3_mp_address_city'] ?? '';
    province = report['p3_mp_address_province'] ?? '';
    region = report['p3_mp_address_region'] ?? '';

    pinnedLocCityMun = report['p5_cityName'] ?? '';
    pinnedLocBarangay = report['p5_brgyName'] ?? '';
    incidentDetails = report['p5_incidentDetails'] ?? '';

    num distance = 0;

    // calculate distance
    if (lastSeenLoc.isNotEmpty) {
      // print('lastseenloc runtime type: ${lastSeenLoc.runtimeType}');
      // print('doubles in lastseenloc: ${extractDoubles(lastSeenLoc)}');
      List<double> lastSeenLocList = extractDoubles(lastSeenLoc);
      double lastSeenLocLat = lastSeenLocList[0];
      double lastSeenLocLong = lastSeenLocList[1];
      LatLng lastSeenLocLatLng = LatLng(lastSeenLocLat, lastSeenLocLong);
      distance = calculateDistance(userLatLng, lastSeenLocLatLng);
      report['distance'] = distance;
    }

    // calculate and update total hours missing (both for if still missing, and if already found)
    if (report['p5_lastSeenDate'] != null &&
        report['p5_lastSeenTime'] != null) {
      DateFormat dateTimeFormat = DateFormat('MMMM d, y hh:mm a');
      DateTime lastSeenDateTime = dateTimeFormat
          .parse('${report['p5_lastSeenDate']} ${report['p5_lastSeenTime']}');
      if (report['status'] == "Already Found") {
        // DateFormat dateTimeFormat = DateFormat('MMMM d, y hh:mm a');
        // use "pnp_dateFound" in report RTDB to calculate total hours missing, defaulting time to 12:00 PM
        // current format is
        //     String dateFound =
        // '${selectedDate.month.toString().padLeft(2, '0')}/'
        // '${selectedDate.day.toString().padLeft(2, '0')}/'
        // '${selectedDate.year.toString()}';
        DateFormat dateTimeFormat = DateFormat('MM/dd/yyyy hh:mm a');
        DateTime foundDateTime = dateTimeFormat.parse(
            '${report['pnp_dateFound']} 12:00 PM'); // 12:00 PM is default time
        // DateTime foundTime = dateTimeFormat.parse(
        // '${report['pnp_dateFound']} 12:00 PM'); // 12:00 PM is default time
        Duration difference = foundDateTime.difference(lastSeenDateTime);
        int differenceInHours = difference.inHours;
        String differenceInHoursString = differenceInHours.toString();
        // update RTDB p5_totalHoursSinceLastSeen
        report['p5_totalHoursSinceLastSeen'] = differenceInHoursString;
        databaseReportsReference
            .child(report['uid'])
            .child(report['key'])
            .update({
          'p5_totalHoursSinceLastSeen': differenceInHoursString,
        });
      } else {
        DateTime now = DateTime.now();
        Duration difference = now.difference(lastSeenDateTime);
        int differenceInHours = difference.inHours;
        String differenceInHoursString = differenceInHours.toString();
        // update RTDB p5_totalHoursSinceLastSeen
        report['p5_totalHoursSinceLastSeen'] = differenceInHoursString;
        databaseReportsReference
            .child(report['uid'])
            .child(report['key'])
            .update({
          'p5_totalHoursSinceLastSeen': differenceInHoursString,
        });
      }
    }

    // calculate and update total hours missing if Already Found (deduct with dateFound) rather than current time

    // CLASSIFIERS
    // is Minor
    if (report['p1_isMinor'] != null && report['p1_isMinor']) {
      importanceString = 'Minor';
    }
    // is Missing over 24 hours
    if (report['p1_isMissing24Hours'] != null &&
        report['p1_isMissing24Hours']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, Over 24 hours missing';
      } else {
        importanceString = 'Over 24 hours missing';
      }
    }
    // adds the isMissing24Hours tag (if FALSE) if the total hours is over 24 hours (calculated based on the current time and date of PNP app)
    if (
        // date and time not missing
        report['p5_lastSeenDate'] != null &&
            report['p5_lastSeenTime'] != null &&
            // over 24 hours
            int.parse(report['p5_totalHoursSinceLastSeen'.trim()]) >= 24 &&
            // isMissing24Hours tag is false when the report is created
            report['p1_isMissing24Hours'] == false) {
      // update RTDB on p1_isMissing24Hours
      report['p1_isMissing24Hours'] = true;
      databaseReportsReference
          .child(report['uid'])
          .child(report['key'])
          .update({
        'p1_isMissing24Hours': true,
      });
    }
    // is victim of a crime
    if (report['p1_isVictimCrime'] != null && report['p1_isVictimCrime']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, \nVictim of Crime';
      } else {
        importanceString = 'Victim of Crime';
      }
    }
    // is victim of natural calamity or human-made accident
    if (report['p1_isVictimNaturalCalamity'] != null &&
        report['p1_isVictimNaturalCalamity']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, \nVictim of Calamity';
      } else {
        importanceString = 'Victim of Calamity';
      }
    }
    report['importanceTags'] = importanceString;

    // mp recent photo
    // if (missingPersonImageString.isNotEmpty) {
    //   missingPersonImageBytes = base64Decode(missingPersonImageString);
    // } else {
    //   missingPersonImageBytes = Uint8List(0);
    // }

    // mp last seen location snapshot
    // if (lastSeenLocSnapshotString.isNotEmpty) {
    //   lastSeenLocSnapshot = base64Decode(lastSeenLocSnapshotString);
    // } else {
    //   lastSeenLocSnapshot = Uint8List(0);
    // }

    var statusValue;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        height: 110,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: 250,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    print('tapped ${report['keyUid']}');
                    print('lastSeenLoc: $lastSeenLoc');
                    print('distance: $distance meters away from you');
                    // print('\n\n');
                    // print(reportList.length);
                    // for (dynamic i in reportList) {
                    //   // print('\n[aye] ${i.keys} ${i.runtimeType}');
                    // }
                    if (dateReported.isNotEmpty) {
                      displayReportDialog(context, report);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        height: 50,
                        width: 50,
                        color: Colors.grey,
                        // decoration: const BoxDecoration(
                        //     color: Colors.grey,
                        //     borderRadius: BorderRadius.all(Radius.circular(20))
                        // ),
                        child: mp_recentPhoto_LINK.isNotEmpty
                            ?
                            // ImageNetwork(
                            //     image: mp_recentPhoto_LINK,
                            //     height: 50,
                            //     width: 50,
                            //     onLoading: const SpinKitChasingDots(
                            //         color: Colors.indigoAccent))
                            Image.network(mp_recentPhoto_LINK)
                            : const Icon(Icons.person),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $lastName',
                            //JUST change the font size to 18 when Name is applied
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          // Text(
                          //   importanceString == ''
                          //       ? 'Absent Person'
                          //       : importanceString,
                          //   style: GoogleFonts.inter(fontSize: 12),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    importanceString == '' ? 'Absent Person' : importanceString,
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700, height: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text('Priority Category',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.black38)),
                ],
              ),
            ),

            // last seen date
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // change text
                  Text(lastSeenDate,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('Last Seen Date',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38)),
                ],
              ),
            ),

            // Last seen time
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(lastSeenTime,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('Last Seen Time',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38)),
                ],
              ),
            ),

            // total hours missing
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(totalHoursMissingString,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('Total Hours Missing',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38)),
                ],
              ),
            ),

            // date reported
            // SizedBox(
            //   width: 200,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Text(dateReported,
            //           style: GoogleFonts.inter(
            //               fontSize: 18, fontWeight: FontWeight.w600)),
            //       Text('Date Reported',
            //           style: GoogleFonts.inter(
            //               fontSize: 12, color: Colors.black38)),
            //     ],
            //   ),
            // ),

            // LAST SEEN LOCATION
            SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(nearestLandmark,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('Last Tracked Location',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black38)),
                ],
              ),
            ),

            const SizedBox(width: 20),
            // CHANGE REPORT STATUS POPUP
            SizedBox(
              width: 160,
              height: 50,
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                onPressed: () {
                  // final currentContext = context;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // String? oldStatusValue = statusValue;
                      String? newStatusValue = statusValue;
                      return AlertDialog(
                        title: Text(
                            // 'Change Report Status of $firstName $lastName'),
                            'Change Report Status of ${report['p3_mp_firstName']} ${report['p3_mp_lastName']}'),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Are you sure you want to change the report status of this missing person?',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              // text to display when no value is selected
                              hint: const Text(
                                'Select Report Status',
                                style: TextStyle(fontSize: 15),
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              value: newStatusValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black54),
                              onChanged: (String? value) {
                                newStatusValue = value;
                              },
                              items: <String>[
                                'Verified',
                                'Already Found',
                                // 'Incomplete Details', -- this can be under "Rejected"
                                'Rejected',
                              ].map<DropdownMenuItem<String>>((statusValue) {
                                return DropdownMenuItem<String>(
                                  value: statusValue,
                                  child: Text(statusValue),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                backgroundColor: Palette.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                statusValue = newStatusValue;
                                report['status'] = statusValue;
                                await databaseReportsReference
                                    .child(report['uid'])
                                    .child(report['key'])
                                    .update({"status": "$statusValue"});
                                // IF REJECTED, PROMPT FOR REASON
                                if (statusValue == "Rejected") {
                                  // Show a dialog box asking for reason for rejection
                                  String? rejectReason;
                                  // ignore: use_build_context_synchronously
                                  await showDialog(
                                    // context: currentContext,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            Text('Enter Reason for Rejection'),
                                        content: TextFormField(
                                          onChanged: (value) {
                                            rejectReason = value;
                                          },
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: 'Type reason here',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          // TextButton(
                                          //   child: Text('Cancel'),
                                          //   onPressed: () async {
                                          //     // revert back to previous status
                                          //     report['status'] = oldStatusValue;
                                          //     await databaseReportsReference
                                          //         .child(report['uid'])
                                          //         .child(report['key'])
                                          //         .update({
                                          //       "status": "$oldStatusValue"
                                          //     });
                                          //     Navigator.of(context).pop();
                                          //   },
                                          // ),
                                          TextButton(
                                            child: Text('Save Reason'),
                                            onPressed: () async {
                                              report['pnp_rejectReason'] =
                                                  rejectReason;
                                              await databaseReportsReference
                                                  .child(report['uid'])
                                                  .child(report['key'])
                                                  .update({
                                                'pnp_rejectReason':
                                                    rejectReason,
                                              });

                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Navigator.of(context).pop();
                                }
                                // end of Rejection reason dialogue box
                                // IF ALREADY FOUND, PROMPT FOR DATE
                                // if (statusValue == "Already Found") {
                                //   // Show a dialog box asking for date found
                                //   String? dateFound;
                                //   // ignore: use_build_context_synchronously
                                //   await showDialog(
                                //     // context: currentContext,
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: Text('Enter Date Found'),
                                //         content:
                                //             // CHANGE THIS TO DATE PICKER
                                //             TextFormField(
                                //           onChanged: (value) {
                                //             dateFound = value;
                                //           },
                                //           maxLines: 3,
                                //           decoration: InputDecoration(
                                //             hintText: 'Type date here',
                                //             border: OutlineInputBorder(
                                //               borderRadius:
                                //                   BorderRadius.circular(10.0),
                                //             ),
                                //           ),
                                //         ),
                                //         // END OF "CHANGE THIS TO DATE PICKER"
                                //         actions: <Widget>[
                                //           // TextButton(
                                //           //   child: Text('Cancel'),
                                //           //   onPressed: () {
                                //           //     // revert back to previous status
                                //           //     oldStatusValue = report['status'];
                                //           //     Navigator.of(context).pop();
                                //           //   },
                                //           // ),
                                //           TextButton(
                                //             child: Text('Save Date'),
                                //             onPressed: () async {
                                //               report['pnp_dateFound'] =
                                //                   dateFound;
                                //               await databaseReportsReference
                                //                   .child(report['uid'])
                                //                   .child(report['key'])
                                //                   .update({
                                //                 'pnp_dateFound': dateFound,
                                //               });

                                //               Navigator.of(context).pop();
                                //             },
                                //           ),
                                //         ],
                                //       );
                                //     },
                                //   );
                                // } else {
                                //   // Navigator.of(context).pop();
                                // }
                                if (statusValue == "Already Found") {
                                  // Show a dialog box asking for date found
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (selectedDate != null) {
                                    // Format the selected date as MM/dd/YYYY
                                    String dateFound =
                                        '${selectedDate.month.toString().padLeft(2, '0')}/'
                                        '${selectedDate.day.toString().padLeft(2, '0')}/'
                                        '${selectedDate.year.toString()}';

                                    report['pnp_dateFound'] = dateFound;
                                    await databaseReportsReference
                                        .child(report['uid'])
                                        .child(report['key'])
                                        .update({
                                      'pnp_dateFound': dateFound,
                                    });
                                  }
                                }
                                // end of Date Found dialogue box
                                print(
                                    '[changed status] ${report['keyUid']} to $statusValue');
                                Navigator.of(context).pop();

                                setState(() {});
                              },
                              child: Text('Confirm'),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        report['status'] == 'pending'
                            ? 'Pending'
                            : report['status'],
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 5),
                    const Icon(Icons.edit, size: 15),
                  ],
                ),
              ),
            ),

            // if status == rejected, show text button to "View Reject Reason" that shows a dialog box with the reason and allows it to be edited
            if (report['status'] == 'Rejected')
              TextButton(
                onPressed: () {
                  String? rejectReason;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Reason for Rejection'),
                        content: TextFormField(
                          initialValue: report['pnp_rejectReason'],
                          onChanged: (value) {
                            rejectReason = value;
                          },
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Type reason here',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () async {
                              report['pnp_rejectReason'] = rejectReason;
                              await databaseReportsReference
                                  .child(report['uid'])
                                  .child(report['key'])
                                  .update({
                                'pnp_rejectReason': rejectReason,
                              });

                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('View Reject Reason'),
              ),

            // if status == already found, show text "Date Found: " and the date found
            if (report['status'] == 'Already Found')
              Text('Date Found: ${report['pnp_dateFound']}'),

            SizedBox(width: 20),

            // ICONS
            SizedBox(
                width: 120,
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: isClicked
                    //       ? Icon(Icons.star_outline_rounded)
                    //       : Icon(Icons.star_rounded)
                    //   onPressed: () {
                    //     setState(() {
                    //       isClicked = !isClicked
                    //     });
                    //   })
                    const IconButton(
                        icon: Icon(Icons.outlined_flag_rounded),
                        onPressed: null),

                    PopupMenuButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black38,
                        ),
                        tooltip: "Show options",
                        itemBuilder: (context) => [
                              const PopupMenuItem(child: Text('Edit')),
                              const PopupMenuItem(child: Text('Add')),
                              const PopupMenuItem(
                                child: Text('Delete'),
                                // onTap: () {
                                //   displayReportDialog(context, report, reportImages);
                                //   setState(() {
                                //   });}
                              )
                            ],
                        onSelected: null),

                    IconButton(
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black38,
                        ),
                        onPressed: () {
                          if (dateReported.isNotEmpty) {
                            displayReportDialog(context, report);
                          }
                        })
                  ],
                )),
            // const IconButton(
            //     icon: Icon(
            //       Icons.chevron_right_rounded,
            //       size: 40,
            //       opticalSize: 100,
            //       color: Colors.black54,
            //     ),
            //     onPressed: null)
          ],
        ),
      ),
    );
  }

  void displayReportDialog(BuildContext context, Map report) {
    String lastSeenDate = report['p5_lastSeenDate'] ?? '';
    String lastSeenTime = report['p5_lastSeenTime'] ?? '';
    String dateReported = report['p5_reportDate'] ?? '';
    String lastSeenLocation = report['p5_lastSeenLoc'] ?? '';
    String nearestLandmark = report['p5_nearestLandmark'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text("Report Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("FIRST NAME",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(15),
                                width:
                                    MediaQuery.of(context).size.width * 0.115,
                                //height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  firstName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LAST NAME",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(15),
                                constraints: BoxConstraints(
                                    minWidth: 100, maxWidth: 200),
                                width:
                                    MediaQuery.of(context).size.width * 0.115,
                                //height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  lastName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MIDDLE NAME",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(15),
                                width:
                                    MediaQuery.of(context).size.width * 0.115,
                                //height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  middleName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NICKNAME",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(15),
                                constraints: BoxConstraints(
                                    minWidth: 100, maxWidth: 200),
                                width:
                                    MediaQuery.of(context).size.width * 0.115,
                                //height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  nickname,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Date Reported
                      Text("DATE REPORTED",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          dateReported,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      // Last Seen Location
                      Text("LAST TRACKED LOCATION",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        ////height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          nearestLandmark,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      // Last Seen Date
                      Text("LAST SEEN DATE",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          lastSeenDate,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      // Last Seen Time
                      Text("LAST SEEN TIME",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          lastSeenTime,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text("Descriptions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                      ),

                      Text("SCARS",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          scars,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("MARKS",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          marks,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("TATTOOS",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          tattoos,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("HAIR COLOR",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          hairColor,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("EYE COLOR",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          eyeColor,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("BIRTH DEFECTS",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          birthDefects,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("PROSTHETICS",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          prosthetics,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("LAST KNOWN CLOTHING AND ACCESSORIES",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        //height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          clothingAccessories,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.all(20),
                        child:
                            // ImageNetwork(
                            //   image: report['mp_recentPhoto_LINK'],
                            //   height: MediaQuery.of(context).size.height,
                            //   width: MediaQuery.of(context).size.width * .4 > 200
                            //       ? MediaQuery.of(context).size.width * .25
                            //       : MediaQuery.of(context).size.width * .4,
                            //   onLoading: const SpinKitCubeGrid(
                            //       color: Colors.indigoAccent),
                            // ),
                            Image.network(
                          report['mp_recentPhoto_LINK'],
                          width: MediaQuery.of(context).size.width * .4 > 200
                              ? MediaQuery.of(context).size.width * .25
                              : MediaQuery.of(context).size.width * .4,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 20),
                          alignment: Alignment.center,
                          child: Text(report['importanceTags'])),
                      // Add more details as needed

                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text("Missing Person Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("HEIGHT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "$heightFeet'$heightInches",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text("WEIGHT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "$weight kg",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      //SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("SEX",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  sex,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text("CIVIL STATUS",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  civilStatus,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("AGE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  age,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text("CITIZENSHIP",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  citizenship,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BIRTHDATE",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: Colors.black54)),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 5, bottom: 15),
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.17,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              birthDate,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ADDRESS",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: Colors.black54)),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 5, bottom: 15),
                            padding: const EdgeInsets.all(15),
                            width: MediaQuery.of(context).size.width * 0.17,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              '$streetHouseNum, $villageSitio, Brgy. $barangay, $city, $province, Region $region',
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 30, bottom: 20),
                            child: Text("Contact Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                )),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MOBILE PHONE NUMBER",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.17,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  mobilePhone,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("HOME PHONE NUMBER",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 2,
                                      color: Colors.black54)),
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.17,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  homePhone,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Palette.indigo,
                        margin: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * 0.25,
                        child:
                            // Image.network(report['mp_locationSnapshot_LINK']),
                            ImageNetwork(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 0.25,
                                image: report['mp_locationSnapshot_LINK'],
                                onLoading: const SpinKitCubeGrid(
                                    color: Colors.indigoAccent)),
                      ),
                      Text("NEAREST LANDMARK",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          nearestLandmark,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Text("CITY/MUNICIPALITY",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          pinnedLocCityMun,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Text("BARANGAY/DISTRICT",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.black54)),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          pinnedLocBarangay,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 10),
                        child: Text("Incident Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 15),
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Text(
                          incidentDetails,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? filterValueLocal = widget.filterValue;
    return Container(
      height: double.infinity,
      child: FutureBuilder(
        future: dbRef.once(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || userLatLng == LatLng(0, 0)) {
            return const SpinKitCubeGrid(
              color: Palette.indigo,
              size: 40.0,
            );
          }
          reportList!.clear();
          dynamic values = snapshot.data?.snapshot.value;
          if (values != null) {
            Map<dynamic, dynamic> reports = values;
            // users
            reports.forEach((key, value) {
              dynamic uid = key;
              // reports of each user
              value.forEach((key, value) {
                value['keyUid'] = '${key}__$uid';
                value['key'] = key;
                value['uid'] = uid;
                var lastSeenLoc = value['p5_lastSeenLoc'] ?? '';
                var status = value['status'] ?? '';
                print('status: $status');
                if (lastSeenLoc != '' && filterValueLocal.contains(status)) {
                  if (userLatLng.latitude == 999999 &&
                      userLatLng.longitude == 999999) {
                    // add report to list
                    reportList!.add(value);
                  } else {
                    List<double> lastSeenLocList = extractDoubles(lastSeenLoc);
                    double lastSeenLocLat = lastSeenLocList[0];
                    double lastSeenLocLong = lastSeenLocList[1];
                    LatLng lastSeenLocLatLng =
                        LatLng(lastSeenLocLat, lastSeenLocLong);
                    var distance =
                        calculateDistance(userLatLng, lastSeenLocLatLng);
                    // currently, distance is set to 10km
                    if (distance <= 10000) {
                      // add report to list
                      reportList!.add(value);
                    } else {
                      print('[NOT OK] distance is: $distance');
                    }
                  }
                }
                // reportList.add(value);
              });
            });
          } else {
            return Container(
              alignment: Alignment.center,
              child: const Text('There are currently no reports here'),
            );
          }

          return reportList!.isNotEmpty
              ? ListView.builder(
                  itemCount: reportList!.length,
                  physics:
                      const BouncingScrollPhysics(parent: PageScrollPhysics()),
                  itemBuilder: (BuildContext context, int index) {
                    return listItem(report: reportList![index]);
                  },
                )
              : Container(
                  alignment: Alignment.center,
                  child: const Text('There are currently no reports'),
                );
        },
      ),
    );
  }
}
