import 'package:flutter/material.dart';

class Page2ReporteeDetails extends StatefulWidget {
  const Page2ReporteeDetails({super.key});

  @override
  State<Page2ReporteeDetails> createState() => _Page2ReporteeDetailsState();
}

class _Page2ReporteeDetailsState extends State<Page2ReporteeDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 2: Reportee Details',
      style: optionStyle,
    );
  }
}
