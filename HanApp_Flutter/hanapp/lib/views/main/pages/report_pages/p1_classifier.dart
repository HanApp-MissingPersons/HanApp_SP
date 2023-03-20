import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page1Classifier extends StatefulWidget {
  const Page1Classifier({super.key});

  @override
  State<Page1Classifier> createState() => _Page1ClassifierState();
}

class _Page1ClassifierState extends State<Page1Classifier> {
  // boolean variables for checkboxes
  bool? _isVictimNaturalCalamity;
  bool? _isMinor;
  bool? _isMissing24Hours;
  bool? _isVictimCrime;

  late SharedPreferences _prefs;

  Future<void> getUserChoices() async {
    // state management using shared preferences
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _isVictimNaturalCalamity =
          _prefs.getBool('isVictimNaturalCalamity') ?? false;
      _isMinor = _prefs.getBool('isMinor') ?? false;
      _isMissing24Hours = _prefs.getBool('isMissing24Hours') ?? false;
      _isVictimCrime = _prefs.getBool('isVictimCrime') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserChoices();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   getUserChoices();
  // }

  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

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
    return _isVictimNaturalCalamity != null
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
                  const SizedBox(height: _rowPadding),
                  Row(
                    children: [
                      Checkbox(
                        value: _isVictimNaturalCalamity,
                        onChanged: (bool? value) {
                          setState(() {
                            _isVictimNaturalCalamity = value;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isVictimNaturalCalamity', value!);
                        },
                      ), // Checkbox for Natural Calamity
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVictimNaturalCalamity =
                                !_isVictimNaturalCalamity!;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isVictimNaturalCalamity',
                              _isVictimNaturalCalamity!);
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
                    children: [
                      Checkbox(
                        value: _isMinor,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMinor = value;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isMinor', value!);
                        },
                      ), // Checkbox for Natural Calamity
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMinor = !_isMinor!;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isMinor', _isMinor!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            _minorText,
                          ),
                        ),
                      ), // end of GestureDetector, // end of text container
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
                            _isMissing24Hours = value;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isMissing24Hours', value!);
                        },
                      ), // Checkbox for Natural Calamity
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMissing24Hours = !_isMissing24Hours!;
                          });
                          // save the value of the checkbox

                          _prefs.setBool(
                              'isMissing24Hours', _isMissing24Hours!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            _missing24HoursText,
                          ),
                        ),
                      ), // end of GestureDetector, // end of text container
                    ],
                  ),
                  const SizedBox(height: _rowPadding),
                  Row(
                    children: [
                      Checkbox(
                        value: _isVictimCrime,
                        onChanged: (bool? value) {
                          setState(() {
                            _isVictimCrime = value;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isVictimCrime', value!);
                        },
                      ), // Checkbox for Natural Calamity
                      // GestureDetector that checks the checkbox when the text is tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVictimCrime = !_isVictimCrime!;
                          });
                          // save the value of the checkbox

                          _prefs.setBool('isVictimCrime', _isVictimCrime!);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: const Text(
                            _victimCrimeText,
                          ),
                        ),
                      ), // end of GestureDetector, // end of text container
                    ],
                  ),
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
          ])
        :
        // Circular loading icon
        const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ));
  } // end of build
}
