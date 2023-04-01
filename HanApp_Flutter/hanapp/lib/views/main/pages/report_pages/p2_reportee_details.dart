import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
LACKING:
1. Adaptive height for scrolling (probably in report_main.dart)
2. JSON for drop down for address (Region, Province, City/Town, Barangay)
3. Data persistence for the form
4. Fix Date Picker for Birthday
5. Age should be calculated based on the date of birth, and automatically updated (grayed out text form field)

 
*/

/* DATE PICKER SETUP */
List reformatDate(String dateTime, DateTime dateTimeBday) {
  var dateParts = dateTime.split('-');
  var month = dateParts[1];
  if (int.parse(month) % 10 != 0) {
    month = month.replaceAll('0', '');
  }
  // switch case of shame
  switch (month) {
    case '1':
      month = 'January';
      break;
    case '2':
      month = 'February';
      break;
    case '3':
      month = 'March';
      break;
    case '4':
      month = 'April';
      break;
    case '5':
      month = 'May';
      break;
    case '6':
      month = 'June';
      break;
    case '7':
      month = 'July';
      break;
    case '8':
      month = 'August';
      break;
    case '9':
      month = 'September';
      break;
    case '10':
      month = 'October';
      break;
    case '11':
      month = 'November';
      break;
    case '12':
      month = 'December';
      break;
  }

  var day = dateParts[2];
  day = day.substring(0, day.indexOf(' '));
  if (int.parse(day) % 10 != 0) {
    day = day.replaceAll('0', '');
  }

  var year = dateParts[0];

  var age =
      (DateTime.now().difference(dateTimeBday).inDays / 365).floor().toString();
  var returnVal = '$month $day, $year'; // format sample: January 1, 2021
  return [returnVal, age];
}

/* END OF DATE PICKER SETUP */

/* Stateful Widget Class */
class Page2ReporteeDetails extends StatefulWidget {
  const Page2ReporteeDetails({Key? key}) : super(key: key);

  @override
  State<Page2ReporteeDetails> createState() => _Page2ReporteeDetailsState();
}

late SharedPreferences _prefs;

class _Page2ReporteeDetailsState extends State<Page2ReporteeDetails> {
  PlatformFile? pickedFile;
  Uint8List? pickedFileBytes;

  Uint8List? reportee_ID_Photo;
  Uint8List? singlePhoto_face;
  String? relationshipToMP;
  String? citizenship;
  String? civil_status;
  String? homePhone;
  String? mobilePhone;
  String? altMobilePhone;
  String? region;
  String? province;
  String? townCity;
  String? barangay;
  String? villageSitio;
  String? streetHouseNum;
  String? altRegion;
  String? altProvince;
  String? altTownCity;
  String? altBarangay;
  String? altVillageSitio;
  String? altStreetHouseNum;
  String? highestEduc;
  String? occupation;

  Future<void> loadImages() async {
    String? reportee_ID_Photo_String = _prefs.getString('p2_reportee_ID_Photo');
    if (reportee_ID_Photo_String == null) {
      print('[p2] No ID photo');
      return;
    } else {
      setState(() {
        reportee_ID_Photo = base64Decode(reportee_ID_Photo_String);
      });
    }
  }

  Future<void> loadImage_face() async {
    String? singlePhotoStringFace = _prefs.getString('p2_singlePhoto_face');
    if (singlePhotoStringFace == null) {
      print('[p2] No user selfie ');
      return;
    } else {
      setState(() {
        singlePhoto_face = base64Decode(singlePhotoStringFace);
      });
    }
  }

  Future<void> saveImages() async {
    if (reportee_ID_Photo != null) {
      _prefs.setString(
          'p2_reportee_ID_Photo', base64Encode(reportee_ID_Photo!));
    }
    if (singlePhoto_face != null) {
      _prefs.setString('p2_singlePhoto_face', base64Encode(singlePhoto_face!));
    }
  }

