import 'package:flutter/material.dart';
// import pages here
import 'package:hanapp/views/main/pages/report_pages/p1_classifier.dart';
import 'package:hanapp/views/main/pages/report_pages/p2_reportee_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p3_mp_info.dart';
import 'package:hanapp/views/main/pages/report_pages/p4_mp_description.dart';
import 'package:hanapp/views/main/pages/report_pages/p5_incident_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p6_auth_confirm.dart';

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
  final List<Widget> _ReportPages = [
    Page1Classifier(),
    Page2ReporteeDetails(),
    Page3MPDetails(),
    Page4MPDesc(),
    Page5IncidentDetails(),
    Page6AuthConfirm()
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
    return Stack(children: [
      Center(
        child: SingleChildScrollView(
          child: Container(
              // margin 1/8th of the screen height
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 8),
              // avoid RenderBox was not laid out: RenderConstrainedBox#f2f9d NEEDS-LAYOUT NEEDS-PAINT using Expanded

              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: PageView.builder(
                  // define height of the pageview
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
                  ) // Expanded
              ),
        ), // SizedBox
      ) // Positioned
    ]); // Stack
  }
}
