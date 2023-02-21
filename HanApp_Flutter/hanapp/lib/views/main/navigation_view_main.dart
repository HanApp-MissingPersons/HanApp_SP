import 'package:flutter/material.dart';

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
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle =
  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Report',
      style: optionStyle,
    ),
    Text(
      'Index 2: Nearby',
      style: optionStyle,
    ),
    Text(
      'Index 3: Companion',
      style: optionStyle,
    ),
    Text(
      'Index 4: Updates',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.teal
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_paste_search_rounded),
            label: 'Report',
              backgroundColor: Colors.teal
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Nearby',
              backgroundColor: Colors.teal
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              label: 'Companion',
              backgroundColor: Colors.teal
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_outlined),
            label: 'Updates',
              backgroundColor: Colors.teal
          ),
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
