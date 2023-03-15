import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/nearby_main.dart';
import 'package:hanapp/views/main/pages/report_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/views/main/pages/update_main.dart';

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
                //minWidth: viewportConstraints.minWidth,
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width / 10),
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 2.5),
                          child: const IconButton(
                            icon: Icon(Icons.info_outline_rounded, size: 30),
                            onPressed: null,
                          ),
                        ),
                        const IconButton(
                          icon: Icon(Icons.notifications_outlined, size: 30),
                          iconSize: 30,
                          onPressed: null, ),
                        const IconButton(
                          icon: Icon(Icons.account_circle_outlined, size: 30),
                          onPressed: null, ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40 ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // USER NAME: configure here
                          Text('Hi Erru!',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('How can we help?',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Padding(
                            padding: new EdgeInsets.only(top: 50, bottom: 10),
                            child: Image.asset('assets/images/home.png',
                                height: MediaQuery.of(context).size.width * .4
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UpdateMain(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 90,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 4.0), //(x,y)
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                                child: const Text('REPORT PLACEHOLDER'),
                              ),
                            ),
                          ),
                          
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NearbyMain(),
                                ),
                              );
                            },
                            child: Container(
                              height: 90,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 4.0), //(x,y)
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),
                              child: const Text('NEARBY PLACEHOLDER'),
                            ),
                          ),
                        ],
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
