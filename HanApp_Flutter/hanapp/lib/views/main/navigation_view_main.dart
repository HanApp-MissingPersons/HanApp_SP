import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/views/main/pages/profile_main.dart';
import '../../firebase_options.dart';
import '../login_view.dart';
import 'pages/home_main.dart';
import 'pages/report_main.dart';
import 'pages/nearby_main.dart';
import 'pages/companion_main.dart';
import 'pages/update_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationField extends StatefulWidget {
  const NavigationField({super.key});

  @override
  State<NavigationField> createState() => _NavigationFieldState();
}

class _NavigationFieldState extends State<NavigationField> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeMain(),
    ReportMain(),
    NearbyMain(),
    CompanionMain(),
    UpdateMain(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final Future<FirebaseApp> _firebaseInit;
  @override
  void initState() {
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _firebaseInit,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            switch (snapshot.connectionState) {
              // if there is no connection, return a text widget
              case ConnectionState.none:
                return const Center(child: Text('None oh no'));
              // if there is a connection, return a text widget
              case ConnectionState.waiting:
                return Center(
                  child: Column(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Text('Loading . . .'),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
              // if the connection is active, return a text widget
              case ConnectionState.active:
                return const Center(child: Text('App loading in...'));
              // if the connection is done, return a text widget
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                return Stack(
                  children: [
                    Positioned(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: _selectedIndex != 2
                              ? Center(
                                  child: SingleChildScrollView(
                                      child: _widgetOptions
                                          .elementAt(_selectedIndex)))
                              // else if maps, do not place in singlechildscroll view
                              : _widgetOptions.elementAt(_selectedIndex)),
                    ),
                    Positioned(
                      // position the user profile button
                      top: MediaQuery.of(context).size.height * .035,
                      right: MediaQuery.of(context).size.width * .035,
                      child: FloatingActionButton(
                        onPressed: () {
                          // sign out the user
                          // FirebaseAuth.instance.signOut();
                          // navigate to the login page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileMain(),
                            ),
                          );
                        },
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: const Icon(Icons.person_outlined),
                      ),
                    ),
                    // _widgetOptions.elementAt(_selectedIndex)
                  ],
                );
              // : const NearbyMain();
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF6B53FD),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              backgroundColor: Color(0xFF6B53FD)),
          BottomNavigationBarItem(
              icon: Icon(Icons.content_paste_search_outlined),
              label: 'Report',
              backgroundColor: Color(0xFF6B53FD)),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Nearby',
              backgroundColor: Color(0xFF6B53FD)),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Companion',
              backgroundColor: Color(0xFF6B53FD)),
          BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_outlined),
              label: 'Updates',
              backgroundColor: Color(0xFF6B53FD)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
