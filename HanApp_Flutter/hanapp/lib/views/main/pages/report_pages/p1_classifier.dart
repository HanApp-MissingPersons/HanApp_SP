import 'package:flutter/material.dart';
import 'package:hanapp/main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'p3_mp_info.dart';

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

  // ageFromP3
  int? ageFromMPBirthDate;
  // hoursSinceLastSeenFromP5
  int? hoursSinceLastSeenFromP5;

  /* FORMATTING STUFF */
  // row padding
  static const _verticalPadding = SizedBox(height: 15);
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87);
  /* END OF FORMATTING STUFF */

  /* SHARED PREFERENCE STUFF */
  // Future builder for shared preferences, initialize as false
  Future<void> getUserChoices() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // set the state of the checkboxes
      isVictimNaturalCalamity =
          _prefs.getBool('p1_isVictimNaturalCalamity') ?? false;

      // isMinor depends on p3_mp_age
      if (_prefs.getString('p3_mp_age') == null ||
          _prefs.getString('p3_mp_age') == '') {
        // isMinor = false;
        isMinor = _prefs.getBool('p1_isMinor') ?? false;
      } else {
        // if p3_mp_age is not null, check if it is less than 18
        ageFromMPBirthDate = int.parse(_prefs.getString('p3_mp_age')!);
        if (ageFromMPBirthDate! < 18) {
          isMinor = true;
        } else {
          isMinor = false;
        }
        _prefs.setBool('p1_isMinor', isMinor!);
      }

      // isMissing24Hours = _prefs.getBool('p1_isMissing24Hours') ?? false;
      // isMissing24Hours depends on p5_totalHoursSinceLastSeen
      if (_prefs.getString('p5_totalHoursSinceLastSeen') == null ||
          _prefs.getString('p5_totalHoursSinceLastSeen') == '') {
        isMissing24Hours = _prefs.getBool('p1_isMissing24Hours') ?? false;
      } else {
        // if p5_totalHoursSinceLastSeen is not null, check if it is less than 24
        hoursSinceLastSeenFromP5 =
            int.parse(_prefs.getString('p5_totalHoursSinceLastSeen')!);
        if (hoursSinceLastSeenFromP5! >= 24) {
          isMissing24Hours = true;
        } else {
          isMissing24Hours = false;
        }
        _prefs.setBool('p1_isMissing24Hours', isMissing24Hours!);
      }

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
      //'Is the absent/missing person a victim of a natural calamity (typhoons, earthquakes, landslides), or human-induced disasters or accidents?';
      'The person is missing due to a natural calamity/disaster (typhoons, earthquakes, landslides), or accident';
  static const String minorText =
      // 'Is the absent/missing person a minor (under the age of 18)?';
      'The person is still a minor\n(under the age of 18)';
  static const String missing24HoursText =
      'The person has been missing for more than 24 hours since they were last seen';
  static const String victimCrimeText =
      'The person is a victim of a crime such as but not limited to kidnapping, abduction, or human trafficking';

  @override
  Widget build(BuildContext context) {
    return isVictimNaturalCalamity != null
        ? Stack(children: [
            // Checkboxes for classifiers
            Positioned(
              top: MediaQuery.of(context).size.height / 8,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      'Page 1 of 6: Classifiers',
                      style: optionStyle,
                    ),
                  ), // Page 1 Text
                  _verticalPadding,
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 80,
                          child: const Text(
                            '''Please check all statements that apply regarding the status of the absent/missing person''',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _verticalPadding,
                  // add padding between rows
                  _verticalPadding,
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          // value: _isVictimNaturalCalamity,
                          // retrieve value of the checkbox from shared preferences
                          value: isVictimNaturalCalamity,
                          activeColor: Palette.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),

                          onChanged: (bool? value) {
                            setState(() {
                              isVictimNaturalCalamity = value;
                            });
                            // save the value of the checkbox
                            _prefs.setBool(
                                'p1_isVictimNaturalCalamity', value!);
                          },
                        ),
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
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          activeColor: Palette.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          value: isMinor,
                          onChanged: ageFromMPBirthDate != null
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    isMinor = value;
                                  });
                                  // save the value of the checkbox
                                  _prefs.setBool('p1_isMinor', value!);
                                },
                        ),
                      ),
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        // disable tap if ageFromMPBirthDate is not null && ageFromMPBirthDate >= 18
                        onTap: ageFromMPBirthDate != null
                            ? null
                            : () {
                                setState(() {
                                  isMinor = !isMinor!;
                                });
                                _prefs.setBool('p1_isMinor', isMinor!);
                              },
                        // onTap: () {
                        //   setState(() {
                        //     isMinor = !isMinor!;
                        //   });
                        //   _prefs.setBool('p1_isMinor', isMinor!);
                        // },
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
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          activeColor: Palette.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          value: isMissing24Hours,
                          onChanged: hoursSinceLastSeenFromP5 != null
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    isMissing24Hours = value;
                                  });
                                  // save the value of the checkbox
                                  _prefs.setBool('p1_isMissing24Hours', value!);
                                },
                          // (bool? value) {
                          // setState(() {
                          //   isMissing24Hours = value;
                          // });
                          // // save the value of the checkbox
                          // _prefs.setBool('p1_isMissing24Hours', value!);
                          // },
                        ),
                      ),
                      GestureDetector(
                        onTap: hoursSinceLastSeenFromP5 != null
                            ? null
                            : () {
                                setState(() {
                                  isMissing24Hours = !isMissing24Hours!;
                                });
                                _prefs.setBool(
                                    'p1_isMissing24Hours', isMissing24Hours!);
                              },
                        // onTap: () {
                        //   setState(() {
                        //     isMissing24Hours = !isMissing24Hours!;
                        //   });
                        //   _prefs.setBool(
                        //       'p1_isMissing24Hours', isMissing24Hours!);
                        // },
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
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          activeColor: Palette.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          value: isVictimCrime,
                          onChanged: (bool? value) {
                            setState(() {
                              isVictimCrime = value;
                            });
                            // save the value of the checkbox
                            _prefs.setBool('p1_isVictimCrime', value!);
                          },
                        ),
                      ),
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isVictimCrime = !isVictimCrime!;
                          });
                          _prefs.setBool('p1_isVictimCrime', isVictimCrime!);
                        },
                        child: SizedBox(
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
                  //info/instruction
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Lottie.network(
                          "https://assets8.lottiefiles.com/packages/lf20_xpxbhrm4.json",
                          animate: true,
                          width: MediaQuery.of(context).size.width*0.15),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          '\nEnd of Classifiers Form \nSwipe left to continue.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Text(
                  //   '''End of Classifiers Form. Swipe left to continue.''',
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.black54,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       left: MediaQuery.of(context).size.width / 6),
                  //   child: TextButton(
                  //     onPressed: () async {
                  //       final prefs = await SharedPreferences.getInstance();
                  //       print(prefs.getKeys());
                  //       print(prefs.get('p1_isMinor'));
                  //       //print p3_mp_age from shared preferences if not null
                  //       if (prefs.get('p3_mp_age') != null) {
                  //         print(prefs.get('p3_mp_age'));
                  //       } else {
                  //         print("No age supplied yet");
                  //       }
                  //       //print p5_totalHoursSinceLastSeen from shared preferences if not null
                  //       if (prefs.get('p5_totalHoursSinceLastSeen') != null) {
                  //         print(prefs.get('p5_totalHoursSinceLastSeen'));
                  //       } else {
                  //         print("No hours supplied yet");
                  //       }
                  //     },
                  //     child: const Text('Print Shared Preferences'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ])
        :
        // Circular loading icon
        const Center(
            child: SpinKitCubeGrid(
              color: Palette.indigo,
              size: 40.0,
            ),
          );
  }
}
