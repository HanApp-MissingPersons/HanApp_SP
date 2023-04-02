import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/views/main/pnp_navigation_view.dart';
import 'package:pnphanapp/views/main/report_dashboard_main.dart';
import 'package:pnphanapp/views/pnp_login_view.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanApp PNP Initial Set Up',
      theme: ThemeData(
        primarySwatch: Palette.indigo,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const NavRailView(),
    );
  }
}

class Palette {
  static const MaterialColor indigo = MaterialColor(
    0xFF6B53FD, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF604be4),//10%
      100: Color(0xff5642ca),//20%
      200: Color(0xff4b3ab1),//30%
      300: Color(0xff403298),//40%
      400: Color(0xff362a7f),//50%
      500: Color(0xff2b2165),//60%
      600: Color(0xff20194c),//70%
      700: Color(0xff151133),//80%
      800: Color(0xff0b0819),//90%
      900: Color(0xff000000),//100%
    },
  );
}
