import 'package:flutter/material.dart';

class HomePageCompanion extends StatefulWidget {
  const HomePageCompanion({Key? key}) : super(key: key);

  @override
  State<HomePageCompanion> createState() => _HomePageCompanionState();
}

class _HomePageCompanionState extends State<HomePageCompanion> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('COMPANION HOMEPAGE'));
  }
}
