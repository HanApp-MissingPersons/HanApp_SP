import 'package:flutter/material.dart';

class ReportMain extends StatefulWidget {
  const ReportMain({super.key});

  @override
  State<ReportMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<ReportMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 1: Report',
      style: optionStyle,
    );
  }
}
