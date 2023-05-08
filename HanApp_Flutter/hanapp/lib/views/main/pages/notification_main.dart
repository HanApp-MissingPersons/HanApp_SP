import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
    retrieveHiddenReports();
  }

  retrieveHiddenReports() async {
    final snapshot = await notificationRef.child(userUid).once();
    hiddenReports = snapshot.snapshot.key ?? {};
    print('PRINT HIDDEN: $hiddenReports');
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

  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return widget.reports.isNotEmpty
        ? Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.only(top: 100.0),
              child: ListView.builder(
                itemCount: widget.reports.length,
                itemBuilder: (context, index) {
                  return ListTile(
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
                                  print(
                                      'hiding notification ${widget.reports.values}');
                                  await FirebaseDatabase.instance
                                      .ref('Notifications')
                                      .child(userUid)
                                      .child(widget.reports.keys
                                          .elementAt(index)
                                          .toString())
                                      .set('hidden');
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop();
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
                    title: const Text('Missing persons last seen in your area'),
                    subtitle:
                        const Text('Check Nearby Reports for more details'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Navigate to Nearby Reports?"),
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
                  );
                },
              ),
            ),
          )
        : Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(
                    Icons.notifications_paused_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const Text(
                    'No notifications',
                    style: optionStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
