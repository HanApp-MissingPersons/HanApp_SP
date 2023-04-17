import 'dart:convert';
//import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/main.dart';

class reportsPNP extends StatefulWidget {
  const reportsPNP({Key? key}) : super(key: key);

  @override
  State<reportsPNP> createState() => _reportsPNPState();
}

class _reportsPNPState extends State<reportsPNP> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');
  List<Map> reportList = [];
  Uint8List lastSeenLocSnapshot = Uint8List(0);
  String scars = "";

  Widget listItem({required Map report}) {
    // ignore: unused_local_variable
    Map reportImages = {};
    if (report.containsKey('images')) {
      reportImages = report['images'];
    }

    String importanceString = '';
    String lastSeenDate = report['p5_lastSeenDate'] ?? '';
    String lastSeenTime = report['p5_lastSeenTime'] ?? '';
    String dateReported = report['p5_reportDate'] ?? '';
    String missingPersonImageString = reportImages['p4_mp_recent_photo'] ?? '';
    String lastSeenLocSnapshotString = reportImages['p5_locSnapshot'] ?? '';
    String nearestLandmark = report['p5_nearestLandmark'] ?? '';
    Uint8List missingPersonImageBytes;
    scars = report['p4_mp_scars'] ?? "";

    // classify importance
    if (report['p1_isMinor'] != null && report['p1_isMinor']) {
      importanceString = 'Minor';
    }
    if (report['p1_isMissing24Hours'] != null &&
        report['p1_isMissing24Hours']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, Over 24 hours missing';
      } else {
        importanceString = 'Over 24 hours missing';
      }
    }
    if (report['p1_isVictimCrime'] != null && report['p1_isVictimCrime']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, \nVictim of Crime';
      } else {
        importanceString = 'Victim of Crime';
      }
    }
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
    if (missingPersonImageString.isNotEmpty) {
      missingPersonImageBytes = base64Decode(missingPersonImageString);
    } else {
      missingPersonImageBytes = Uint8List(0);
    }

    // mp last seen location snapshot
    if (lastSeenLocSnapshotString.isNotEmpty) {
      lastSeenLocSnapshot = base64Decode(lastSeenLocSnapshotString);
    } else {
      lastSeenLocSnapshot = Uint8List(0);
    }

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
                    print('tapped ${report['key']}');
                    // print('\n\n');
                    // print(reportList.length);
                    // for (dynamic i in reportList) {
                    //   // print('\n[aye] ${i.keys} ${i.runtimeType}');
                    // }
                    if (dateReported.isNotEmpty) {
                      displayReportDialog(context, report, reportImages);
                    }
                    setState(() {});
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
                        child: missingPersonImageString.isNotEmpty
                            ? Image.memory(missingPersonImageBytes)
                            : const Icon(Icons.person),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Key: ${report['key']}',
                            //JUST change the font size to 18 when Name is applied
                            style: GoogleFonts.inter(
                                fontSize: 6, fontWeight: FontWeight.w700),
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
              width: 200,
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

            SizedBox(
              width: 165,
              height: 50,
              child: DropdownButtonFormField<String>(
                // text to display when no value is selected
                hint: const Text(
                  'Select Report Status',
                  style: TextStyle(fontSize: 12),
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                value: null,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black54),
                onChanged: null,
                items: <String>[
                  'Verified',
                  'Already Found',
                  'Incomplete Details',
                  'Rejected',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

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
                            displayReportDialog(context, report, reportImages);
                          }
                          setState(() {});
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

  void displayReportDialog(BuildContext context, Map report, Map reportImages) {
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
            // title: Text(
            //   "Report Details",
            //   textAlign: TextAlign.center,
            // ),
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
                                  'Juan Manuel',
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
                                  'dela Cruz',
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

                      // Last Seen Location
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
                        ////height: MediaQuery.of(context).size.height * 0.1,
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
                          "Birthmark near shoulders",
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
                          "Butterfly tattoo thighs",
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
                          "Pink",
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
                          "Violet/Purple",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),

                      Text("PROSTHETICS/BIRTH DEFECTS",
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
                          "NA",
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
                          "Pink Dress, headband and violet gem earings",
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
                        child: Image.memory(
                          base64Decode(reportImages['p4_mp_recent_photo']),
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
                                margin: const EdgeInsets.only(top: 5),
                                //padding: const EdgeInsets.only(left: 15),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "5'4",
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
                                margin: const EdgeInsets.only(top: 5),
                                //padding: const EdgeInsets.only(left: 15),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "60 kg",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

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
                                margin: const EdgeInsets.only(top: 5),
                                //padding: const EdgeInsets.only(left: 15),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "Female",
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
                                margin: const EdgeInsets.only(top: 5),
                                //padding: const EdgeInsets.only(left: 15),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
                                child: Text(
                                  "Separated",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        child: Text("Contact Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                      ),
                    ],
                  ),
                  Container(
                    color: Palette.indigo,
                    margin: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.2,
                    //height: MediaQuery.of(context).size.height * 0.8,
                    child: Image.memory(lastSeenLocSnapshot),
                  )
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
    return Container(
      height: double.infinity,
      child: StreamBuilder(
        stream: dbRef.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SpinKitCubeGrid(
              color: Palette.indigo,
              size: 40.0,
            );
          }
          reportList.clear();
          dynamic values = snapshot.data?.snapshot.value;
          if (values != null) {
            Map<dynamic, dynamic> reports = values;
            // users
            reports.forEach((key, value) {
              dynamic uid = key;
              // reports of each user
              value.forEach((key, value) {
                value['key'] = '${key}__$uid';
                value['uid'] = uid;

                // add report to list
                reportList.add(value);
              });
            });
          } else {
            return Container(
              alignment: Alignment.center,
              child: const Text('There are currently no reports'),
            );
          }

          return ListView.builder(
            itemCount: reportList.length,
            physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
            itemBuilder: (BuildContext context, int index) {
              return listItem(report: reportList[index]);
            },
          );
        },
      ),
    );
  }
}
