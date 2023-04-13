import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      reportName = report['p3_mp_lastName'] + ', ' + report['p3_mp_firstName'];
    }
    print(report.keys);
    return Card(
      child: ListTile(
        title: Text(reportName),
        subtitle: Text('description'),
        trailing: Text(report['p5_reportDate']),
      ),
    );
  }

  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .2),
      height: MediaQuery.of(context).size.height * .6,
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
    );
  }
}
