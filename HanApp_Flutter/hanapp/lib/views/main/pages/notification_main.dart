import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class NotificationMain extends StatefulWidget {
  final Map<dynamic, dynamic> reports;
  final VoidCallback missingPersonTap;
  const NotificationMain(
      {super.key, required this.reports, required this.missingPersonTap});

  @override
  State<NotificationMain> createState() => _NotificationMain();
}

class _NotificationMain extends State<NotificationMain> {
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');
  final notificationRef = FirebaseDatabase.instance.ref('Notifications');
  final userUid = FirebaseAuth.instance.currentUser!.uid;
  dynamic hiddenReports = {};

  late dynamic _reports = {};

  Future<void> _fetchData() async {
    final snapshot = await dbRef2.once();
    setState(() {
      _reports = snapshot.snapshot.value ?? {};
    });
    print(
        '[DATA FETCHED] [DATA FETCHED] [DATA FETCHED] [DATA FETCHED] [DATA FETCHED]');
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    // retrieveHiddenReports();
  }

  //final mp_recentPhoto_LINK = dbRef2['mp_recentPhoto_LINK'];

  // retrieveHiddenReports() async {
  //   final snapshot = await notificationRef.child(userUid).once();
  //   hiddenReports = snapshot.snapshot.value ?? {};
  //   print('PRINT HIDDEN: ${hiddenReports.keys.toList()}');
  // }

