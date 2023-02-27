import 'package:flutter/material.dart';

class NearbyMain extends StatefulWidget {
  const NearbyMain({super.key});

  @override
  State<NearbyMain> createState() => _NearbyMain();
}

class _NearbyMain extends State<NearbyMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 2: Nearby',
      style: optionStyle,
    );
  }
}
