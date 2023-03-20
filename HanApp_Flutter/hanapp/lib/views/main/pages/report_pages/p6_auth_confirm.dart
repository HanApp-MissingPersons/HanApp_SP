import 'package:flutter/material.dart';

class Page6AuthConfirm extends StatefulWidget {
  const Page6AuthConfirm({super.key});

  @override
  State<Page6AuthConfirm> createState() => _Page6AuthConfirmState();
}

class _Page6AuthConfirmState extends State<Page6AuthConfirm> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 6: Confirmation and Authorization',
      style: optionStyle,
    );
  }
}