  List<double> extractDoubles(String input) {
    RegExp regExp = RegExp(r"[-+]?\d*\.?\d+");
    List<double> doubles = [];
    Iterable<RegExpMatch> matches = regExp.allMatches(input);
    for (RegExpMatch match in matches) {
      doubles.add(double.parse(match.group(0)!));
    }
    return doubles;
  }

  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle =
      TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black);
  @override
  Widget build(BuildContext context) {
    // Map<dynamic, dynamic> reportsUnclean = widget.reports;
    // Map<dynamic, dynamic> reportsClean =
    //     Map.from(reportsUnclean); // make a copy of reportsUnclean

    // for (var key in hiddenReports.keys.toList()) {
    //   reportsClean.remove(key);
    // }

    return widget.reports.isNotEmpty
        ? Center(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Image.asset('assets/images/hanappLogo.png',
                            width: 35),
                      ),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: Icon(Icons.account_circle_outlined, size: 30),
                        selectedIcon: Icon(Icons.account_circle, size: 30),
                        onPressed: () {
                          // sign out the user
                          // FirebaseAuth.instance.signOut();
                          // navigate to the login page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileMain(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // NOTIFICATIONS LIST
                Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.only(top: 30.0),
                  child: ListView.builder(
                    itemCount: widget.reports.length,
                    itemBuilder: (context, index) {
                      dynamic currentReportValues =
                          widget.reports[widget.reports.keys.elementAt(index)];
                      dynamic currentReportKey =
                          widget.reports.keys.elementAt(index);

                      bool minor = currentReportValues['p1_isMinor'] ?? false;
                      bool crime =
                          currentReportValues['p1_isVictimCrime'] ?? false;
                      bool calamity =
                          currentReportValues['p1_isVictimNaturalCalamity'] ??
                              false;
                      bool over24hours =
                          currentReportValues['p1_isMissing24Hours'] ?? false;

                      final lastSeendate =
                          currentReportValues['p5_lastSeenDate'] ?? '';
                      final lastSeenTime =
                          currentReportValues['p5_lastSeenTime'] ?? '';

                      final firstName =
                          currentReportValues['p3_mp_firstName'] ?? '';
                      final lastName =
                          currentReportValues['p3_mp_lastName'] ?? '';
                      final mp_recentPhoto_LINK = currentReportValues[
                              'mp_recentPhoto_LINK'] ??
                          'https://images.squarespace-cdn.com/content/v1/5b8709309f87706a308b674a/1630432472107-419TL4L1S480Z0LIVRYA/Missing.jpg';
                      final lastSeenLoc =
                          currentReportValues['p5_nearestLandmark'] ?? '';
                      final dateReported =
                          currentReportValues['p5_reportDate'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 4,
                          child: ListTile(
                            isThreeLine: true,
                            dense: true,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: Container(
                                      width: 48,
                                      height: 48,
                                      color: Palette.indigo,
                                      child:
                                          Image.network(mp_recentPhoto_LINK)),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0))),
                                    title: const Text("Remove Notification"),
                                    content: const Text(
                                      "Are you sure you want to hide this notification?",
                                      textScaleFactor: 0.9,
                                    ),
                                    actions: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 20),
                                              child: Container(
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    color: Palette.indigo,
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref('Notifications')
                                                        .child(userUid)
                                                        .child(widget
                                                            .reports.keys
                                                            .elementAt(index)
                                                            .toString())
                                                        .set('hidden');
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.remove_red_eye_outlined),
                                ],
                              ),
                            ),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Container(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '$firstName $lastName',
                                      style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  Text(
                                    "Last Seen: $lastSeendate, $lastSeenTime at $lastSeenLoc",
                                    style: TextStyle(color: Colors.black54),
                                    textScaleFactor: 0.9,
                                  ),
                                  Text(
                                    "\nDate Reported: $dateReported",
                                    style: TextStyle(color: Colors.black54),
                                    textScaleFactor: 0.8,
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    width:
                                        MediaQuery.of(context).size.width * 5,
                                    child: Visibility(
                                      visible: minor ||
                                          crime ||
                                          calamity ||
                                          over24hours,
                                      child: Wrap(
                                        children: [
                                          Visibility(
                                            visible: crime,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 5, top: 5),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.deepPurple),
                                              //Retrieve the status here
                                              child: const Text(
                                                'Victim of Crime',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: over24hours,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 5, top: 5),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.green),
                                              //Retrieve the status here
                                              child: const Text(
                                                '> 24 Hours',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: calamity,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 5, top: 5),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.orangeAccent),
                                              //Retrieve the status here
                                              child: const Text(
                                                'Victim of Calamity',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: minor,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 5, top: 5),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.redAccent),
                                              //Retrieve the status here
                                              child: const Text(
                                                'Minor',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 10,
                                      ),
                                      Text(
                                        'Tap to view more details in Nearby Reports',
                                        textScaleFactor: 0.65,
                                      ),
                                    ],
                                  ),
                                  //Text('$currentReportValues['']'),,
                                ],
                              ),
                            ),
                            // Text(
                            //     'Check Nearby Reports for more details, current Report: ${currentReportKey}'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0))),
                                    title: const Text(
                                        "Proceed to Nearby Reports?",
                                        textScaleFactor: 0.8),
                                    content: const Text(
                                      "Are you sure you want to navigate to the Nearby Reports map?",
                                      textScaleFactor: 0.9,
                                    ),
                                    actions: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 20),
                                              child: Container(
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    color: Palette.indigo,
                                                    border:
                                                        Border.all(width: 0.5),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    widget.missingPersonTap();
                                                    Navigator.of(context).pop();
                                                    // if user is on report page and wants to navigate away
                                                    // clear the pref
                                                  },
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.10),
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Image.asset('assets/images/hanappLogo.png',
                          width: 35),
                    ),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: Icon(Icons.account_circle_outlined, size: 30),
                      selectedIcon: Icon(Icons.account_circle, size: 30),
                      onPressed: () {
                        // sign out the user
                        // FirebaseAuth.instance.signOut();
                        // navigate to the login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileMain(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Text(
                'Take a Break',
                style: optionStyle,
                textAlign: TextAlign.center,
              ),
              const Text(
                '\nNo new reported missing person near you!',
                textScaleFactor: 0.8,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 40, bottom: MediaQuery.of(context).size.height * 0.12),
                child: Image.asset(
                  'assets/images/no_notif.png',
                  height: 300,
                ),
              )
            ],
          );
  }
}
