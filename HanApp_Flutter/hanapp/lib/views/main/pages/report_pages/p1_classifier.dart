import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* LACKING:
1. Need to automatically add padding between rows (instead of hardcoding the padding in between rows)
2. Need backend to store the values of the checkboxes
3. Need state management to store the values of the checkboxes
*/

class Page1Classifier extends StatefulWidget {
  const Page1Classifier({super.key});

  @override
  State<Page1Classifier> createState() => _Page1ClassifierState();
}

// shared preferences for state management
late SharedPreferences _prefs;
void clearPrefs() {
  _prefs.clear();
}

class _Page1ClassifierState extends State<Page1Classifier> {
  // local boolean variables for checkboxes
  bool? isVictimNaturalCalamity;
  bool? isMinor;
  bool? isMissing24Hours;
  bool? isVictimCrime;

  /* FORMATTING STUFF */
  // row padding
  static const _verticalPadding = SizedBox(height: 10);
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  /* END OF FORMATTING STUFF */

  /* SHARED PREFERENCE STUFF */
  // Future builder for shared preferences, initialize as false
  Future<void> getUserChoices() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // set the state of the checkboxes
      isVictimNaturalCalamity =
          _prefs.getBool('p1_isVictimNaturalCalamity') ?? false;
      isMinor = _prefs.getBool('p1_isMinor') ?? false;
      isMissing24Hours = _prefs.getBool('p1_isMissing24Hours') ?? false;
      isVictimCrime = _prefs.getBool('p1_isVictimCrime') ?? false;
    });
  }

  // initstate for shared preferences
  @override
  void initState() {
    super.initState();
    getUserChoices();
  }
  /* END OF SHARED PREFERENCE STUFF */

  // classifier texts
  static const String naturalCalamityText =
      'Is the absent/missing person a victim of a natural calamity (typhoons, earthquakes, landslides), or human-induced disasters or accidents?';
  static const String minorText =
      'Is the absent/missing person a minor (under the age of 18)?';
  static const String missing24HoursText =
      'Has the absent/missing person not been located for more than 24 hours since their perceived disappearance?';
  static const String victimCrimeText =
      'Is the absent/missing person believed to be a victim of violence and crimes (including but not limited to: kidnapping, abduction, enforced disappearance, human trafficking)';

  @override
  Widget build(BuildContext context) {
    return isVictimNaturalCalamity != null
        ? Stack(children: [
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
                  _verticalPadding,
                  Row(
                    children: [
                      Checkbox(
                        // value: _isVictimNaturalCalamity,
                        // retrieve value of the checkbox from shared preferences
                        value: isVictimNaturalCalamity,

                        onChanged: (bool? value) {
                          setState(() {
                            isVictimNaturalCalamity = value;
                          });
                          // save the value of the checkbox
                          _prefs.setBool('p1_isVictimNaturalCalamity', value!);
                        },
                      ), // Checkbox for Natural Calamity
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isVictimNaturalCalamity = !isVictimNaturalCalamity!;
                          });
                          _prefs.setBool('p1_isVictimNaturalCalamity',
                              isVictimNaturalCalamity!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            naturalCalamityText,
                          ),
                        ),
                      ), // end of GestureDetector, // end of text container
                    ],
                  ),
                  // add padding between rows
                  _verticalPadding,
                  Row(
                    // add space between checkbox rows
                    children: [
                      Checkbox(
                        value: isMinor,
                        onChanged: (bool? value) {
                          setState(() {
                            isMinor = value;
                          });
                          // save the value of the checkbox
                          _prefs.setBool('p1_isMinor', value!);
                          ;
                        },
                      ),
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isMinor = !isMinor!;
                          });
                          _prefs.setBool('p1_isMinor', isMinor!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            minorText,
                          ),
                        ),
                      ), // end of GestureDetector
                    ],
                  ),
                  // add padding between rows
                  _verticalPadding,
                  Row(
                    children: [
                      Checkbox(
                        value: isMissing24Hours,
                        onChanged: (bool? value) {
                          setState(() {
                            isMissing24Hours = value;
                          });
                          // save the value of the checkbox
                          _prefs.setBool('p1_isMissing24Hours', value!);
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isMissing24Hours = !isMissing24Hours!;
                          });
                          _prefs.setBool(
                              'p1_isMissing24Hours', isMissing24Hours!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            missing24HoursText,
                          ),
                        ),
                      ), // end of GestureDetector, // end of text container
                    ],
                  ), // add padding between rows
                  _verticalPadding,
                  Row(
                    children: [
                      Checkbox(
                        value: isVictimCrime,
                        onChanged: (bool? value) {
                          setState(() {
                            isVictimCrime = value;
                          });
                          // save the value of the checkbox
                          _prefs.setBool('p1_isVictimCrime', value!);
                        },
                      ),
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isVictimCrime = !isVictimCrime!;
                          });
                          _prefs.setBool('p1_isVictimCrime', isVictimCrime!);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            victimCrimeText,
                          ),
                        ),
                      ), // end of GestureDetector
                    ],
                  ), // end of Row for Victim of Crime
                  // add padding between rows
                  _verticalPadding,
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
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      print(prefs.getKeys());
                    },
                    child: const Text('Print Shared Preferences'),
                  ),
                ],
              ),
            ),
          ])
        :
        // Circular loading icon
        const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ));
  }
}
