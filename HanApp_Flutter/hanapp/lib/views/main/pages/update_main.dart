import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

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
    switch(status) {
      case 'Pending':
        containerColor = Palette.indigo;
        break;
      case 'Verified':
        containerColor = Colors.green;
        break;
      case 'Rejected':
        containerColor = Colors.deepOrange;
        break;
      default:
        containerColor = Colors.grey;
        break;
    }

    print(report['status']);
    print(report.keys);
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
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
                color: containerColor
              ),
              //Retrieve the status here
              child: Text(status=='Pending'?'Received':status,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,),
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
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .1, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
                  child: Text('Reports',
                  style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                      fontSize: 24))),
                ),
              ],
            ),
          ),

          Container(
            //margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
            height: MediaQuery.of(context).size.height * .7,
            width: MediaQuery.of(context).size.width * .85,
            child: StreamBuilder(
              stream: dbRef.onValue,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print('snapshot: $snapshot');
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
                      child: const Text('There are currently no submitted reports'),
                    );
                  }
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: const Text('There are currently no submitted reports'),
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