  Future<void> getImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        reportee_ID_Photo = imageBytes;
      });
      await saveImages();
    }
  }

  Future<void> getImageFace() async {
    final pickerFace = ImagePicker();
    final pickedFileFace =
        await pickerFace.pickImage(source: ImageSource.camera);
    if (pickedFileFace != null) {
      final imageBytesFace = await pickedFileFace.readAsBytes();
      setState(() {
        singlePhoto_face = imageBytesFace;
      });
      await saveImages();
    }
  }

  Future<void> getReporteeInfo() async {
    _prefs = await SharedPreferences.getInstance();
    loadImages();
    loadImage_face();
    setState(() {
      relationshipToMP = _prefs.getString('p2_relationshipToMP');
      if (relationshipToMP != null) {
        _reporteeRelationshipToMissingPerson.text = relationshipToMP!;
      }

      citizenship = _prefs.getString('p2_citizenship');
      if (citizenship != null) {
        _reporteeCitizenship.text = citizenship!;
      }

      civil_status = _prefs.getString('p2_civil_status');
      if (civil_status != null) {
        _reporteeCivilStatus.text = civil_status!;
      }

      homePhone = _prefs.getString('p2_homePhone');
      if (homePhone != null) {
        _reporteeHomePhone.text = homePhone!;
      }

      mobilePhone = _prefs.getString('p2_mobilePhone');
      if (mobilePhone != null) {
        _reporteeMobilePhone.text = mobilePhone!;
      }

      altMobilePhone = _prefs.getString('p2_altMobilePhone');
      if (altMobilePhone != null) {
        _reporteeAlternateMobilePhone.text = altMobilePhone!;
      }

      region = _prefs.getString('p2_region');
      if (region != null) {
        _reporteeRegion.text = region!;
      }

      province = _prefs.getString('p2_province');
      if (province != null) {
        _reporteeProvince.text = province!;
      }

      townCity = _prefs.getString('p2_townCity');
      if (townCity != null) {
        _reporteeCity.text = townCity!;
      }

      barangay = _prefs.getString('p2_barangay');
      if (barangay != null) {
        _reporteeBarangay.text = barangay!;
      }

      villageSitio = _prefs.getString('p2_villageSitio');
      if (villageSitio != null) {
        _reporteeVillageSitio.text = villageSitio!;
      }

      streetHouseNum = _prefs.getString('p2_streetHouseNum');
      if (streetHouseNum != null) {
        _reporteeStreetHouseNum.text = streetHouseNum!;
      }

      altRegion = _prefs.getString('p2_altRegion');
      if (altRegion != null) {
        _reporteeAltRegion.text = altRegion!;
      }

      altProvince = _prefs.getString('p2_altProvince');
      if (altProvince != null) {
        _reporteeAltProvince.text = altProvince!;
      }

      altTownCity = _prefs.getString('p2_altTownCity');
      if (altTownCity != null) {
        _reporteeAltCityTown.text = altTownCity!;
      }

      altBarangay = _prefs.getString('p2_altBarangay');
      if (altBarangay != null) {
        _reporteeAltBarangay.text = altBarangay!;
      }

      altVillageSitio = _prefs.getString('p2_altVillageSitio');
      if (altVillageSitio != null) {
        _reporteeAltVillageSitio.text = altVillageSitio!;
      }

      altStreetHouseNum = _prefs.getString('p2_altStreetHouseNum');
      if (altStreetHouseNum != null) {
        _reporteeAltStreetHouseNum.text = altStreetHouseNum!;
      }

      highestEduc = _prefs.getString('p2_highestEduc');
      if (highestEduc != null) {
        _reporteeHighestEduc.text = highestEduc!;
      }
      occupation = _prefs.getString('p2_occupation');
      if (occupation != null) {
        _reporteeOccupation.text = occupation!;
      }
    });
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      pickedFileBytes = pickedFile!.bytes;
    });
  }

  /* SHARED PREF EMPTY CHECKER AND SAVER FUNCTION*/
  Future<void> _writeToPrefs(String key, String value) async {
    if (value != '') {
      _prefs.setString(key, value);
    } else {
      _prefs.remove(key);
    }
  }

  /* FORMATTING STUFF */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);
  /* END OF FORMATTING STUFF */

/* VARIABLES AND CONTROLLERS */
// controllers for the form
// REPORTEE SEX, CITIZENSHIP, CIVIL STATUS
  late final TextEditingController _reporteeCitizenship;
  late final TextEditingController _reporteeCivilStatus;
// REPORTEE BIRTHDAY
  late final TextEditingController _reporteeBirthdayController;
// REPORTEE AGE (not a controller, should be calculated from birthday)
  String? ageFromBday;
