import 'package:flutter/material.dart';

class Page5IncidentDetails extends StatefulWidget {
  const Page5IncidentDetails({super.key});

  @override
  State<Page5IncidentDetails> createState() => _Page5IncidentDetailsState();
}

class _Page5IncidentDetailsState extends State<Page5IncidentDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

  // local variables for text fields
  String? lastSeenDate;
  String? lastSeenTime;
  String? lastSeenLoc;

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 5: Incident Details',
      style: optionStyle,
    );
  }
}
