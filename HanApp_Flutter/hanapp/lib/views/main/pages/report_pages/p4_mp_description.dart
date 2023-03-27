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

  /* INITIALIZE VARIABLES FOR SHARED PREFERENCE */
  // get text and boolean values from shared preferences
  Future<void> _getUserChoices() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // set the state of the checkboxes
      mp_scars = _prefs.getString('p4_mp_scars') ?? '';
      mp_marks = _prefs.getString('p4_mp_marks') ?? '';
      mp_tattoos = _prefs.getString('p4_mp_tattoos') ?? '';
      mp_hair_color = _prefs.getString('p4_mp_hair_color') ?? '';
      mp_hair_color_natural =
          _prefs.getBool('p4_mp_hair_color_natural') ?? false;
      mp_eye_color = _prefs.getString('p4_mp_eye_color') ?? '';
      mp_eye_color_natural = _prefs.getBool('p4_mp_eye_color_natural') ?? false;
      mp_prosthetics = _prefs.getString('p4_mp_prosthetics') ?? '';
      mp_birth_defects = _prefs.getString('p4_mp_birth_defects') ?? '';
      last_clothing = _prefs.getString('p4_last_clothing') ?? '';
      mp_height_feet = _prefs.getString('p4_mp_height_feet') ?? '';
      mp_height_inches = _prefs.getString('p4_mp_height_inches') ?? '';
      mp_weight = _prefs.getString('p4_mp_weight') ?? '';
      mp_blood_type = _prefs.getString('p4_mp_blood_type') ?? '';
      mp_medications = _prefs.getString('p4_mp_medications') ?? '';
      mp_facebook = _prefs.getString('p4_mp_facebook') ?? '';
      mp_twitter = _prefs.getString('p4_mp_twitter') ?? '';
      mp_instagram = _prefs.getString('p4_mp_instagram') ?? '';
      mp_socmed_other_platform =
          _prefs.getString('p4_mp_socmed_other_platform') ?? '';
      mp_socmed_other_username =
          _prefs.getString('p4_mp_socmed_other_username') ?? '';
    });
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
    _getUserChoices();
    _loadImages();
  }
  // this is to load the images from shared preference when the page is loaded

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
            _verticalPadding,
            // upload recent photo
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
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "End of Absent/Missing Person Details Form. Swipe left to move to next page",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ]))
    ]);
  }
}
