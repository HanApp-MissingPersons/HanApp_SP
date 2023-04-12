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

  Widget listItem({required Map report}) {
    // ignore: unused_local_variable
    Map reportImages;
    if (report.containsKey('images')) {
      reportImages = report['images'];
    }

    String importanceString = '';
    String lastSeenDate = report['p5_lastSeenDate'] ?? '';
    String lastSeenTime = report['p5_lastSeenTime'] ?? '';
    String dateReported = report['p5_reportDate'] ?? '';
    if (report['p1_isMinor'] != null && report['p1_isMinor']) {
      importanceString = 'Minor';
    }
    if (report['p1_isMissing24Hours'] != null &&
        report['p1_isMissing24Hours']) {
      if (importanceString.isNotEmpty) {
        importanceString = '${importanceString}, Over 24 hours missing';
      } else {
        importanceString = 'Over 24 hours missing';
      }
    }
    if (report['p1_isVictimCrime'] != null && report['p1_isVictimCrime']) {
      if (importanceString.isNotEmpty) {
        importanceString = '$importanceString, \nVictim of Crime';
      } else {
        importanceString = '\nVictim of Crime';
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
        child: GestureDetector(
          onTap: () {
            print('tapped ${report['key']}');
            // print('\n\n');
            // print(reportList.length);
            // for (dynamic i in reportList) {
            //   // print('\n[aye] ${i.keys} ${i.runtimeType}');
            // }
          },
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      height: 50,
                      width: 50,
                      color: Colors.indigo,
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
                        Text(
                          importanceString == ''
                              ? 'Absent Person'
                              : importanceString,
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ],
                    ),
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
                    Text('Last Seen Date',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.black38)),
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
                    Text('Last Seen time',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.black38)),
                  ],
                ),
              ),

              // date reported
              SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(dateReported,
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    Text('Date Reported',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.black38)),
                  ],
                ),
              ),

              // LAST SEEN LOCATION
              SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Brgy. Maty, Miagao',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    Text('Last Tracked Location',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.black38)),
                  ],
                ),
              ),

              SizedBox(
                width: 180,
                height: 50,
                child: DropdownButtonFormField<String>(
                  // text to display when no value is selected
                  hint: Text('Select Report Status'),
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
                    'Received',
                    'Verified',
                    'Already Found',
                    'Incomplete Details',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),

              // ICONS
              SizedBox(
                  width: 150,
                  child: Row(
                    children: const [
                      // IconButton(
                      //   icon: isClicked
                      //       ? Icon(Icons.star_outline_rounded)
                      //       : Icon(Icons.star_rounded)
                      //   onPressed: () {
                      //     setState(() {
                      //       isClicked = !isClicked
                      //     });
                      //   })
                      IconButton(
                          icon: Icon(Icons.star_outline_rounded),
                          onPressed: null),
                      IconButton(
                          icon: Icon(Icons.outlined_flag_rounded),
                          onPressed: null),
                    ],
                  )),
              const IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    size: 40,
                    color: Colors.black54,
                  ),
                  onPressed: null)
            ],
          ),
        ),
      ),
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
            itemBuilder: (BuildContext context, int index) {
              return listItem(report: reportList[index]);
            },
          );
        },
      ),
    );
  }
}
