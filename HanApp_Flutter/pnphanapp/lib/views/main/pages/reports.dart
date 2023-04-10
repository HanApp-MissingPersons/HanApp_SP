import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../../../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class reportsPNP extends StatefulWidget {
  const reportsPNP({super.key});

  @override
  State<reportsPNP> createState() => _reportsPNPState();
}

// ignore: camel_case_types
class _reportsPNPState extends State<reportsPNP> {
  Query dbRef = FirebaseDatabase.instance.ref().child('Reports');

  Widget listItem({required Map report}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      color: Colors.purple.shade100,
      child: Column(
        children: [
          const Text('Reportee name'),
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
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            dynamic values = snapshot.value;
            print('[values] ${values[0]}');
            // Map report = snapshot.value as Map;
            // return listItem(report: report);
            return (Text('balls'));
          },
        ));
  }
}
