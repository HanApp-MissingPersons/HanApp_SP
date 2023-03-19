import 'package:flutter/material.dart';

class Page1Classifier extends StatefulWidget {
  const Page1Classifier({super.key});

  @override
  State<Page1Classifier> createState() => _Page1ClassifierState();
}

class _Page1ClassifierState extends State<Page1Classifier> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

  // boolean variables for checkboxes
  bool _isVictimNaturalCalamity = false;
  bool _isMinor = false;
  bool _isMissing24Hours = false;
  bool _isVictimCrime = false;

  // row padding
  static const double _rowPadding = 20;

  // classifier texts
  static const String _naturalCalamityText =
      'Is the absent/missing person a victim of a natural calamity (typhoons, earthquakes, landslides), or human-induced disasters or accidents?';
  static const String _minorText =
      'Is the absent/missing person a minor (under the age of 18)?';
  static const String _missing24HoursText =
      'Has the absent/missing person not been located for more than 24 hours since their perceived disappearance?';
  static const String _victimCrimeText =
      'Is the absent/missing person believed to be a victim of violence and crimes (including but not limited to: kidnapping, abduction, enforced disappearance, human trafficking)';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Checkboxes for classifiers
      Positioned(
        top: 100,
        left: 20,
        child: Column(
          // // set all the checkboxes to be on the left side of the screen
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text
            const Text(
              'Page 1: Classifiers',
              style: optionStyle,
            ), // Page 1 Text
            // add padding between rows
            const SizedBox(height: _rowPadding),
            Row(
              children: [
                Checkbox(
                  value: _isVictimNaturalCalamity,
                  onChanged: (bool? value) {
                    setState(() {
                      _isVictimNaturalCalamity = value!;
                    });
                  },
                ), // Checkbox for Natural Calamity
                // container for text (to force a word wrap)
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width - 100,
                  child: const Text(
                    _naturalCalamityText,
                    // style: optionStyle,
                  ),
                ), // end of text container
              ],
            ),
            // add padding between rows
            const SizedBox(height: _rowPadding),
            Row(
              // add space between checkbox rows
              children: [
                Checkbox(
                  value: _isMinor,
                  onChanged: (bool? value) {
                    setState(() {
                      _isMinor = value!;
                    });
                  },
                ),
                // container for text (to force a word wrap)
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width - 100,
                  child: const Text(
                    _minorText,
                  ),
                ), // end of text container
              ],
            ),
            // add padding between rows
            const SizedBox(height: _rowPadding),
            Row(
              children: [
                Checkbox(
                  value: _isMissing24Hours,
                  onChanged: (bool? value) {
                    setState(() {
                      _isMissing24Hours = value!;
                    });
                  },
                ),
                // container for text (to force a word wrap)
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width - 100,
                  child: const Text(
                    _missing24HoursText,
                  ),
                ), // end of text container
              ],
            ), // add padding between rows
            const SizedBox(height: _rowPadding),
            Row(
              children: [
                Checkbox(
                  value: _isVictimCrime,
                  onChanged: (bool? value) {
                    setState(() {
                      _isVictimCrime = value!;
                    });
                  },
                ),
                // container for text (to force a word wrap)
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width - 100,
                  child: const Text(
                    _victimCrimeText,
                  ),
                ), // end of text container
              ],
            ), // end of Row for Victim of Crime
            // add padding between rows
            const SizedBox(height: _rowPadding),
            // info/instruction text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info),
                SizedBox(width: 5),
                Text(
                  '''Please check all that apply. Swipe left to continue.''',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ), // end of Row for info text
          ], // end of children for Column
        ), // end of Column
      ), // end of Positioned
    ]); // end of Stack;
  } // end of build
}
