/* 
1. Remove "Other Photo"
2. Implement Shared Pref
3. Naming convention for variables (ex: p4_mp_desc, p4_mp_recent_photo)
4. Only three photos: Most Recent Photo, Dental Record, Finger Print Record (last two optional)
*/

/* IMPORTS */
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

/* SHARED PREFERENCE */
late SharedPreferences _prefs;
void clearPrefs() {
  _prefs.clear();
}

/* PAGE 4 */
class Page4MPDesc extends StatefulWidget {
  const Page4MPDesc({super.key});

  @override
  State<Page4MPDesc> createState() => _Page4MPDescState();
}

/* PAGE 4 STATE */
class _Page4MPDescState extends State<Page4MPDesc> {
  /* FORMATTING */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);

  /* IMAGE PICKER */
  final ImagePicker _picker = ImagePicker();

  /* VARIABLES */
  // MP Appearance
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
  String? mp_blood_type;
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

  // list for blood types for dropdown
  List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
  bool _mp_hair_color_natural = false;
  bool _mp_eye_color_natural = false;

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
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

  /* initState for picking images */
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
        mp_hair_color_natural =
            _prefs.getBool('p4_mp_hair_color_unknown') ?? false;
        mp_eye_color_natural =
            _prefs.getBool('p4_mp_eye_color_unknown') ?? false;
        // prosthetics, birth defects, last clothing
        _mp_prosthetics.text = _prefs.getString('p4_mp_prosthetics') ?? '';
        _mp_birth_defects.text = _prefs.getString('p4_mp_birth_defects') ?? '';
        _mp_last_clothing.text = _prefs.getString('p4_mp_last_clothing') ?? '';
        // MP medical details
        _mp_height_feet.text = _prefs.getString('p4_mp_height_feet') ?? '';
        _mp_height_inches.text = _prefs.getString('p4_mp_height_inches') ?? '';
        _mp_weight.text = _prefs.getString('p4_mp_weight') ?? '';
        _mp_blood_type.text = _prefs.getString('p4_mp_blood_type') ?? '';
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
      });
    });
  }

  /* BUILD WIDGET */
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 100,
          left: 20,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Page 4: Absent/Missing Person Description',
                style: optionStyle,
              ),
            ),
            _verticalPadding,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info),
                SizedBox(width: 5),
                Text(
                  '''Fields with (*) are required.''',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            // SCARS, MARKS, AND TATTOOS SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Scars, Marks, and Tattoos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // scars text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_scars,
                decoration: const InputDecoration(
                  labelText: 'Scars',
                  hintText: 'Scars',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_scars', value);
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
                decoration: const InputDecoration(
                  labelText: 'Marks',
                  hintText: 'Marks',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_marks', value);
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
                decoration: const InputDecoration(
                  labelText: 'Tattoos',
                  hintText: 'Tattoos',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_tattoos', value);
                  });
                },
              ),
            ),
            _verticalPadding,
            // HAIR COLOR SECTION
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Hair Color',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // hair color text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_hair_color,
                decoration: const InputDecoration(
                  labelText: 'Hair Color',
                  hintText: 'Hair Color',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_hair_color', value);
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
                    value: _mp_hair_color_natural,
                    onChanged: (value) {
                      setState(() {
                        _mp_hair_color_natural = value!;
                        _prefs.setBool('p4_mp_hair_natural', value);
                      });
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: const Text(
                        'Is the hair color natural? (not dyed/ wearing wig)'),
                  ),
                ],
              ),
            ),
            _verticalPadding,
            // EYE COLOR SECTION
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Eye Color',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // eye color text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_eye_color,
                decoration: const InputDecoration(
                  labelText: 'Eye Color',
                  hintText: 'Eye Color',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_eye_color', value);
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
                    value: _mp_eye_color_natural,
                    onChanged: (value) {
                      setState(() {
                        _mp_eye_color_natural = value!;
                        _prefs.setBool('p4_mp_eye_natural', value);
                      });
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: const Text(
                        'Is the eye color natural (not wearing contacts)?'),
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            // ask if the person has any prosthetics
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_prosthetics,
                decoration: const InputDecoration(
                  labelText: 'Prosthetics (if none/unknown type "NA")',
                  hintText: 'Prosthetics',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_prosthetics', value);
                  });
                },
              ),
            ),
            // BIRTH DEFECTS SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Birth Defects',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // birth defects text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_birth_defects,
                decoration: const InputDecoration(
                  labelText: 'Birth Defects (if none/unknown type "NA")',
                  hintText: 'Birth Defects',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_birth_defects', value);
                  });
                },
              ),
            ),
            // LAST KNOWN CLOTHING AND ACCESSORIES SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Last Known Clothing and Accessories',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // last known clothing and accessories text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_last_clothing,
                decoration: const InputDecoration(
                  labelText: 'Last Known Clothing and Accessories',
                  hintText: 'Last Known Clothing and Accessories',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_last_clothing', value);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            // HEIGHT (in inches and feet, two separate text field rows)
            _verticalPadding,
            // height in inches text field, saves to shared preference after user types
            Row(
              // height in inches text field, saves to shared preference after user types
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: _mp_height_inches,
                    decoration: const InputDecoration(
                      labelText: 'Height (feet)',
                      hintText: 'Height (feet)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p4_mp_height_feet', value);
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: _mp_height_feet,
                    decoration: const InputDecoration(
                      labelText: 'Height (inches)',
                      hintText: 'Height (inches)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p4_mp_height_inches', value);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // weight text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_weight,
                decoration: const InputDecoration(
                  labelText: 'Weight (kilograms)',
                  hintText: 'Weight (kilograms)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_weight', value);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                    border: OutlineInputBorder(),
                  ),
                  value: mp_blood_type,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? bloodtype_value) {
                    setState(() {
                      mp_blood_type = bloodtype_value;
                      _prefs.setString('p4_mp_blood_type', bloodtype_value!);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // medications text field, saves to shared preference after user types
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_medications,
                decoration: const InputDecoration(
                  labelText: 'Medications (if none/unknown type "NA")',
                  hintText: 'Medications',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_medications', value);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // text fields for facebook username
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_facebook,
                decoration: const InputDecoration(
                  labelText: 'Facebook Username',
                  hintText: 'Facebook Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_socmed_facebook_username', value);
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
                  labelText: 'Twitter Username',
                  hintText: 'Twitter Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_socmed_twitter_username', value);
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
                  labelText: 'Instagram Username',
                  hintText: 'Instagram Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _prefs.setString('p4_mp_socmed_instagram_username', value);
                  });
                },
              ),
            ),
            _verticalPadding,
            // two text fields in a row for "other social media platform" and "username"
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextField(
                    controller: _mp_socmed_other_platform,
                    decoration: const InputDecoration(
                      labelText: 'Other Socmed Platform',
                      hintText: 'Platform Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p4_mp_socmed_other_platform', value);
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: _mp_socmed_other_username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p4_mp_socmed_other_username', value);
                      });
                    },
                  ),
                ),
              ],
            ),

            // RECENT PHOTO SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Most recent photo of the absent/missing person',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: ElevatedButton(
                onPressed: () {
                  _getImages('mp_recent_photo');
                },
                child: const Text('Upload'),
              ),
            ),
            _verticalPadding,
            // show recent photo in sizedbox
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 200,
              child: mp_recent_photo != null
                  ? Image.memory(mp_recent_photo!)
                  : const Text('No image selected.'),
            ),
            _verticalPadding,
            // checkbox to ask if the person has dental and/or finger print records
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Does the person have dental and/or finger print records?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                    });
                  },
                ),
                const Text('Finger Print Records'),
                Checkbox(
                  value: mp_fingerprints_available,
                  onChanged: (value) {
                    setState(() {
                      mp_fingerprints_available = value!;
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
                      'Upload dental record photo',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _getImages('mp_dental_record_photo');
                      },
                      child: const Text('Upload'),
                    ),
                  ),
                  _verticalPadding,
                  // show dental record photo in sizedbox
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: mp_dental_record_photo != null
                        ? Image.memory(mp_dental_record_photo!)
                        : const Text('No image selected.'),
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
                      'Upload finger print record photo',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _getImages('mp_finger_print_record_photo');
                      },
                      child: const Text('Upload'),
                    ),
                  ),
                  _verticalPadding,
                  // show finger print record photo in sizedbox
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 200,
                    child: mp_finger_print_record_photo != null
                        ? Image.memory(mp_finger_print_record_photo!)
                        : const Text('No image selected.'),
                  ),
                ],
              ),
            // END OF PAGE
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "End of Absent/Missing Person Details Form. Swipe left to move to next page",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                print(prefs.getKeys());
                print(prefs.getString('p4_mp_scars'));
                print(prefs.getString('p4_mp_marks'));
                print(prefs.getString('p4_mp_blood_type'));
                print(prefs.getString('p4_mp_socmed_facebook_username'));
              },
              child: const Text('Print Shared Preferences'),
            ),
          ]))
    ]);
  }
}
