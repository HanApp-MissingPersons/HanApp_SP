import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class reportsPNP extends StatefulWidget {
  const reportsPNP({Key? key}) : super(key: key);

  @override
  State<reportsPNP> createState() => _reportsPNPState();
}

class _reportsPNPState extends State<reportsPNP> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');
  List<Map> reportList = [];

  Widget listItem({required Map report}) {
    print('[report] $report');
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      color: Colors.purple.shade100,
      child: Column(
        children: [
          Text('Report Key: ${report['key']}'),
          GestureDetector(
            onTap: () {
              print('Tapped');
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('View Report'),
            ),
          ),
        ],
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
            return const CircularProgressIndicator();
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
                print('[key] $key');
                print('[value] $value');
                reportList.add(value);
              });
            });
            // print('[reports] ${reports.values}');
            // dynamic whoa = Map.fromIterable(reports.values);
            Map<dynamic, dynamic> map = {
              for (var item in reports.values) item: item
            };
            // print(map.keys.length);
            // print('[keys] ${whoa.values}');
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
