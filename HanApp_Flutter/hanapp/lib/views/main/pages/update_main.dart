import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';

import '../../../main.dart';

class UpdateMain extends StatefulWidget {
  const UpdateMain({super.key});

  @override
  State<UpdateMain> createState() => _UpdateMainState();
}

class _UpdateMainState extends State<UpdateMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');
  List<Map> reportList = [];
  final user = FirebaseAuth.instance.currentUser;

  Widget listItem({required Map report}) {
    String reportName = 'No Name';
    if (report['p3_mp_lastName'] != null && report['p3_mp_firstName'] != null) {
      reportName = report['p3_mp_firstName'] + " " + report['p3_mp_lastName'];
    }

    String status = report['status'];

    Color containerColor;
    switch (status) {
      case 'Pending':
        containerColor = Palette.indigo;
        break;
      case 'Verified':
        containerColor = Colors.green;
        break;
      case 'Rejected':
        containerColor = Colors.deepOrange;
        break;
      case 'Already Found':
        containerColor = Colors.yellow;
        break;
      default:
        containerColor = Colors.grey;
        break;
    }

    Text statusChange;
    switch (status) {
      case 'Pending':
        statusChange = const Text('Received',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.center);
        break;
      case 'Verified':
        statusChange = const Text('Verified',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.center);
        break;
      case 'Rejected':
        statusChange = const Text('Rejected',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.center);
        break;
      case 'Already Found':
        statusChange = const Text('Found',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.center);
        break;
      default:
        statusChange = const Text('Incomplete',
            style: TextStyle(color: Colors.white), textAlign: TextAlign.center);
        break;
    }

    print(report['status']);
    print(report.keys);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: ListTile(
        title: Text(reportName),
        subtitle: Text(report['p5_reportDate']),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(40),
        // ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: containerColor),
              //Retrieve the status here
              child: statusChange,
            ),
            // Text(report['p5_reportDate'],
            //   style: TextStyle(fontSize: 10),),
          ],
        ),
      ),
    );
  }

  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .15,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 5,
                    right: MediaQuery.of(context).size.width / 5),
                child: const Text(
                  'Updates',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
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
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .05, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.1),
                  child: Text('Reports',
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 24))),
                ),
              ],
            ),
          ),
          Container(
            //margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
            height: MediaQuery.of(context).size.height * .65,
            width: MediaQuery.of(context).size.width * .85,
            child: StreamBuilder(
              stream: dbRef.onValue,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print('snapshot: $snapshot');
                if (!snapshot.hasData) {
                  return const SpinKitCubeGrid(
                    color: Palette.indigo,
                    size: 30.0,
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
                    print('key = $key');
                    if (key == user?.uid) {
                      value.forEach((key, value) {
                        value['key'] = '${key}__$uid';
                        value['uid'] = uid;
                        // add report to list
                        reportList.add(value);
                      });
                    }
                  });
                  if (reportList.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      child: const Text(
                          'There are currently no submitted reports'),
                    );
                  }
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child:
                        const Text('There are currently no submitted reports'),
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
          ),
        ],
      ),
    );
  }
}
