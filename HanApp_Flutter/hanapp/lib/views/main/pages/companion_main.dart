import 'package:flutter/material.dart';

class CompanionMain extends StatefulWidget {
  const CompanionMain({super.key});

  @override
  State<CompanionMain> createState() => _CompanionMain();
}

class _CompanionMain extends State<CompanionMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 3: Companion',
      style: optionStyle,
    );
  }
}
