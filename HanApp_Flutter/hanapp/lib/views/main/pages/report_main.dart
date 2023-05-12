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
  }
  double p3height = 2400;
  double p4height = 2400;

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
              const SizedBox(height: 2250,child: Page2ReporteeDetails()), // change image display height
              SizedBox(height: p3height, child: Page3MPDetails(addHeightParent: increaseP3Height, subtractHeightParent: returnP3Height,)),
              SizedBox(height: p4height, child: Page4MPDesc(addHeightParent: increaseP4Height, subtractHeightParent: returnP4Height,)), // change image display height
              const SizedBox(height: 1600, child: Page5IncidentDetails()),
              Container(margin: const EdgeInsets.only(top: 40), height: 950,
                child: Page6AuthConfirm(
                  onReportSubmissionDone: widget.onReportSubmissionDone,
                ),
              )
            ]),
          ),
        ); // Stack
  }
}
