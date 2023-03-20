import 'package:flutter/material.dart';
// import pages here
import 'package:hanapp/views/main/pages/report_pages/p1_classifier.dart';
import 'package:hanapp/views/main/pages/report_pages/p2_reportee_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p3_mp_info.dart';
import 'package:hanapp/views/main/pages/report_pages/p4_mp_description.dart';
import 'package:hanapp/views/main/pages/report_pages/p5_incident_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p6_auth_confirm.dart';

/* REQUIREMENTS:
1. Need to have adaptive height to content for scrolling (currently hardcoded mediquery height)

 */

class ReportMain extends StatefulWidget {
  const ReportMain({super.key});

  @override
  State<ReportMain> createState() => _ReportMainState();
}

// ////////// PageView WITHOUT Indicator
// class _ReportMainState extends State<ReportMain> {
//   // optionStyle is for the text, we can remove this when actualy doing menu contents
//   static const TextStyle optionStyle = TextStyle(
//       fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

//   // initialize controller for PageView
//   final PageController _pageController = PageController(initialPage: 0);

//   // int _activePage = 0;

//   // //Create list holding all the pages
//   // final List<Widget> _ReportPages = [Page1Classifier()];

//   // dispose the controller, this is needed to avoid memory leak
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // build the page view
//   @override
//   Widget build(BuildContext context) {
//     //use stack and sizedbox to make the pageview full screen
//     return Stack(children: [
//       Positioned(
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: PageView(
//             controller: _pageController,
//             onPageChanged: (int page) {
//               setState(() {
//                 // _activePage = page;
//               });
//             },
//             // ignore: prefer_const_literals_to_create_immutables
//             children: [
//               // set children to be centered
//               const Center(child: Page1Classifier()),
//               const Center(child: Page2ReporteeDetails()),
//               const Center(child: Page3MPDetails()),
//               const Center(child: Page4MPDesc()),
//               const Center(child: Page5IncidentDetails()),
//               const Center(child: Page6AuthConfirm()),
//             ],
//           ),
//         ),
//       )
//     ]);
//   }
// }
// ///////// END PageView WITHOUT Indicator

////// PageView with Bottom Incidator
class _ReportMainState extends State<ReportMain> {
  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

  // initialize controller for PageView
  final PageController _pageController = PageController(initialPage: 0);

  int _activePage = 0;

  //Create list holding all the pages
  // ignore: non_constant_identifier_names
  final List<Widget> _ReportPages = [
    const Page1Classifier(),
    const Page2ReporteeDetails(),
    const Page3MPDetails(),
    const Page4MPDesc(),
    const Page5IncidentDetails(),
    const Page6AuthConfirm()
  ];

  // dispose the controller, this is needed to avoid memory leak
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // build the page view
  @override
  Widget build(BuildContext context) {
    //use stack and sizedbox to make the pageview full screen
    return Stack(
      children: [
        // Stack for PageView
        Positioned(
          child: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 8),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *
                    3, // NEED TO CHANGE THIS
                child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _activePage = index;
                      });
                    }, // onPageChanged
                    itemCount: _ReportPages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _ReportPages[index];
                    } // itemBuilder
                    ) // Container
                ),
          ), // SizedBox
        ), // Center for Pageview

        // Bottom Indicator
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: Container(
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                    _ReportPages.length,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: InkWell(
                            onTap: () {
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeIn);
                            },
                            child: CircleAvatar(
                              radius: 5,
                              // check if a dot is connected to the current page
                              // if true, give it a different color
                              backgroundColor: _activePage == index
                                  ? Colors.indigo
                                  : Colors.white30,
                            ), // CircleAvatar
                          ), // InkWell
                        )), // Padding
              ), // Row
            ) // Container
            ), // Positioned

        // Next Page Button
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 0, right: 20),
            child: FloatingActionButton(
              onPressed: () {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn);
              },
              // removes Icon circle if on first page
              backgroundColor: _activePage == _ReportPages.length - 1
                  ? Colors.transparent
                  : Colors.indigo,
              // removes icon shadow if on first page
              elevation: _activePage == _ReportPages.length - 1 ? 0 : 6,
              // removes button if on first page
              child: _activePage == _ReportPages.length - 1
                  ? null
                  : const Icon(Icons.arrow_forward),
            ), // FloatingActionButton
          ), // Container
        ), // Positioned for Next Page Button

        // Previous Page Button
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 0, left: 20),
            child: FloatingActionButton(
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn);
              },
              // removes Icon circle if on first page
              backgroundColor:
                  _activePage == 0 ? Colors.transparent : Colors.indigo,
              // removes icon shadow if on first page
              elevation: _activePage == 0 ? 0 : 6,
              // removes button if on first page
              child: _activePage == 0 ? null : const Icon(Icons.arrow_back),

              // removes shadow if on first page
            ), // FloatingActionButton
          ), // Container
        ), // Positioned for Previous Page Button
      ], // children for Stack
    ); // Stack
  }
}
