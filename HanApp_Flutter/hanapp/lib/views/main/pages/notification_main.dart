import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    // retrieveHiddenReports();
  }

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
  static const TextStyle optionStyle = TextStyle(
      fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black);
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
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .15,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 6.7,
                            right: MediaQuery.of(context).size.width / 6.7),
                        child: const Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
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
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.only(top: 30.0),
                  child: ListView.builder(
                    itemCount: widget.reports.length,
                    itemBuilder: (context, index) {
                      dynamic currentReportValues =
                          widget.reports[widget.reports.keys.elementAt(index)];
                      dynamic currentReportKey =
                          widget.reports.keys.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 3,
                          child: ListTile(
                            isThreeLine: true,
                            dense: true,
                            leading: const Icon(Icons.person_search_outlined),
                            trailing: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Hide notification?"),
                                    content: const Text(
                                        "Are you sure you want to hide this notification?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("No"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseDatabase.instance
                                              .ref('Notifications')
                                              .child(userUid)
                                              .child(widget.reports.keys
                                                  .elementAt(index)
                                                  .toString())
                                              .set('hidden');
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: const Text("Yes"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Icon(Icons.remove_red_eye_outlined),
                            ),
                            tileColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: const Text(
                                'Missing persons last seen in your area'),
                            subtitle: Text(
                                'Check Nearby Reports for more details, current Report: ${currentReportKey}'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title:
                                      const Text("Navigate to Nearby Reports?"),
                                  content: const Text(
                                      "Are you sure you want to navigate to the Nearby Reports screen?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget.missingPersonTap();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ),
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
        : Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    'Take a Break',
                    style: optionStyle,
                    textAlign: TextAlign.center,
                  ),

                  const Text(
                    '\nNo reported missing person near you!',
                    textScaleFactor: 0.8,
                    textAlign: TextAlign.center,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Image.asset('assets/images/no_notif.png', height: 300,),
                  )
                ],
              ),
            ),
          );
  }
}
