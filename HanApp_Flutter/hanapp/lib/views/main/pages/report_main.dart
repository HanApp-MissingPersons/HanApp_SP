import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import pages here
import 'package:hanapp/views/main/pages/report_pages/p1_classifier.dart';
import 'package:hanapp/views/main/pages/report_pages/p2_reportee_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p3_mp_info.dart';
import 'package:hanapp/views/main/pages/report_pages/p4_mp_description.dart';
import 'package:hanapp/views/main/pages/report_pages/p5_incident_details.dart';
import 'package:hanapp/views/main/pages/report_pages/p6_auth_confirm.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* REQUIREMENTS:
1. Need to have adaptive height to content for scrolling (currently hardcoded mediquery height) (find: NOTE1)

 */

class ReportMain extends StatefulWidget {
  final VoidCallback onReportSubmissionDone;
  const ReportMain({super.key, required this.onReportSubmissionDone});

  @override
  State<ReportMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<ReportMain> {
  // initialize controller for PageView
  final PageController _pageController = PageController(initialPage: 0);

  int _activePage = 0;

  //Create list holding all the pages
  // ignore: non_constant_identifier_names

  // dispose the controller, this is needed to avoid memory leak
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // List<Widget>? _ReportPages;
  @override
  void initState() {
    super.initState();
    getSharedPrefLen();
  }

  void getSharedPrefLen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().length > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[200], // Light grey background color
            content: Text(
              'You have an existing report. Please complete it first.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900]), // Dark indigo text color
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // set page default heights
  double p2height = 2300;
  double p3height = 2400;
  double p4height = 2400;
  double p5height = 1700;

  void setP2Height(double height) {
    setState(() {
      p2height = height;
    });
  }

  void setP3Height(double height) {
    setState(() {
      p3height = height;
    });
  }

  void setP4Height(double height) {
    setState(() {
      p4height = height;
    });
  }

  void setP5Height(double height) {
    setState(() {
      p5height = height;
    });
  }

  // functions to increase and return page heights
  void increaseP2Height() {
    setState(() {
      p2height = p2height + 450;
    });
  }

  void returnP2Height() {
    setState(() {
      p2height = p2height - 450;
    });
  }

  void defaultP2Height() {
    setState(() {
      p2height = 2300;
    });
  }

  void defaultP3Height() {
    setState(() {
      p3height = 2400;
    });
  }

  void defaultP4Height() {
    setState(() {
      p4height = 2400;
    });
  }

  void enhancedHeightP5() {
    setState(() {
      p5height = 1700;
    });
  }

  void increaseP3Height() {
    setState(() {
      p3height = p3height + 500;
    });
  }

  void returnP3Height() {
    setState(() {
      p3height = p3height - 500;
    });
  }

  void increaseP4Height() {
    setState(() {
      p4height = p4height + 300;
    });
  }

  void increaseP5Height() {
    setState(() {
      p5height = p5height + 100;
    });
  }

  void decreaseP5Height() {
    setState(() {
      p5height = p5height - 100;
    });
  }

  void returnP4Height() {
    setState(() {
      p4height = p4height - 300;
    });
  }

  // build the page view
  @override
  Widget build(BuildContext context) {
    print('BUILT');
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        child: ExpandablePageView(children: [
          const SizedBox(height: 600, child: Page1Classifier()), // okay
          // page 2
          SizedBox(
              height: p2height,
              child: Page2ReporteeDetails(
                addHeightParent: increaseP2Height,
                subtractHeightParent: returnP2Height,
                defaultHeightParent: defaultP2Height,
              )), // change image display height
          // page 3
          SizedBox(
              height: p3height,
              child: Page3MPDetails(
                addHeightParent: increaseP3Height,
                subtractHeightParent: returnP3Height,
                defaultHeightParent: defaultP3Height,
              )),
          // page 4
          SizedBox(
              height: p4height,
              child: Page4MPDesc(
                addHeightParent: increaseP4Height,
                subtractHeightParent: returnP4Height,
                defaultHeightParent: defaultP4Height,
              )), // change image display height
          // page 5
          SizedBox(
              height: p5height,
              child: Page5IncidentDetails(
                addHeightParent: increaseP5Height,
                subtractHeightParent: decreaseP5Height,
                enhancedHeightParent: enhancedHeightP5,
              )),
          // page 6
          Container(
            margin: const EdgeInsets.only(top: 40),
            height: 950,
            child: Page6AuthConfirm(
              onReportSubmissionDone: widget.onReportSubmissionDone,
            ),
          )
        ]),
      ),
    ); // Stack
  }
}
