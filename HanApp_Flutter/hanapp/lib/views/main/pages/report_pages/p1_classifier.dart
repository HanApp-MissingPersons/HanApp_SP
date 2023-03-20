import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* LACKING:
1. Need to add padding between rows (instead of hardcoding the padding in between rows)
2. Need backend to store the values of the checkboxes
3. Need state management to store the values of the checkboxes

*/

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

  // state management using shared preferences
  final _prefs = SharedPreferences.getInstance();

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
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Page 1 of 6: Classifiers',
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
                    // save the value of the checkbox
                    _prefs.then((prefs) {
                      prefs.setBool('isVictimNaturalCalamity', value!);
                    });
                  },
                ), // Checkbox for Natural Calamity
                // GestureDetector that checks the checkbox when the text is tapped
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVictimNaturalCalamity = !_isVictimNaturalCalamity;
                    });
                    // save the value of the checkbox
                    _prefs.then((prefs) {
                      prefs.setBool(
                          'isVictimNaturalCalamity', !_isVictimNaturalCalamity);
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: const Text(
                      _naturalCalamityText,
                    ),
                  ),
                ), // end of GestureDetector, // end of text container
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
                    // save the value of the checkbox
                    _prefs.then((prefs) {
                      prefs.setBool('isMinor', value!);
                    });
                  },
                ),
                // GestureDetector that checks the checkbox when the text is tapped
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMinor = !_isMinor;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: const Text(
                      _minorText,
                    ),
                  ),
                ), // end of GestureDetector
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
                    // save the value of the checkbox
                    _prefs.then((prefs) {
                      prefs.setBool('isMissing24Hours', value!);
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMissing24Hours = !_isMissing24Hours;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: const Text(
                      _missing24HoursText,
                    ),
                  ),
                ), // end of GestureDetector, // end of text container
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
                    // save the value of the checkbox
                    _prefs.then((prefs) {
                      prefs.setBool('isVictimCrime', value!);
                    });
                  },
                ),
                // GestureDetector that checks the checkbox when the text is tapped
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVictimCrime = !_isVictimCrime;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: const Text(
                      _victimCrimeText,
                    ),
                  ),
                ), // end of GestureDetector
              ],
            ), // end of Row for Victim of Crime
            // add padding between rows
            const SizedBox(height: _rowPadding),
            // info/instruction
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
