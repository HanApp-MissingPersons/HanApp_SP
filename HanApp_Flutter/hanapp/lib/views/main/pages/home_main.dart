import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 0: Home',
    );
    //return const Scaffold(
    //  body: Center(
    //    child: SpinKitCubeGrid(
    //      color: Color(0xFF6B53FD),
    //      size: 50,
    //    ),
    //  )
    //);
  }
}