// REPORTEE CONTACT DETAILS
  late final TextEditingController _reporteeHomePhone;
  late final TextEditingController _reporteeMobilePhone;
  late final TextEditingController _reporteeAlternateMobilePhone;
  late final TextEditingController _reporteeEmail;
// REPORTEE ADDRESS
  late final TextEditingController _reporteeRegion;
  late final TextEditingController _reporteeProvince;
  late final TextEditingController _reporteeCity;
  late final TextEditingController _reporteeBarangay;
  late final TextEditingController _reporteeVillageSitio;
  late final TextEditingController _reporteeStreetHouseNum;
// REPORTEE ALTERNATE ADDRESS
  late final TextEditingController _reporteeAltRegion;
  late final TextEditingController _reporteeAltProvince;
  late final TextEditingController _reporteeAltCityTown;
  late final TextEditingController _reporteeAltBarangay;
  late final TextEditingController _reporteeAltVillageSitio;
  late final TextEditingController _reporteeAltStreetHouseNum;
// REPORTEE EDUC AND OCCUPATION
  late final TextEditingController _reporteeHighestEduc;
  late final TextEditingController _reporteeOccupation;
// REPORTEE ID
  late final TextEditingController _reporteeID;
// REPORTEE PHOTO
  late final TextEditingController _reporteePhoto;
// REPORTEE RELATIONSHIP TO MISSING PERSON
  late final TextEditingController _reporteeRelationshipToMissingPerson;

  String? _sexValue;
  String? _civilStatusValue;
  DateTime? _dateOfBirth;
  DateTime? dateTimeBday;

  String? _highestEduc;
  File? _reporteeIDphoto;

  bool? reportee_AltAddress_available = false;

  // controllers to contain the text in the form
  late final TextEditingController _dateOfBirthController;

