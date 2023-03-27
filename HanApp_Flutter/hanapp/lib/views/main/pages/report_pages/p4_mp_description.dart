import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:image_picker/image_picker.dart';

// shared preferences for state management
late SharedPreferences _prefs;
void clearPrefs() {
  _prefs.clear();
}

class Page4MPDesc extends StatefulWidget {
  const Page4MPDesc({super.key});

  @override
  State<Page4MPDesc> createState() => _Page4MPDescState();
}

class _Page4MPDescState extends State<Page4MPDesc> {
  /* FORMATTING */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);

  // local variables for text fields
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
  // MP recent photo
  File? mp_recent_photo;
  // MP other photos (multiple)
  List<File> mp_other_photos = [];
  // MP dental records (multiple)
  bool? mp_dental_records_available = false;
  List<File> mp_dental_records = [];
  // MP fingerprints (multiple)
  bool? mp_fingerprints_available = false;
  List<File> mp_fingerprints = [];

  // initialize ImagePicker
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes; // for storing the image as bytes

  // _loadImage initialize
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // function to load image from shared preferences
  void _loadImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imageData = prefs.getString('imageData');
    if (imageData != null) {
      setState(() {
        _imageBytes = base64Decode(imageData);
      });
    }
  }

  // function to save image to shared preferences
  void _saveImage(Uint8List imageBytes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String imageData = base64Encode(imageBytes);
    if (_imageBytes != null) {
      prefs.setString('imageData', base64Encode(imageBytes));
    }
  }

  // function to pick image from gallery OR camera
  void _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      _saveImage(imageBytes);
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }

  // function to pick multiple images from gallery OR camera
  void _pickMultipleImages(ImageSource source) async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      for (var image in images) {
        final Uint8List imageBytes = await image.readAsBytes();
        _saveImage(imageBytes);
        setState(() {
          _imageBytes = imageBytes;
        });
      }
    }
  }

  // old function
  // Future<File?> _pickImage(ImageSource source) async {
  //   final XFile? image = await _picker.pickImage(source: source);
  //   final File? file = File(image!.path);
  //   return file;
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: 100,
        left: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // text fields for Scars
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_scars = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Scars',
                ),
              ),
            ),
            _verticalPadding,
            // text fields for Marks
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_marks = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Marks',
                ),
              ),
            ),
            _verticalPadding,
            // text fields for Tattoos
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_tattoos = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tattoos',
                ),
              ),
            ),
            _verticalPadding,
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
            // text fields for Hair Color
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_hair_color = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Hair Color',
                ),
              ),
            ),
            _verticalPadding,
            // NOTE! Insert checkbox for Hair Color Natural
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
            // text fields for Eye Color
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_eye_color = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Eye Color',
                ),
              ),
            ),
            _verticalPadding,
            // NOTE! Insert checkbox for Eye Color Natural
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
            _verticalPadding,
            // text fields for Prosthetics
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_prosthetics = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Prosthetics',
                ),
              ),
            ),
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
            // text fields for Birth Defects
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_birth_defects = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Birth Defects',
                ),
              ),
            ),
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
            // big text field for Last Known Clothing and Accessories
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  last_clothing = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Last Known Clothing and Accessories',
                ),
              ),
            ),
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Medical Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // text fields for Height
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Height',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            _verticalPadding,
            // two separate text fields (Height: feet and Height: inches)
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  child: TextField(
                    onChanged: (value) {
                      mp_height_feet = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Feet',
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  child: TextField(
                    onChanged: (value) {
                      mp_height_inches = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Inches',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            // text fields for Weight
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_weight = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Weight (kg)',
                ),
              ),
            ),
            _verticalPadding,
            // dropdown for Blood Type
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: DropdownButtonFormField<String>(
                // text to display when no value is selected
                hint: const Text("Blood Type"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: mp_blood_type,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black54),
                onChanged: (String? newValue) {
                  setState(() {
                    mp_blood_type = newValue;
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
              ),
            ),
            _verticalPadding,
            // text fields for medications
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_medications = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Medications (separate by comma)',
                ),
              ),
            ),
            _verticalPadding,
            // Social Media Accounts
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
            // text fields for facebook
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_facebook = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Facebook',
                ),
              ),
            ),
            // text fields for twitter
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_twitter = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Twitter',
                ),
              ),
            ),
            // text fields for instagram
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                onChanged: (value) {
                  mp_instagram = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Instagram',
                ),
              ),
            ),
            // text fields for other social media
            _verticalPadding,
            // should be two text fields in one row for other social media platform and username
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Other Socmed Platform',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            _verticalPadding,
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: TextField(
                    onChanged: (value) {
                      mp_socmed_other_platform = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Other Social Media',
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: TextField(
                    onChanged: (value) {
                      mp_socmed_other_username = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            // ask to upload most recent photo
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
            _verticalPadding,
            // upload photo button
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                  // final XFile? mp_recent_photo = _picker.pickImage(
                  //     source: ImageSource.gallery,
                  //     imageQuality: 50,
                  //     maxWidth: 1800) as XFile?;
                },
                child: const Text('Upload Photo'),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : const Text('No image selected.'),
            ),
            // ask to upload other photos
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Upload other photos of the absent/missing person',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),

            _verticalPadding,
            // upload multiple photos button
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: ElevatedButton(
                onPressed: () {
                  _pickMultipleImages(ImageSource.gallery);
                  // final List<XFile>? mp_other_photos = _picker.pickMultiImage(
                  //     imageQuality: 50, maxWidth: 1800) as List<XFile>?;
                },
                child: const Text('Upload Photos'),
              ),
            ),
            // show image preview
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : const Text('No image selected.'),
            ),
            _verticalPadding,
            // Checkbox to ask if the person has dental and/or finger print records
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
                  value: mp_dental_records_available,
                  onChanged: (value) {
                    setState(() {
                      mp_dental_records_available = value!;
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
            // if mp_dental_records_available is true, ask to upload dental records
            if (mp_dental_records_available == true)
              Column(
                children: [
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: const Text(
                      'Upload dental records',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                  _verticalPadding,
                  // upload dental records button
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _pickMultipleImages(ImageSource.gallery);
                        // final XFile? mp_dental_records = _picker.pickImage(
                        //     source: ImageSource.gallery,
                        //     imageQuality: 50,
                        //     maxWidth: 1800) as XFile?;
                      },
                      child: const Text('Upload Dental Records'),
                    ),
                  ),
                ],
              ),
            // if mp_fingerprints_available is true, ask to upload finger print records
            if (mp_fingerprints_available == true)
              Column(
                children: [
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: const Text(
                      'Upload finger print records',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ),
                  _verticalPadding,
                  // upload finger print records button
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _pickMultipleImages(ImageSource.gallery);
                        // final XFile? mp_fingerprints = _picker.pickImage(
                        //     source: ImageSource.gallery,
                        //     imageQuality: 50,
                        //     maxWidth: 1800) as XFile?;
                      },
                      child: const Text('Upload Finger Print Records'),
                    ),
                  ),
                ],
              ),
            // "Swipe Right to Move to Next Page"
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "End of Absent/Missing Person Details Form. Swipe left to move to next page",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
