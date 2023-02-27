import 'package:flutter/material.dart';

class UpdateMain extends StatefulWidget {
  const UpdateMain({super.key});

  @override
  State<UpdateMain> createState() => _UpdateMainState();
}

class _UpdateMainState extends State<UpdateMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 4: Updates',
      style: optionStyle,
    );
  }
}
