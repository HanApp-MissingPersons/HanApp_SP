import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
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
  // const Page2ReporteeDetails({Key? key, required void Function() addHeightParent, required void Function() subtractHeightParent}) : super(key: key);
  final VoidCallback addHeightParent;
  final VoidCallback subtractHeightParent;
  final VoidCallback defaultHeightParent;
  const Page2ReporteeDetails(
      {super.key,
      required this.addHeightParent,
      required this.subtractHeightParent,
      required this.defaultHeightParent});

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
    String? singlePhotoStringFace = _prefs.getString('p2_reporteeSelfie');
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
      _prefs.setString('p2_reporteeSelfie', base64Encode(singlePhoto_face!));
    }
  }

  Future<void> getImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _writeToPrefs('p2_reportee_ID_Photo_PATH', file.path);
      });
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
      final file = File(pickedFileFace.path);
      setState(() {
        _writeToPrefs('p2_reporteeSelfie_PATH', file.path);
      });
      final imageBytesFace = await pickedFileFace.readAsBytes();
      setState(() {
        singlePhoto_face = imageBytesFace;
      });
      await saveImages();
    }
  }

  bool isDrafted = false;
  Future<void> getReporteeInfo() async {
    _prefs = await SharedPreferences.getInstance();
    loadImages();
    loadImage_face();
    setState(() {
      widget.defaultHeightParent();
      reportee_hasAltAddress = _prefs.getBool('p2_hasAltAddress') ?? false;
      reportee_hasAltAddress ? widget.addHeightParent() : null;
      // default is false
      // isDrafted = _prefs.getBool('isDrafted') ?? false;
      // isDrafted ? widget.defaultHeightParent() : null;
      // bool check = _prefs.getBool('p2_hasAltAddress') ?? false;
      // reportee_hasAltAddress =
      //     !isDrafted ? _prefs.getBool('p2_hasAltAddress') ?? false : false;
      // _civilStatusValue = _prefs.getString('p2_civil_status') ?? 'Single';
      // if (_prefs.getString('p2_civil_status') == null) {
      //   _prefs.setString('p2_civil_status', 'Single');
      // } else {
      //   _civilStatusValue = _prefs.getString('p2_civil_status') ?? 'Single';
      // }
      if (_prefs.getString('p2_civil_status') != null) {
        _civilStatusValue = _prefs.getString('p2_civil_status');
      }

      // _highestEduc = _prefs.getString('p2_highestEduc') ?? 'Unknown';
      // if (_prefs.getString('p2_highestEduc') == null) {
      //   _prefs.setString('p2_highestEduc', 'Unknown');
      // } else {
      //   _highestEduc = _prefs.getString('p2_highestEduc') ?? 'Unknown';
      // }
      if (_prefs.getString('p2_highestEduc') != null) {
        _highestEduc = _prefs.getString('p2_highestEduc');
      }

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
      await _prefs.setString(key, value);
    } else {
      await _prefs.remove(key);
    }
  }

  /* FORMATTING STUFF */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87);

  static const TextStyle headingStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54);

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
  // For alternative addres
  bool reportee_hasAltAddress = false;
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

  String? _civilStatusValue;
  DateTime? dateTimeBday;

  String? _highestEduc;

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

  // error message: empty field
  static const String _emptyFieldError = 'Field cannot be empty';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Checkboxes for classifiers
      Positioned(
        top: MediaQuery.of(context).size.height / 8,
        left: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 10,
              child: const Text(
                'Page 2 of 6: Reportee Details',
                style: optionStyle,
              ),
            ),
            _verticalPadding,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline_rounded, size: 20),
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
            // SECTION: Relationship to Missing Person
            _verticalPadding,
            const Text(
              "Relationship to Missing Person*",
              style: headingStyle,
            ),
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 30,
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
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      //labelText: 'Relationship to Missing Person*',
                      hintText: 'ex: Sibling, Relative, Spouse, etc.',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding, // Page 1 Text
            // add padding between rows

            // Section: Reportee Name [REMOVED]
            // Section: Reportee Citizenship
            const Text(
              "Citizenship*",
              style: headingStyle,
            ),
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 30,
                    controller: _reporteeCitizenship,
                    onChanged: (text) {
                      setState(() {
                        _writeToPrefs('p2_citizenship', text);
                        // _prefs.setString('p2_citizenship', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      //labelText: 'Citizenship*',
                      hintText: 'ex: Filipino',
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
              style: headingStyle,
            ),
            _verticalPadding,
            // dropdown for civil status and update _civilStatusValue
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: DropdownButtonFormField<String>(
                // text to display when no value is selected
                hint: const Text("Select Civil Status*"),
                decoration: const InputDecoration(
                  hintText: 'Select Civil Status*',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
                  'Common Law',
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
              style: headingStyle,
            ),
            _verticalPadding,
            // text fields for Home Phone, Mobile Phone, Alternate Mobile Phone, Email Address
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeHomePhone,
                    keyboardType: TextInputType.phone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_homePhone', text);
                        _writeToPrefs('p2_homePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Home Phone/Landline*',
                      hintText: 'XXX-XXXX',
                    ),
                  ),
                ),
                _verticalPadding,
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  alignment: Alignment.center,
                  child: const Text(
                    'or',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                _verticalPadding,
                // Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeMobilePhone,
                    keyboardType: TextInputType.phone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_mobilePhone', text);
                        _writeToPrefs('p2_mobilePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Mobile Phone*',
                      hintText: '09XXXXXXXXX',
                    ),
                  ),
                ),
                _verticalPadding,
                // Alternate Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeAlternateMobilePhone,
                    keyboardType: TextInputType.phone,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_altMobilePhone', text);
                        _writeToPrefs('p2_altMobilePhone', text);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Alternate Mobile Phone (if any)',
                      hintText: '09XXXXXXXXX',
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
              "Address",
              style: headingStyle,
            ),
            _verticalPadding,
            // text fiels for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Region
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeRegion,
                    maxLength: 30,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_region', text);
                        _writeToPrefs('p2_region', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: 'Region*',
                        hintText: 'ex: Region VI'),
                  ),
                ),
                _verticalPadding,
                // Province
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 30,
                    controller: _reporteeProvince,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_province', text);
                        _writeToPrefs('p2_province', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Province*',
                      hintText: 'ex: Iloilo',
                    ),
                  ),
                ),
                _verticalPadding,
                // Town/City
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeCity,
                    maxLength: 30,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_townCity', text);
                        _writeToPrefs('p2_townCity', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Municipality/City*',
                      hintText: 'ex: Iloilo City',
                    ),
                  ),
                ),
                _verticalPadding,
                // Barangay
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _reporteeBarangay,
                    maxLength: 30,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_barangay', text);
                        _writeToPrefs('p2_barangay', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Barangay*',
                      hintText: 'ex: Brgy. San Jose',
                    ),
                  ),
                ),
                _verticalPadding,
                // Village/Sitio
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 30,
                    controller: _reporteeVillageSitio,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_villageSitio', text);
                        _writeToPrefs('p2_villageSitio', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Village, Sitio, Subdivision',
                      hintText: 'ex: Sitio Talahib',
                    ),
                  ),
                ),
                _verticalPadding,
                // House Number/Street
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 30,
                    controller: _reporteeStreetHouseNum,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_streetHouseNum', text);
                        _writeToPrefs('p2_streetHouseNum', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'House Number/Street*',
                      hintText: 'ex: 123 Street',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,

            const Text(
              'Alternate Address',
              style: headingStyle,
            ),
            // ask if user has alternate address if yes, show another section for alternate address
            Row(
              children: [
                Checkbox(
                  value: reportee_hasAltAddress,
                  onChanged: (bool? value) {
                    setState(() {
                      reportee_hasAltAddress = value!;
                      if (value == true) {
                        widget.addHeightParent();
                      } else {
                        widget.subtractHeightParent();
                      }
                      // set bool in prefs
                      _prefs.setBool('p2_hasAltAddress', value);
                    });
                  },
                ),
                const Text(
                  'Do you have another house location/address?',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),

            if (reportee_hasAltAddress)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alternate Address, ask for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Region
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          maxLength: 30,
                          controller: _reporteeAltRegion,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altRegion', text);
                              _writeToPrefs('p2_altRegion', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Region',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Province
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          maxLength: 30,
                          controller: _reporteeAltProvince,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altProvince', text);
                              _writeToPrefs('p2_altProvince', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Province',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Town/City
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          maxLength: 30,
                          controller: _reporteeAltCityTown,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altTownCity', text);
                              _writeToPrefs('p2_altTownCity', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Municipality/City',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Barangay
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          controller: _reporteeAltBarangay,
                          maxLength: 30,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altBarangay', text);
                              _writeToPrefs('p2_altBarangay', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Barangay',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // Village/Sitio
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          maxLength: 50,
                          controller: _reporteeAltVillageSitio,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altVillageSitio', text);
                              _writeToPrefs('p2_altVillageSitio', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Village, Sitio, Subdivision',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // House Number/Street
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: TextFormField(
                          maxLength: 50,
                          controller: _reporteeAltStreetHouseNum,
                          onChanged: (text) {
                            setState(() {
                              // _prefs.setString('p2_altStreetHouseNum', text);
                              _writeToPrefs('p2_altStreetHouseNum', text);
                            });
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'House Number/Street',
                          ),
                        ),
                      ),
                      _verticalPadding,
                      _verticalPadding,
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
              style: headingStyle,
            ),
            _verticalPadding,
            // dropdown for highest educational attainment (elementary, high school, college, etc.)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: DropdownButtonFormField<String>(
                    value: _highestEduc,
                    hint: const Text('Select Highest Educational Attainment*'),
                    decoration: const InputDecoration(
                      hintText: 'Select Highest Educational Attainment*',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black54),
                    items: <String>[
                      'Elementary',
                      'High School',
                      'Vocational',
                      'College',
                      'Graduate Studies',
                      'Unknown',
                    ].map<DropdownMenuItem<String>>((String newValue) {
                      return DropdownMenuItem<String>(
                        value: newValue,
                        child: Text(newValue),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _highestEduc = value.toString();
                        // _prefs.setString('p2_highestEduc', _highestEduc!);
                        _writeToPrefs('p2_highestEduc', _highestEduc!);
                      });
                    },
                  ),
                ),
              ],
            ),
            _verticalPadding,
            // SECTION: Occupation
            const Text(
              "Occupation",
              style: headingStyle,
            ),
            _verticalPadding,
            // textfield for occupation
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    maxLength: 20,
                    controller: _reporteeOccupation,
                    onChanged: (text) {
                      setState(() {
                        // _prefs.setString('p2_occupation', text);
                        _writeToPrefs('p2_occupation', text);
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      counterText: '',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Occupation',
                    ),
                  ),
                ),
              ],
            ),
            _verticalPadding,
            _verticalPadding,
            // SECTION: Proof of Identity
            const Text(
              "Proof of Identity",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _verticalPadding,
            Row(
              children: [
                const Text(
                  "Identification Card/Document*",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black38,
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerLeft,
                  icon: Icon(Icons.info_outline, color: Colors.indigo[500]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: const Text("Valid IDs"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  // width: 300,
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.grey[200],
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    children: const [
                                      Text(
                                        'A Valid ID can be any (but are not limited to) Government-issued ID, Company ID, or a Student ID.',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Some valid ID examples:',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  // height: 200,
                                  height:
                                      MediaQuery.of(context).size.height - 400,
                                  // width: 300,
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: const [
                                      ListTile(
                                        leading: Icon(Icons.book),
                                        title: Text("Passport"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.drive_eta),
                                        title: Text("Driver's License"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.credit_card),
                                        title: Text(
                                            "Unified Multi-purpose Identification (UMID) Card"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.person),
                                        title: Text(
                                            "Social Security System (SSS) ID"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.work),
                                        title: Text(
                                            "Government Service Insurance System (GSIS) ID"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.healing),
                                        title: Text("PhilHealth ID"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.markunread_mailbox),
                                        title: Text("Postal ID"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.school),
                                        title: Text(
                                            "Professional Regulation Commission (PRC) ID"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.how_to_vote),
                                        title: Text("Voter's ID"),
                                      ),
                                      ListTile(
                                        leading:
                                            Icon(Icons.confirmation_number),
                                        title: Text(
                                            "Tax Identification Number (TIN) ID"),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.info_rounded,
                                        color: Colors.grey,
                                        size: 14,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Scroll to view examples',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                child: Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            // use image picker to upload ID
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reportee_ID_Photo != null
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: Image.memory(
                          reportee_ID_Photo!,
                          height: 200,
                        ))
                    : Column(
                        children: [
                          Icon(
                            Icons.perm_identity,
                            size: 200,
                            color: Colors.grey[200],
                          ),
                          Text("No ID Selected",
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ), // show image
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: ElevatedButton(
                      onPressed: () {
                        getImages();
                      },
                      child: const Text("Upload ID")),
                ),
              ],
            ),
            _verticalPadding,
            // SECTION: Photograph of Reportee
            const Text(
              "Photograph of Reportee*",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
              ),
            ),
            // use image picker to upload photo of reportee
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                singlePhoto_face != null
                    ? Center(
                        child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * .9,
                            child: Image.memory(
                              singlePhoto_face!,
                              height: 300,
                            )))
                    : Container(
                        margin: const EdgeInsets.only(top: 40, bottom: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_front_outlined,
                              size: 200,
                              color: Colors.grey[200],
                            ),
                            const Text('No selfie taken',
                                style: TextStyle(color: Colors.grey))
                          ],
                        )), // show image
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: ElevatedButton(
                      onPressed: () {
                        getImageFace();
                      },
                      child: const Text("Take Selfie")),
                ),
              ],
            ),
            _verticalPadding,
            // "Swipe Right to Move to Next Page"
            // SizedBox(
            //   width: MediaQuery.of(context).size.width - 30,
            //   child: const Text(
            //     "End of Reportee Details Form. Swipe left to move to next page",
            //     style: TextStyle(fontSize: 12, color: Colors.black54),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Lottie.asset("assets/lottie/swipeLeft.json",
                    animate: true,
                    width: MediaQuery.of(context).size.width * 0.15),
                const SizedBox(width: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    '\nEnd of Reportee Details Form \nSwipe left to continue.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            // DEBUG TOOL: SHARED PREF PRINTER
            // TextButton(
            //   onPressed: () async {
            //     final prefs = await SharedPreferences.getInstance();
            //     print(prefs.getKeys());
            //     print(prefs.getString('p2_highestEduc'));
            //   },
            //   child: const Text('Print Shared Preferences'),
            // ),
          ],
        ),
      ),
    ]);
  } // end of build
}
