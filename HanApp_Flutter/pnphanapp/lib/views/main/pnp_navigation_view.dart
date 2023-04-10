import 'package:flutter/material.dart';
import 'package:pnphanapp/main.dart';
import 'package:pnphanapp/views/main/pages/reports.dart';
import 'package:pnphanapp/views/main/pages/tempPage1.dart';
import 'package:pnphanapp/views/main/pages/tempPage2.dart';

class NavRailView extends StatefulWidget {
  const NavRailView({super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  int _selectedIndex = 0;
  // final List<dynamic> _destinations = ['Home', 'Calendar', 'Email', reportsPNP];
  static const List<Widget> _destinations = <Widget>[
    reportsPNP(),
    tempPage1(),
    tempPage2(),
  ];
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
      trailing: IconButton(
        icon: _isExpanded == true
            ? const Icon(Icons.close_rounded)
            : const Icon(Icons.menu_rounded),
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: Text('Temp Page 1'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.email_outlined),
          selectedIcon: Icon(Icons.email),
          label: Text('Temp Page 2'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          _buildNavigationRail(),
          Expanded(
            child: Center(
              child: _destinations[_selectedIndex],
            ),
          )
        ],
      ),
    );
  }
}
