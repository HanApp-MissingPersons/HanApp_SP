import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../login_view.dart';
import 'pages/home_main.dart';
import 'pages/report_main.dart';
import 'pages/nearby_main.dart';
import 'pages/companion_main.dart';
import 'pages/update_main.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: NavigationField(),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
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
                return Center(
                    child: Column(
                  children: [
                    Text('User: ${user?.email}'),
                    _widgetOptions.elementAt(_selectedIndex),
                    ElevatedButton(
                      onPressed: () {
                        // sign out the user
                        FirebaseAuth.instance.signOut();
                        // navigate to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ));
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.teal),
          BottomNavigationBarItem(
              icon: Icon(Icons.content_paste_search_rounded),
              label: 'Report',
              backgroundColor: Colors.teal),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Nearby',
              backgroundColor: Colors.teal),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Companion',
              backgroundColor: Colors.teal),
          BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_outlined),
              label: 'Updates',
              backgroundColor: Colors.teal),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
