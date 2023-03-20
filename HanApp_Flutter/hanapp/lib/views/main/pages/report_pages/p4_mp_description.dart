import 'package:flutter/material.dart';

class Page4MPDesc extends StatefulWidget {
  const Page4MPDesc({super.key});

  @override
  State<Page4MPDesc> createState() => _Page4MPDescState();
}

class _Page4MPDescState extends State<Page4MPDesc> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 4: Absent/Missing Person Description',
      style: optionStyle,
    );
  }
}
