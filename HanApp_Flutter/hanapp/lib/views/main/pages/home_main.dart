import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/report_main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  //static const TextStyle optionStyle = TextStyle(
  //    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.minHeight,
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                child: Column (
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 2),
                          child: const IconButton(
                            icon: Icon(Icons.info_outline_rounded),
                            onPressed: null,
                          ),
                        ),
                        const IconButton(
                          icon: Icon(Icons.notifications_outlined),
                          onPressed: null, ),
                        const IconButton(
                          icon: Icon(Icons.account_circle_outlined),
                          onPressed: null, ),
                      ],
                    ),
                    Text('How can we help?',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
      }
    );
  }
}
