import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/main.dart';
import 'package:hanapp/views/main/pages/nearby_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';
import 'package:hanapp/views/main/pages/update_main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeMain extends StatefulWidget {
  final VoidCallback onReportPressed;
  final VoidCallback onNearbyPressed;
  const HomeMain(
      {super.key,
      required this.onReportPressed,
      required this.onNearbyPressed});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final user = FirebaseAuth.instance.currentUser;
  String? displayName;
  List<String>? tokenNames;

  @override
  void initState() {
    displayName = user!.displayName;
    try {
      tokenNames = displayName?.split(' ');
      displayName = tokenNames![0];
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return displayName != null
          ? SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.minHeight,
                  //minWidth: viewportConstraints.minWidth,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width / 2.5),
                              child: const IconButton(
                                icon: Icon(Icons.info_outline_rounded, size: 35),
                                onPressed: null,
                              ),
                            ),
                            const IconButton(
                              icon: Icon(Icons.notifications_outlined, size: 35),
                              onPressed: null,
                            ),
                            IconButton(
                              icon: Icon(Icons.account_circle_outlined, size: 35),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileMain(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // USER NAME: configure here
                            Text(
                              'Hi $displayName!',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'How can we help?',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Padding(
                              padding: new EdgeInsets.only(top: 20, bottom: 10),
                              child: Image.asset('assets/images/home.png',
                                  height:
                                      MediaQuery.of(context).size.width * .4),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  widget.onReportPressed();
                                },
                                child: Container(
                                  height: 90,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF781D),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 4.0), //(x,y)
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                      'assets/images/reportCont.png'),
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                widget.onNearbyPressed();
                              },
                              child: Container(
                                height: 90,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Palette.indigo,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 4.0), //(x,y)
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                                child:
                                    Image.asset('assets/images/NearbyCont.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          :
          // if user deets are still being retrieved.
          const Center(
              child: SpinKitCubeGrid(
                color: Palette.indigo,
                size: 40.0,
              ),
            );
    });
  }
}
