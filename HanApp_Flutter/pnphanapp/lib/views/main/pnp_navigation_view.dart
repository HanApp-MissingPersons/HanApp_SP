import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/main.dart';

class NavRailView extends StatefulWidget {
  const NavRailView({super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  int _selectedIndex = 0;
  bool isClicked = false;

  final List<Widget> _destinations = [
    // Dashboard Main
    Container(
      child: Column(
        children: [
          Container(
            child: Column(
              children: const [
                Text('Search'),
                Divider(
                ),
                Text('IDK'),
              ],
            ),
          ),
          Row(
            children: [
              Text('Reports',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,)),
              const Text('Filter')
            ],
          ),
          Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                addAutomaticKeepAlives: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Erru Torculas',
                                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                                      ),
                                      Text('Minor, Victim of Calamity',
                                        style: GoogleFonts.inter(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // TIME REPORTED
                            SizedBox(
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('11:55', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                                  Text('Time Reported',
                                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                                ],
                              ),
                            ),
                            
                            // DATE REPORTED
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('April 11, 2023', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                                  Text('Date Reported',
                                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                                ],
                              ),
                            ),
                            
                            // LAST SEEN LOCATION
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Brgy. Maty, Miagao', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                                  Text('Last Tracked Location',
                                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
                                ],
                              ),
                            ),

                            // ICONS
                            Padding(
                              padding: const EdgeInsets.only(left: 100),
                              child: SizedBox(
                                width: 150,
                                child: Row(
                                  children: const [
                                    // IconButton(
                                    //   icon: isClicked
                                    //       ? Icon(Icons.star_outline_rounded)
                                    //       : Icon(Icons.star_rounded)
                                    //   onPressed: () {
                                    //     setState(() {
                                    //       isClicked = !isClicked
                                    //     });
                                    //   })
                                    IconButton(icon: Icon(Icons.star_outline_rounded), onPressed: null),
                                    IconButton(icon: Icon(Icons.outlined_flag_rounded), onPressed: null),
                                  ],

                                )
                              ),
                            ),
                            const IconButton(
                                icon: Icon(Icons.chevron_right_rounded, size: 40, color: Colors.black54,),
                                onPressed: null)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
          )
        ]
      )
    ),
    Container(
        child: Row(
            children: const [
              Text('Location'),
            ]
        )
    ),
    Container(
        child: Row(
            children: const [
              Text('Settings'),
            ]
        )
    )];
  bool _isExpanded = false;

  Widget _buildNavigationRail() {
    return NavigationRail(
      extended: _isExpanded,
      labelType: NavigationRailLabelType.none,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      leading: Container(
        width: 40,
        height: 40,
        color: Palette.indigo,
      ),
      trailing: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/2),
        child: IconButton(
          icon: _isExpanded == true ? const Icon(Icons.close_rounded):const Icon(Icons.menu_rounded),
          onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
        ),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.summarize_outlined),
          selectedIcon: Icon(Icons.summarize),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: Text('Location'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          if (MediaQuery.of(context).size.width >= 640)
            _buildNavigationRail(),
            Expanded(
              child: _destinations[_selectedIndex]
              ),
        ],
      ),
    );
  }
}