// initialize controllers
  @override
  void initState() {
    try {
      if (kDebugMode) {
        print('[PREFS] ${_prefs.getKeys()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PREFS] No prefs found: ${e.toString()}');
      }
    }
    _reporteeCitizenship = TextEditingController();
    _reporteeCivilStatus = TextEditingController();
    _reporteeBirthdayController = TextEditingController();
    _reporteeHomePhone = TextEditingController();
    _reporteeMobilePhone = TextEditingController();
    _reporteeAlternateMobilePhone = TextEditingController();
    _reporteeEmail = TextEditingController();
    _reporteeRegion = TextEditingController();
    _reporteeProvince = TextEditingController();
    _reporteeCity = TextEditingController();
    _reporteeBarangay = TextEditingController();
    _reporteeVillageSitio = TextEditingController();
    _reporteeStreetHouseNum = TextEditingController();
    _reporteeAltRegion = TextEditingController();
    _reporteeAltProvince = TextEditingController();
    _reporteeAltCityTown = TextEditingController();
    _reporteeAltBarangay = TextEditingController();
    _reporteeAltVillageSitio = TextEditingController();
    _reporteeAltStreetHouseNum = TextEditingController();
    _reporteeHighestEduc = TextEditingController();
    _reporteeOccupation = TextEditingController();
    _reporteeID = TextEditingController();
    _reporteePhoto = TextEditingController();
    _reporteeRelationshipToMissingPerson = TextEditingController();
    _dateOfBirthController = TextEditingController();
    getReporteeInfo();
    super.initState();
  }

  // dispose controllers
  @override
  void dispose() {
    _reporteeCitizenship.dispose();
    _reporteeCivilStatus.dispose();
    _reporteeBirthdayController.dispose();
    _reporteeHomePhone.dispose();
    _reporteeMobilePhone.dispose();
    _reporteeAlternateMobilePhone.dispose();
    _reporteeEmail.dispose();
    _reporteeRegion.dispose();
    _reporteeProvince.dispose();
    _reporteeCity.dispose();
    _reporteeBarangay.dispose();
    _reporteeVillageSitio.dispose();
    _reporteeStreetHouseNum.dispose();
    _reporteeAltRegion.dispose();
    _reporteeAltProvince.dispose();
    _reporteeAltCityTown.dispose();
    _reporteeAltBarangay.dispose();
    _reporteeAltVillageSitio.dispose();
    _reporteeAltStreetHouseNum.dispose();
    _reporteeHighestEduc.dispose();
    _reporteeOccupation.dispose();
    _reporteeID.dispose();
    _reporteePhoto.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
  /* END OF VARIABLES AND CONTROLLERS */

  // initialize ImagePicker
  final ImagePicker _picker = ImagePicker();

  Future<File?> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    final File? file = File(image!.path);
    return file;
  }

  // error message: empty field
  static const String _emptyFieldError = 'Field cannot be empty';

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
            Container(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Page 2 of 6: Reportee Details',
                style: optionStyle,
              ),
            ),
            // SECTION: Relationship to Missing Person
            _verticalPadding,
            const Text(
              "Your relationship to Missing Person*",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeRelationshipToMissingPerson,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_relationshipToMP', text);
                        _writeToPrefs('p2_relationshipToMP', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Relationship to Missing Person*',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding, // Page 1 Text
            // add padding between rows
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
            // Section: Reportee Name [REMOVED]
            // Section: Reportee Citizenship
            const Text(
              "Citizenship",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeCitizenship,
                    onChanged: (text) {
                      setState(() {
                        _prefs.setString('p2_citizenship', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Citizenship*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            _verticalPadding,
            // Section: Sex [REMOVED]
            // Section: Civil Status
            const Text(
              "Civil Status",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // dropdown for civil status and update _civilStatusValue
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: DropdownButtonFormField<String>(
                // text to display when no value is selected
                hint: const Text("Select Civil Status"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: _civilStatusValue,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black54),
                onChanged: (String? newValue) {
                  setState(() {
                    _civilStatusValue = newValue;
                    // _prefs.setString('p2_civil_status', _civilStatusValue!);
                    _writeToPrefs('p2_civil_status', _civilStatusValue!);
                  });
                },
                items: <String>[
                  'Single',
                  'Married',
                  'Widowed',
                  'Separated',
                  'Divorced',
                  'Annulled',
                  'Common Law'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            _verticalPadding,
            // Section: Date of Birth [REMOVED]
            // Section: Contact Information
            const Text(
              "Contact Information",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // text fields for Home Phone, Mobile Phone, Alternate Mobile Phone, Email Address
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeHomePhone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_homePhone', text);
                        _writeToPrefs('p2_homePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Home Phone*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeMobilePhone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_mobilePhone', text);
                        _writeToPrefs('p2_mobilePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mobile Phone*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Alternate Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeAlternateMobilePhone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_altMobilePhone', text);
                        _writeToPrefs('p2_altMobilePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Alternate Mobile Phone',
                    ),
                  ),
                ),
                _verticalPadding,
                // Email Address [REMOVED]
              ],
            ),
            _verticalPadding,
            // SECTION: Address
            const Text(
              "Address*",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // text fiels for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Region
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeRegion,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_region', text);
                        _writeToPrefs('p2_region', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Region*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Province
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeProvince,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_province', text);
                        _writeToPrefs('p2_province', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Province*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Town/City
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeCity,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_townCity', text);
                        _writeToPrefs('p2_townCity', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Town/City*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Barangay
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeBarangay,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_barangay', text);
                        _writeToPrefs('p2_barangay', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Barangay*',
                    ),
                  ),
                ),
                _verticalPadding,
                // Village/Sitio
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeVillageSitio,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_villageSitio', text);
                        _writeToPrefs('p2_villageSitio', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Village/Sitio',
                    ),
                  ),
                ),
                _verticalPadding,
                // House Number/Street
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeStreetHouseNum,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_streetHouseNum', text);
                        _writeToPrefs('p2_streetHouseNum', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'House Number/Street*',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            // ask if user has alternate address if yes, show another section for alternate address
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Do you have an alternate address?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            _verticalPadding,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Yes
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        reportee_AltAddress_available = true;
                      });
                    },
                    child: const Text('Yes'),
                  ),
                ),

                // No
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        reportee_AltAddress_available = false;
                        // if reportee_AltAddress_available is false, clear all the alternate address from shared preferences
                        _prefs.remove('p2_altRegion');
                        _prefs.remove('p2_altProvince');
                        _prefs.remove('p2_altTownCity');
                        _prefs.remove('p2_altBarangay');
                        _prefs.remove('p2_altVillageSitio');
                        _prefs.remove('p2_altStreetHouseNum');
                      });
                    },
                    child: const Text('No'),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            if (reportee_AltAddress_available == true)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Alternate Address, ask for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
                  const Text(
                    "Alternate Address",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  _verticalPadding,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Region
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltRegion,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altRegion', text);
                              _writeToPrefs('p2_altRegion', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Region*',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Province
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltProvince,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altProvince', text);
                              _writeToPrefs('p2_altProvince', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Province*',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Town/City
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltCityTown,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altTownCity', text);
                              _writeToPrefs('p2_altTownCity', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Town/City*',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Barangay
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltBarangay,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altBarangay', text);
                              _writeToPrefs('p2_altBarangay', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Barangay*',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Village/Sitio
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltVillageSitio,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altVillageSitio', text);
                              _writeToPrefs('p2_altVillageSitio', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Village/Sitio',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // House Number/Street
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextFormField(
                          controller: _reporteeAltStreetHouseNum,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altStreetHouseNum', text);
                              _writeToPrefs('p2_altStreetHouseNum', text);
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'House Number/Street',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // // ask if user has alternate address if yes, add another section for alternate address
            // // this should be radio button
            // const Text(
            //   "Do you have an alternate address? ",
            //   style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black54),
            // ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     // Alternate Address
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width - 50,
            //       child: TextFormField(
            //         decoration: const InputDecoration(
            //           border: OutlineInputBorder(),
            //           labelText: 'Alternate Address (Enter NA if none)',
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            _verticalPadding,
            // SECTION: Highest Educational Attainment
            const Text(
              "Highest Educational Attainment",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // dropdown for highest educational attainment (elementary, high school, college, etc.)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Highest Educational Attainment',
                    ),
                    items:
                        // const [
                        //   DropdownMenuItem(
                        //     value: "Elementary",
                        //     child: Text("Elementary"),
                        //   ),
                        //   DropdownMenuItem(
                        //     value: "High School",
                        //     child: Text("High School"),
                        //   ),
                        //   DropdownMenuItem(
                        //     value: "College",
                        //     child: Text("College"),
                        //   ),
                        //   DropdownMenuItem(
                        //     value: "Vocational",
                        //     child: Text("Vocational"),
                        //   ),
                        //   DropdownMenuItem(
                        //     value: "Graduate Studies",
                        //     child: Text("Graduate Studies"),
                        //   ),
                        // ],
                        <String>[
                      'Elementary',
                      'High School',
                      'Vocational',
                      'College',
                      'Graduate Studies',
                      'Unknown',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _highestEduc = value.toString();
                        // _prefs.setString('p2_highestEduc', _highestEduc!);
                        _writeToPrefs('p2_highestEduc', _highestEduc!);
                      });
                    },
                    value: _highestEduc,
                  ),
                ),
              ],
            ),
            // SECTION: Occupation
            const Text(
              "Occupation",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // textfield for occupation
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    controller: _reporteeOccupation,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_occupation', text);
                        _writeToPrefs('p2_occupation', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Occupation',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            // SECTION: Proof of Identity
            const Text(
              "Proof of Identity: Upload ID*",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // use image picker to upload ID
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (reportee_ID_Photo != null)
                  Center(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * .9,
                          child:
                              Image.memory(reportee_ID_Photo!))), // show image
                ElevatedButton(
                    onPressed: () {
                      getImages();
                    },
                    child: const Text("Upload ID")),
              ],
            ),
            _verticalPadding,
            // SECTION: Photograph of Reportee
            const Text(
              "Photograph of Reportee*",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            // use image picker to upload photo of reportee
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (singlePhoto_face != null)
                  Center(
                      child: Container(
                          color: Colors.red,
                          alignment: Alignment.center,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: Image.memory(
                                  singlePhoto_face!)))), // show image
                ElevatedButton(
                    onPressed: () {
                      getImageFace();
                    },
                    child: const Text("Take Selfie")),
              ],
            ),
            _verticalPadding,

            // "Swipe Right to Move to Next Page"
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "End of Reportee Details Form. Swipe left to move to next page",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            // DEBUG TOOL: SHARED PREF PRINTER
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                print(prefs.getKeys());
                print(prefs.getString('p2_highestEduc'));
              },
              child: const Text('Print Shared Preferences'),
            ),
          ],
        ),
      ),
    ]);
  } // end of build
}
