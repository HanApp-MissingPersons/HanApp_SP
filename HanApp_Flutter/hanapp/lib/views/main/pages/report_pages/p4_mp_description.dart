/* 
1. Remove "Other Photo"
2. Implement Shared Pref
3. Naming convention for variables (ex: p4_mp_desc, p4_mp_recent_photo)
4. Only three photos: Most Recent Photo, Dental Record, Finger Print Record (last two optional)
*/

/* IMPORTS */
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

/* SHARED PREFERENCE */
late SharedPreferences _prefs;
void clearPrefs() {
  _prefs.clear();
}

/* PAGE 4 */
class Page4MPDesc extends StatefulWidget {
  final VoidCallback addHeightParent;
  final VoidCallback subtractHeightParent;
  const Page4MPDesc(
      {super.key,
      required this.addHeightParent,
      required this.subtractHeightParent});

  @override
  State<Page4MPDesc> createState() => _Page4MPDescState();
}

/* PAGE 4 STATE */
class _Page4MPDescState extends State<Page4MPDesc> {
  /* FORMATTING */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87);
  static const _verticalPadding = SizedBox(height: 10);

  static const TextStyle headingStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54);

  String userUID = FirebaseAuth.instance.currentUser!.uid;
  Reference reportRef = FirebaseStorage.instance.ref().child('Reports');
  /* VARIABLES */
  // MP Appearance
  String mpImageURL = '';
  String? mp_scars;
  String? mp_marks;
  String? mp_tattoos;
  String? mp_hair_color;
  bool? mp_hair_color_natural;
  String? mp_eye_color;
  bool? mp_eye_color_natural;
  String? mp_prosthetics;
  String? mp_birth_defects;
  String? last_clothing;
  // MP medical details
  String? mp_height_feet;
  String? mp_height_inches;
  String? mp_weight;
  String? mp_blood_typeValue;
  String? mp_medications;
  // MP socmed details
  String? mp_facebook;
  String? mp_twitter;
  String? mp_instagram;
  String? mp_socmed_other_platform;
  String? mp_socmed_other_username;
  // Photos
  Uint8List? mp_recent_photo;
  Uint8List? mp_dental_record_photo;
  Uint8List? mp_finger_print_record_photo;
  // Boolean variables for checkboxes
  bool? mp_dental_available = false;
  bool? mp_fingerprints_available = false;

  // all controlers for text fields
  late final TextEditingController _mp_scars = TextEditingController();
  late final TextEditingController _mp_marks = TextEditingController();
  late final TextEditingController _mp_tattoos = TextEditingController();
  late final TextEditingController _mp_hair_color = TextEditingController();
  late final TextEditingController _mp_eye_color = TextEditingController();
  late final TextEditingController _mp_prosthetics = TextEditingController();
  late final TextEditingController _mp_birth_defects = TextEditingController();
  late final TextEditingController _mp_last_clothing = TextEditingController();
  late final TextEditingController _mp_height_feet = TextEditingController();
  late final TextEditingController _mp_height_inches = TextEditingController();
  late final TextEditingController _mp_weight = TextEditingController();
  late final TextEditingController _mp_blood_type = TextEditingController();
  late final TextEditingController _mp_medications = TextEditingController();
  // socmed details
  late final TextEditingController _mp_facebook = TextEditingController();
  late final TextEditingController _mp_twitter = TextEditingController();
  late final TextEditingController _mp_instagram = TextEditingController();
  late final TextEditingController _mp_socmed_other_platform =
      TextEditingController();
  late final TextEditingController _mp_socmed_other_username =
      TextEditingController();
  // bool _mp_hair_color_natural = false;
  // bool _mp_eye_color_natural = false;

  // dispose all controllers
  @override
  void dispose() {
    _mp_scars.dispose();
    _mp_marks.dispose();
    _mp_tattoos.dispose();
    _mp_hair_color.dispose();
    _mp_eye_color.dispose();
    _mp_prosthetics.dispose();
    _mp_birth_defects.dispose();
    _mp_last_clothing.dispose();
    _mp_height_feet.dispose();
    _mp_height_inches.dispose();
    _mp_weight.dispose();
    _mp_blood_type.dispose();
    _mp_medications.dispose();
    _mp_facebook.dispose();
    _mp_twitter.dispose();
    _mp_instagram.dispose();
    _mp_socmed_other_platform.dispose();
    _mp_socmed_other_username.dispose();
    super.dispose();
  }

  /* INITIALIZE VARIABLES FOR SHARED PREFERENCE */
  // get text and boolean values from shared preferences
  // Future<void> _getUserChoices() async {
  //   _prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     mp_scars = _prefs.getString('p4_mp_scars') ?? '';
  //     mp_marks = _prefs.getString('p4_mp_marks') ?? '';
  //     mp_tattoos = _prefs.getString('p4_mp_tattoos') ?? '';
  //     mp_hair_color = _prefs.getString('p4_mp_hair_color') ?? '';
  //     mp_hair_color_natural =
  //         _prefs.getBool('p4_mp_hair_color_natural') ?? false;
  //     mp_eye_color = _prefs.getString('p4_mp_eye_color') ?? '';
  //     mp_eye_color_natural = _prefs.getBool('p4_mp_eye_color_natural') ?? false;
  //     mp_prosthetics = _prefs.getString('p4_mp_prosthetics') ?? '';
  //     mp_birth_defects = _prefs.getString('p4_mp_birth_defects') ?? '';
  //     last_clothing = _prefs.getString('p4_last_clothing') ?? '';
  //     mp_height_feet = _prefs.getString('p4_mp_height_feet') ?? '';
  //     mp_height_inches = _prefs.getString('p4_mp_height_inches') ?? '';
  //     mp_weight = _prefs.getString('p4_mp_weight') ?? '';
  //     mp_blood_type = _prefs.getString('p4_mp_blood_type') ?? '';
  //     mp_medications = _prefs.getString('p4_mp_medications') ?? '';
  //     mp_facebook = _prefs.getString('p4_mp_facebook') ?? '';
  //     mp_twitter = _prefs.getString('p4_mp_twitter') ?? '';
  //     mp_instagram = _prefs.getString('p4_mp_instagram') ?? '';
  //     mp_socmed_other_platform =
  //         _prefs.getString('p4_mp_socmed_other_platform') ?? '';
  //     mp_socmed_other_username =
  //         _prefs.getString('p4_mp_socmed_other_username') ?? '';
  //   });
  // }

  late String reportCount;
  retrieveUserData() async {
    _prefs = await SharedPreferences.getInstance();
    await FirebaseDatabase.instance
        .ref("Main Users")
        .child(userUID)
        .get()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> userDict = snapshot.value as Map<dynamic, dynamic>;
      print('${userDict['firstName']} ${userDict['lastName']}');
      reportCount = userDict['reportCount'];
    });
    print('[REPORT COUNT] report count: $reportCount');
  }

  // save images to shared preference
  Future<void> _saveImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mp_recent_photo != null) {
      String mpRecentPhotoString = base64Encode(mp_recent_photo!);
      prefs.setString('p4_mp_recent_photo', mpRecentPhotoString);
    }
    if (mp_dental_record_photo != null) {
      String mpDentalRecordPhotoString = base64Encode(mp_dental_record_photo!);
      prefs.setString('p4_mp_dental_record_photo', mpDentalRecordPhotoString);
    }
    if (mp_finger_print_record_photo != null) {
      String mpFingerPrintRecordPhotoString =
          base64Encode(mp_finger_print_record_photo!);
      prefs.setString(
          'p4_mp_finger_print_record_photo', mpFingerPrintRecordPhotoString);
    }
  }

  // get images from shared preference
  Future<void> _getImages(String photoType) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      try {
        final file = File(pickedFile.path);
        setState(() {
          _writeToPrefs('p4_${photoType}_PATH', file.path);
        });
        //   await FirebaseStorage.instance
        //       .ref()
        //       .child('Reports')
        //       .child(userUID.toString())
        //       .child('report_$reportCount')
        //       .child(photoType)
        //       .putFile(file)
        //       .whenComplete(() async {
        //     await FirebaseStorage.instance
        //         .ref()
        //         .child('Reports')
        //         .child(userUID.toString())
        //         .child('report_$reportCount')
        //         .child(photoType)
        //         .getDownloadURL()
        //         .then((value) {
        //       setState(() {
        //         mpImageURL = value;
        //         _writeToPrefs('p4_${photoType}_LINK', value);
        //       });
        //     });
        //   });
        //   print('image URL: $mpImageURL');
      } catch (e) {
        print('[ERROR] $e');
      }
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        if (photoType == 'mp_recent_photo') {
          mp_recent_photo = imageBytes;
        } else if (photoType == 'mp_dental_record_photo') {
          mp_dental_record_photo = imageBytes;
        } else if (photoType == 'mp_finger_print_record_photo') {
          mp_finger_print_record_photo = imageBytes;
        }
      });
      await _saveImages(); // this is to save the image to shared preference when the user picks an image
    }
  }

  // load images from shared preference
  Future<void> _loadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('p4_mp_recent_photo') != null) {
      String mpRecentPhotoString = prefs.getString('p4_mp_recent_photo')!;
      mp_recent_photo = base64Decode(mpRecentPhotoString);
    }
    if (prefs.getString('p4_mp_dental_record_photo') != null) {
      String mpDentalRecordPhotoString =
          prefs.getString('p4_mp_dental_record_photo')!;
      mp_dental_record_photo = base64Decode(mpDentalRecordPhotoString);
    }
    if (prefs.getString('p4_mp_finger_print_record_photo') != null) {
      String mpFingerPrintRecordPhotoString =
          prefs.getString('p4_mp_finger_print_record_photo')!;
      mp_finger_print_record_photo =
          base64Decode(mpFingerPrintRecordPhotoString);
    }
  }

  /* SHARED PREF EMPTY CHECKER AND SAVER FUNCTION*/
  Future<void> _writeToPrefs(String key, String value) async {
    if (value != '') {
      _prefs.setString(key, value);
    } else {
      _prefs.remove(key);
    }
  }

  Future<void> getBoolChoices() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      mp_hair_color_natural =
          _prefs.getBool('p4_mp_hair_color_natural') ?? true;
      mp_eye_color_natural = _prefs.getBool('p4_mp_eye_color_natural') ?? true;
    });
  }

  /* initState for shared pref text and bool */
  @override
  void initState() {
    super.initState();
    // _getUserChoices(); // this is to get the text and boolean values from shared preference when the page is loaded
    _loadImages(); // this is to load the images from shared preference when the page is loaded
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        // scars, marks, tattoos
        _mp_scars.text = _prefs.getString('p4_mp_scars') ?? '';
        _mp_marks.text = _prefs.getString('p4_mp_marks') ?? '';
        _mp_tattoos.text = _prefs.getString('p4_mp_tattoos') ?? '';
        // hair, eye color
        _mp_hair_color.text = _prefs.getString('p4_mp_hair_color') ?? '';
        _mp_eye_color.text = _prefs.getString('p4_mp_eye_color') ?? '';
        // boolean for hair and eye color
        // mp_hair_color_natural = _prefs.getBool('p4_mp_hair_natural') ?? false;
        // mp_eye_color_natural = _prefs.getBool('p4_mp_eye_natural') ?? false;
        // prosthetics, birth defects, last clothing
        _mp_prosthetics.text = _prefs.getString('p4_mp_prosthetics') ?? '';
        _mp_birth_defects.text = _prefs.getString('p4_mp_birth_defects') ?? '';
        _mp_last_clothing.text = _prefs.getString('p4_mp_last_clothing') ?? '';
        // MP medical details
        _mp_height_feet.text = _prefs.getString('p4_mp_height_feet') ?? '';
        _mp_height_inches.text = _prefs.getString('p4_mp_height_inches') ?? '';
        _mp_weight.text = _prefs.getString('p4_mp_weight') ?? '';
        _mp_blood_type.text = _prefs.getString('p4_mp_blood_type') ?? '';
        mp_blood_typeValue = _prefs.getString('p4_mp_blood_type') ?? 'Unknown';
        _mp_medications.text = _prefs.getString('p4_mp_medications') ?? '';
        // MP socmed details
        _mp_facebook.text =
            _prefs.getString('p4_mp_socmed_facebook_username') ?? '';
        _mp_twitter.text =
            _prefs.getString('p4_mp_socmed_twitter_username') ?? '';
        _mp_instagram.text =
            _prefs.getString('p4_mp_socmed_instagram_username') ?? '';
        _mp_socmed_other_platform.text =
            _prefs.getString('p4_mp_socmed_other_platform') ?? '';
        _mp_socmed_other_username.text =
            _prefs.getString('p4_mp_socmed_other_username') ?? '';
        // bool for mp_dental_available and mp_fingerprints_available
        mp_dental_available = _prefs.getBool('p4_mp_dental_available') ?? false;
        mp_fingerprints_available =
            _prefs.getBool('p4_mp_fingerprints_available') ?? false;
      });
    });
    getBoolChoices();
    retrieveUserData();
  }

  /* BUILD WIDGET */
  @override
  Widget build(BuildContext context) {
    return mp_eye_color_natural != null
        ? Stack(children: [
            Positioned(
                top: MediaQuery.of(context).size.height / 8,
                left: 20,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Page 4 of 6: Absent/Missing Person Description',
                          style: optionStyle,
                        ),
                      ),
                      _verticalPadding,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 25,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 80,
                            child: const Text(
                              '''All fields for the descriptions are required, if unknown or unsure, write NA.''',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _verticalPadding,
                      // SCARS, MARKS, AND TATTOOS SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Scars, Marks, and Tattoos',
                          style: headingStyle,
                        ),
                      ),
                      _verticalPadding,
                      // scars text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_scars,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Scars',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_scars', value);
                              _writeToPrefs('p4_mp_scars', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // marks text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_marks,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Marks',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_marks', value);
                              _writeToPrefs('p4_mp_marks', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // tattoos text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_tattoos,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Tattoos',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_tattoos', value);
                              _writeToPrefs('p4_mp_tattoos', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // HAIR COLOR SECTION
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text('Hair Color', style: headingStyle),
                      ),

                      _verticalPadding,
                      // hair color text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_hair_color,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Hair Color',
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_hair_color', value);
                              _writeToPrefs('p4_mp_hair_color', value);
                            });
                          },
                        ),
                      ),
                      // checkbox to ask if the person's hair is natural
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Row(
                          children: [
                            Checkbox(
                              value: mp_hair_color_natural,
                              onChanged: (bool? value) {
                                setState(() {
                                  mp_hair_color_natural = value;
                                });
                                _prefs.setBool(
                                    'p4_mp_hair_color_natural', value!);
                                // print value from shared preferences
                                // print(_prefs.getBool('p4_mp_hair_natural'));
                                // if false, remove from shared preferences
                              },
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 100,
                              child: const Text(
                                  'Natural hair color (not dyed/wearing wig).',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                      _verticalPadding,
                      // EYE COLOR SECTION
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text('Eye Color', style: headingStyle),
                      ),
                      _verticalPadding,
                      // eye color text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_eye_color,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Eye Color',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_eye_color', value);
                              _writeToPrefs('p4_mp_eye_color', value);
                            });
                          },
                        ),
                      ),
                      // checkbox to ask if the person's eye color is natural
                      SizedBox(
                        // width: MediaQuery.of(context).size.width - 40,
                        child: Row(
                          children: [
                            Checkbox(
                              value: mp_eye_color_natural,
                              onChanged: (bool? value) {
                                setState(() {
                                  mp_eye_color_natural = value;
                                  // if (value == false) {
                                  //   _prefs.remove('p4_mp_eye_natural');
                                  // }
                                });
                                // write to shared preferences
                                _prefs.setBool(
                                    'p4_mp_eye_color_natural', value!);
                                // print value from shared preferences
                                // print(_prefs.getBool('p4_mp_eye_natural'));
                              },
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 100,
                              child: const Text(
                                  'Natural eye color (not wearing contacts)',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                      _verticalPadding,
                      // PROSTHETICS SECTION
                      // text for the prosthetics section
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Prosthetics',
                          style: headingStyle,
                        ),
                      ),
                      // ask if the person has any prosthetics
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_prosthetics,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'If none/unknown type "NA"',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_prosthetics', value);
                              _writeToPrefs('p4_mp_prosthetics', value);
                            });
                          },
                        ),
                      ),
                      // BIRTH DEFECTS SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text('Birth Defects', style: headingStyle),
                      ),
                      _verticalPadding,
                      // birth defects text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_birth_defects,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'If none/unknown type "NA"',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_birth_defects', value);
                              _writeToPrefs('p4_mp_birth_defects', value);
                            });
                          },
                        ),
                      ),
                      // LAST KNOWN CLOTHING AND ACCESSORIES SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text('Last Known Clothing and Accessories',
                            style: headingStyle),
                      ),
                      _verticalPadding,
                      // last known clothing and accessories text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_last_clothing,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Clothing and Accessories',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_last_clothing', value);
                              _writeToPrefs('p4_mp_last_clothing', value);
                            });
                          },
                        ),
                      ),
                      // HEIGHT SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Height',
                          style: headingStyle,
                        ),
                      ),
                      // HEIGHT (in inches and feet, two separate text field rows)
                      _verticalPadding,
                      // height in inches text field, saves to shared preference after user types
                      Row(
                        // height in inches text field, saves to shared preference after user types
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.425,
                            child: TextField(
                              controller: _mp_height_feet,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Feet (ft)',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // _prefs.setString('p4_mp_height_inches', value);
                                  _writeToPrefs('p4_mp_height_inches', value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.425,
                            child: TextField(
                              controller: _mp_height_inches,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Inches (inch)',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // _prefs.setString('p4_mp_height_feet', value);
                                  _writeToPrefs('p4_mp_height_feet', value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      // WEIGHT SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Weight',
                          style: headingStyle,
                        ),
                      ),
                      _verticalPadding,
                      // weight text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_weight,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Kilograms (kg)',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_weight', value);
                              _writeToPrefs('p4_mp_weight', value);
                            });
                          },
                        ),
                      ),
                      // BLOOD TYPE SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Blood Type',
                          style: headingStyle,
                        ),
                      ),
                      _verticalPadding,
                      // bloodtype Drop down menu, saves to shared preference after user types
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: DropdownButtonFormField<String>(
                            // text to display when no value is selected
                            hint: const Text('Select Blood Type'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            value: mp_blood_typeValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.black54),
                            onChanged: (String? bloodtypeValue) {
                              setState(() {
                                mp_blood_typeValue = bloodtypeValue;
                                // _prefs.setString('p4_mp_blood_type', bloodtype_value!);
                                _writeToPrefs(
                                    'p4_mp_blood_type', bloodtypeValue!);
                              });
                            },
                            items: <String>[
                              'A+',
                              'A-',
                              'B+',
                              'B-',
                              'AB+',
                              'AB-',
                              'O+',
                              'O-',
                              'Unknown',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                      // MEDICATIONS SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Medications',
                          style: headingStyle,
                        ),
                      ),
                      _verticalPadding,
                      // medications text field, saves to shared preference after user types
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_medications,
                          decoration: const InputDecoration(
                            hintText: 'If none/unknown type "NA"',
                            labelText: 'Medications',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_medications', value);
                              _writeToPrefs('p4_mp_medications', value);
                            });
                          },
                        ),
                      ),
                      // SOCIAL MEDIA ACCOUNTS SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Social Media Accounts',
                          style: headingStyle,
                        ),
                      ),
                      _verticalPadding,
                      // text fields for facebook username
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_facebook,
                          decoration: const InputDecoration(
                            labelText: 'Facebook',
                            hintText: 'Facebook Username (NA if none/unknown)',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_socmed_facebook_username', value);
                              _writeToPrefs(
                                  'p4_mp_socmed_facebook_username', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // text fields for twitter username
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_twitter,
                          decoration: const InputDecoration(
                            labelText: 'Twitter',
                            hintText: 'Twitter Username (NA if none/unknown)',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_socmed_twitter_username', value);
                              _writeToPrefs(
                                  'p4_mp_socmed_twitter_username', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // text fields for instagram username
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextField(
                          controller: _mp_instagram,
                          decoration: const InputDecoration(
                            labelText: 'Instagram',
                            hintText: 'Instagram Username (NA if none/unknown)',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // _prefs.setString('p4_mp_socmed_instagram_username', value);
                              _writeToPrefs(
                                  'p4_mp_socmed_instagram_username', value);
                            });
                          },
                        ),
                      ),
                      _verticalPadding,
                      // two text fields in a row for "other social media platform" and "username"
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.425,
                            child: TextField(
                              controller: _mp_socmed_other_platform,
                              decoration: const InputDecoration(
                                labelText: 'Others',
                                hintText: 'Platform Name',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // _prefs.setString('p4_mp_socmed_other_platform', value);
                                  _writeToPrefs(
                                      'p4_mp_socmed_other_platform', value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.425,
                            child: TextField(
                              controller: _mp_socmed_other_username,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Username',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // _prefs.setString('p4_mp_socmed_other_username', value);
                                  _writeToPrefs(
                                      'p4_mp_socmed_other_username', value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      _verticalPadding,

                      // RECENT PHOTO SECTION
                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Photograph of the Absent/Missing Person',
                          style: headingStyle,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Center(
                          child: Text(
                            'Please upload the most recent pictures/photographs of the person being reported',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // show recent photo in sizedbox
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        //height: 200,
                        child: mp_recent_photo != null
                            ? Image.memory(
                                mp_recent_photo!,
                                height: 300,
                              )
                            : Center(
                                child: Column(
                                children: [
                                  Icon(
                                    Icons.drive_folder_upload,
                                    size: 250,
                                    color: Colors.grey[200],
                                  ),
                                  Text(
                                    'No photo uploaded',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )),
                      ),

                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _getImages('mp_recent_photo');
                          },
                          child: const Text('Upload Photo'),
                        ),
                      ),

                      _verticalPadding,
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text('Records of Dental and Fingerprints',
                            style: headingStyle),
                      ),
                      const SizedBox(height: 5),
                      // checkbox to ask if the person has dental and/or finger print records
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: const Text(
                          'Does the person have dental and/or finger print records? Please check all that apply',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                      _verticalPadding,
                      Row(
                        children: [
                          const Text('Dental Records'),
                          Checkbox(
                            value: mp_dental_available,
                            onChanged: (value) {
                              setState(() {
                                mp_dental_available = value!;
                                if (value == true) {
                                  widget.addHeightParent();
                                } else {
                                  widget.subtractHeightParent();
                                }
                                // set bool in prefs
                                _prefs.setBool('p4_mp_dental_available', value);
                              });
                            },
                          ),
                          const Center(child: Text('Finger Print Records')),
                          Checkbox(
                            value: mp_fingerprints_available,
                            onChanged: (value) {
                              setState(() {
                                mp_fingerprints_available = value!;
                                if (value == true) {
                                  widget.addHeightParent();
                                } else {
                                  widget.subtractHeightParent();
                                }
                                // set bool in prefs
                                _prefs.setBool(
                                    'p4_mp_fingerprints_available', value);
                              });
                            },
                          ),
                        ],
                      ),
                      // if mp_dental_records_available is true, show ask to upload dental record photo
                      if (mp_dental_available == true)
                        Column(
                          children: [
                            _verticalPadding,
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: const Text(
                                'Dental Record Photo',
                                style: headingStyle,
                              ),
                            ),
                            // show dental record photo in sizedbox
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: mp_dental_record_photo != null
                                  ? Image.memory(
                                      mp_dental_record_photo!,
                                      height: 200,
                                    )
                                  : Center(
                                      child: Column(
                                      children: [
                                        Icon(
                                          Icons.newspaper_rounded,
                                          size: 200,
                                          color: Colors.grey[200],
                                        ),
                                        Text('No image selected.'),
                                        SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    )),
                            ),
                            _verticalPadding,
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  _getImages('mp_dental_record_photo');
                                },
                                child: const Text('Upload'),
                              ),
                            ),
                          ],
                        ),
                      // if mp_finger_print_records_available is true, show ask to upload finger print record photo
                      if (mp_fingerprints_available == true)
                        Column(
                          children: [
                            _verticalPadding,
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: const Text(
                                'Fingerprint Record Photo',
                                style: headingStyle,
                              ),
                            ),
                            _verticalPadding,
                            // show finger print record photo in sizedbox
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: mp_finger_print_record_photo != null
                                  ? Image.memory(
                                      mp_finger_print_record_photo!,
                                      height: 200,
                                    )
                                  : Center(
                                      child: Column(
                                      children: [
                                        Icon(
                                          Icons.fingerprint_rounded,
                                          size: 200,
                                          color: Colors.grey[200],
                                        ),
                                        Text('No image selected.'),
                                        SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    )),
                            ),
                            _verticalPadding,
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  _getImages('mp_finger_print_record_photo');
                                },
                                child: const Text('Upload'),
                              ),
                            ),
                          ],
                        ),
                      // END OF PAGE
                      _verticalPadding,
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              // Icons.info_outline_rounded,
                              Icons.swipe_left_rounded,
                              color: Colors.black54,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: const Text(
                                'End of Absent/Missing Person Description Form. \nSwipe left to continue.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // DEBUG TOOL: SHARED PREF PRINTER
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          print(prefs.getKeys());
                          // print(prefs.getString('p4_mp_scars'));
                          // print(prefs.getString('p4_mp_marks'));
                          // print(prefs.getString('p4_mp_blood_type'));
                          // print(prefs
                          //     .getString('p4_mp_socmed_facebook_username'));
                          // // print bools for hair and eye
                          // print(prefs.getBool('p4_mp_hair_color_natural'));
                          // print(prefs.getBool('p4_mp_eye_color_natural'));
                        },
                        child: const Text('Print Shared Preferences'),
                      ),
                    ]))
          ])
        : // Circular loading icon
        const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ));
  }
}
