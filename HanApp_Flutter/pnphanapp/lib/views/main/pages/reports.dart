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
  @override
  Widget build(BuildContext context) {
    return Text('Reports PNP firebase initialized.');
  }
}
