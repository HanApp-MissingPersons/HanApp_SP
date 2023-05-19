import 'package:flutter/material.dart';
import 'package:pnphanapp/main.dart';
import 'package:pnphanapp/views/main/pages/reports.dart';

class NavRailView extends StatefulWidget {
  const NavRailView({super.key});

  @override
  State<NavRailView> createState() => _NavRailViewState();
}

class _NavRailViewState extends State<NavRailView> {
  int _selectedIndex = 0;
  // final List<dynamic> _destinations = ['Home', 'Calendar', 'Email', reportsPNP];
  static const List<Widget> _destinations = <Widget>[
    reportsPNP(filterValue: ['Pending']), //first page
    reportsPNP(filterValue: ['Verified']), //second page
    // reportsVerfiedPNP(),
    reportsPNP(filterValue: [
      'Rejected'
    ]), // third page, removed "Incomplete Details" since it can be added as a reject reason
    reportsPNP(filterValue: ['Already Found']), // fourth page
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
        width: 50,
        height: 50,
        child: Image.asset('assets/images/hanappLogo.png'),
      ),
      trailing: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
        child: IconButton(
          icon: _isExpanded == true
              ? const Icon(Icons.close_rounded)
              : const Icon(Icons.menu_rounded),
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
          selectedIcon: Icon(Icons.summarize_rounded),
          label: Text('Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check_rounded),
          label: Text('Verified Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.delete_forever_outlined),
          selectedIcon: Icon(Icons.delete_forever_rounded),
          label: Text('Archived Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.verified_outlined),
          selectedIcon: Icon(Icons.verified_rounded),
          label: Text('Already Found'),
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
