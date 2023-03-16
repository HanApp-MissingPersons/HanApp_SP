import 'package:flutter/material.dart';

class Page3MPDetails extends StatefulWidget {
  const Page3MPDetails({super.key});

  @override
  State<Page3MPDetails> createState() => _Page3MPDetailsState();
}

class _Page3MPDetailsState extends State<Page3MPDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 3: Absent/Missing Person Details',
      style: optionStyle,
    );
  }
}
