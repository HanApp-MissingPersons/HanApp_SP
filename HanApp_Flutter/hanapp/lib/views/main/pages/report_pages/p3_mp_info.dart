/* IMPORTS */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'p1_classifier.dart';

/* SHARED PREFERENCE */
late SharedPreferences _prefs;
void clearPrefs() {
  _prefs.clear();
}

/* DATE AND FORMATTER */
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
  var returnVal = '$month $day, $year';
  return [returnVal, age];
}

/* PAGE 3 */
class Page3MPDetails extends StatefulWidget {
  final VoidCallback addHeightParent;
  final VoidCallback subtractHeightParent;
  const Page3MPDetails(
      {super.key,
      required this.addHeightParent,
      required this.subtractHeightParent});

  @override
  State<Page3MPDetails> createState() => _Page3MPDetailsState();
}

/* PAGE 3 STATE */
// skeleton, prints only "page 3"
class _Page3MPDetailsState extends State<Page3MPDetails> {
  /* FORMATTERS */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87);

  static const _verticalPadding = SizedBox(height: 10);

  static const TextStyle headingStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54);

  /* CONTROLLERS */
  // for basic info
  late final TextEditingController _mp_lastName = TextEditingController();
  late final TextEditingController _mp_firstName = TextEditingController();
  late final TextEditingController _mp_middleName = TextEditingController();
  late final TextEditingController _mp_qualifier = TextEditingController();
  late final TextEditingController _mp_nickname = TextEditingController();
  late final TextEditingController _mp_citizenship = TextEditingController();
  late final TextEditingController _mp_nationalityEthnicity =
      TextEditingController();
  late final TextEditingController _mp_sex = TextEditingController();
  late final TextEditingController _mp_civilStatus = TextEditingController();
  late final TextEditingController _mp_birthDate;
  late final TextEditingController _mp_age = TextEditingController();
  // for contact info
  late final TextEditingController _mp_contact_homePhone =
      TextEditingController();
  late final TextEditingController _mp_contact_mobilePhone =
      TextEditingController();
  late final TextEditingController _mp_contact_mobilePhone_alt =
      TextEditingController();
  late final TextEditingController _mp_contact_email = TextEditingController();
  // for address
  late final TextEditingController _mp_address_region = TextEditingController();
  late final TextEditingController _mp_address_province =
      TextEditingController();
  late final TextEditingController _mp_address_city = TextEditingController();
  late final TextEditingController _mp_address_barangay =
      TextEditingController();
  late final TextEditingController _mp_address_villageSitio =
      TextEditingController();
  late final TextEditingController _mp_address_streetHouseNum =
      TextEditingController();
  // for alternate address
  bool mp_hasAltAddress = false;
  late final TextEditingController _mp_address_region_alt =
      TextEditingController();
  late final TextEditingController _mp_address_province_alt =
      TextEditingController();
  late final TextEditingController _mp_address_city_alt =
      TextEditingController();
  late final TextEditingController _mp_address_barangay_alt =
      TextEditingController();
  late final TextEditingController _mp_address_villageSitio_alt =
      TextEditingController();
  late final TextEditingController _mp_address_streetHouseNum_alt =
      TextEditingController();
  // for ocupation and highest education
  late final TextEditingController _mp_education = TextEditingController();
  late final TextEditingController _mp_occupation = TextEditingController();
  // for Work/School Address
  bool mp_hasSchoolWorkAddress = false;
  late final TextEditingController _mp_workSchool_region =
      TextEditingController();
  late final TextEditingController _mp_workSchool_province =
      TextEditingController();
  late final TextEditingController _mp_workSchool_city =
      TextEditingController();
  late final TextEditingController _mp_workSchool_barangay =
      TextEditingController();
  late final TextEditingController _mp_workSchool_villageSitio =
      TextEditingController();
  late final TextEditingController _mp_workSchool_streetHouseNum =
      TextEditingController();
  late final TextEditingController _mp_workSchool_name =
      TextEditingController();

  /* VARIABLES */
  String? ageFromMPBirthDate;
  DateTime? dateTimeMPBirthDate;
  bool? hasAlternateAddress = false; // initialize hasAlternateAddress to false
  String? sexValue;
  String? mp_civilStatValue;
  int age_value = 0;
  String? mp_educationalAttainment;

  /* SHARED PREF EMPTY CHECKER AND SAVER FUNCTION*/
  Future<void> _writeToPrefs(String key, String value) async {
    if (value != '') {
      _prefs.setString(key, value);
    } else {
      _prefs.remove(key);
    }
  }

  /* INITIALIZE CONTROLLERS */
  @override
  void initState() {
    _mp_birthDate = TextEditingController();
    super.initState();
    // shared preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        // basic info
        mp_civilStatValue =
            prefs.getString('p3_mp_civilStatus') ?? 'Common Law';
        sexValue = prefs.getString('p3_mp_sex') ?? '';
        _mp_lastName.text = prefs.getString('p3_mp_lastName') ?? '';
        _mp_firstName.text = prefs.getString('p3_mp_firstName') ?? '';
        _mp_middleName.text = prefs.getString('p3_mp_middleName') ?? '';
        _mp_qualifier.text = prefs.getString('p3_mp_qualifier') ?? '';
        _mp_nickname.text = prefs.getString('p3_mp_nickname') ?? '';
        _mp_citizenship.text = prefs.getString('p3_mp_citizenship') ?? '';
        _mp_nationalityEthnicity.text =
            prefs.getString('p3_mp_nationalityEthnicity') ?? '';
        _mp_sex.text = prefs.getString('p3_mp_sex') ?? '';
        _mp_civilStatus.text = prefs.getString('p3_mp_civilStatus') ?? '';
        _mp_birthDate.text = prefs.getString('p3_mp_birthDate') ?? '';
        ageFromMPBirthDate = prefs.getString('p3_mp_age') ?? '';
        _mp_age.text = prefs.getString('p3_mp_age') ?? '';
        // for contact info
        _mp_contact_homePhone.text =
            prefs.getString('p3_mp_contact_homePhone') ?? '';
        _mp_contact_mobilePhone.text =
            prefs.getString('p3_mp_contact_mobilePhone') ?? '';
        _mp_contact_mobilePhone_alt.text =
            prefs.getString('p3_mp_contact_mobilePhone_alt') ?? '';
        _mp_contact_email.text = prefs.getString('p3_mp_contact_email') ?? '';
        // for address
        _mp_address_region.text = prefs.getString('p3_mp_address_region') ?? '';
        _mp_address_province.text =
            prefs.getString('p3_mp_address_province') ?? '';
        _mp_address_city.text = prefs.getString('p3_mp_address_city') ?? '';
        _mp_address_barangay.text =
            prefs.getString('p3_mp_address_barangay') ?? '';
        _mp_address_villageSitio.text =
            prefs.getString('p3_mp_address_villageSitio') ?? '';
        _mp_address_streetHouseNum.text =
            prefs.getString('p3_mp_address_streetHouseNum') ?? '';
        // for alternate address
        _mp_address_region_alt.text =
            prefs.getString('p3_mp_address_region_alt') ?? '';
        _mp_address_province_alt.text =
            prefs.getString('p3_mp_address_province_alt') ?? '';
        _mp_address_city_alt.text =
            prefs.getString('p3_mp_address_city_alt') ?? '';
        _mp_address_barangay_alt.text =
            prefs.getString('p3_mp_address_barangay_alt') ?? '';
        _mp_address_villageSitio_alt.text =
            prefs.getString('p3_mp_address_villageSitio_alt') ?? '';
        _mp_address_streetHouseNum_alt.text =
            prefs.getString('p3_mp_address_streetHouseNum_alt') ?? '';
        // for ocupation and highest education
        mp_educationalAttainment = prefs.getString('p3_mp_education') ?? 'NA';
        _mp_education.text = prefs.getString('p3_mp_education') ?? 'None';
        _mp_occupation.text = prefs.getString('p3_mp_occupation') ?? '';
        // for Work/School Address
        _mp_workSchool_region.text =
            prefs.getString('p3_mp_workSchool_region') ?? '';
        _mp_workSchool_province.text =
            prefs.getString('p3_mp_workSchool_province') ?? '';
        _mp_workSchool_city.text =
            prefs.getString('p3_mp_workSchool_city') ?? '';
        _mp_workSchool_barangay.text =
            prefs.getString('p3_mp_workSchool_barangay') ?? '';
        _mp_workSchool_villageSitio.text =
            prefs.getString('p3_mp_workSchool_villageSitio') ?? '';
        _mp_workSchool_streetHouseNum.text =
            prefs.getString('p3_mp_workSchool_streetHouseNum') ?? '';
        _mp_workSchool_name.text =
            prefs.getString('p3_mp_workSchool_name') ?? '';
        // for mp_hasAltAddress and mp_hasSchoolWorkAddress bool
        mp_hasAltAddress = _prefs.getBool('p3_mp_hasAltAddress') ?? false;
        mp_hasSchoolWorkAddress =
            _prefs.getBool('p3_mp_hasSchoolWorkAddress') ?? false;
      });
    });
  }

  /* DISPOSE CONTROLLERS */
  @override
  void dispose() {
    _mp_birthDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: MediaQuery.of(context).size.height / 8,
          left: 20,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Page 3 of 6: Absent/Missing Person Details',
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
            // ABSENT/MISSING PERSON NAME SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Absent/Missing Person Name',
                style: headingStyle,
              ),
            ),
            _verticalPadding,
            // textfields for absent/missing person name
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //last name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_lastName,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Last Name*",
                        hintText: "Dela Cruz",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        // _prefs.setString('p3_mp_lastName', value);
                        _writeToPrefs('p3_mp_lastName', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // firstname (same format as above)
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_firstName,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "First Name*",
                        hintText: "Juan",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        // _prefs.setString('p3_mp_firstName', value);
                        // // if value is '', clear from prefs
                        // if (value == '') {
                        //   _prefs.remove('p3_mp_firstName');
                        // }
                        // if (value != '') {
                        //   _prefs.setString('p3_mp_firstName', value);
                        // } else {
                        //   _prefs.remove('p3_mp_firstName');
                        // }
                        _writeToPrefs('p3_mp_firstName', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // middlename (same format as above)
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_middleName,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Middle Name",
                        hintText: "Pedro",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        // _prefs.setString('p3_mp_middleName', value);
                        _writeToPrefs('p3_mp_middleName', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // qualifier
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_qualifier,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Qualifier",
                        hintText: "Jr.",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        // _prefs.setString('p3_mp_qualifier', value);
                        _writeToPrefs('p3_mp_qualifier', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // nickname/known aliases
            _verticalPadding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_nickname,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Nickname / Known Aliases",
                        hintText: "Nickname / Known Aliases",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        // _prefs.setString('p3_mp_nickname', value);
                        _writeToPrefs('p3_mp_nickname', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // CITIZENSHIP SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Citizenship*',
                style: headingStyle,
              ),
            ),
            _verticalPadding,
            // textfield for citizenship:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_citizenship,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: "Filipino",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _writeToPrefs('p3_mp_citizenship', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // NATIONALITY/ETHNICITY SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Nationality/Ethnicity*',
                style: headingStyle,
              ),
            ),
            _verticalPadding,
            // textfield for nationality/ethnicity
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _mp_nationalityEthnicity,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Nationality/Ethnicity*",
                        hintText: "Asian, Hispanic, Latino, etc.",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _writeToPrefs('p3_mp_nationalityEthnicity', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // SEX SECTION
            _verticalPadding,
            // rows for Male and Female radio buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 40,
                  child: Text(
                    'Sex*',
                    style: headingStyle,
                  ),
                ),
                //male
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: RadioListTile(
                    title: const Text("Male"),
                    value: "Male",
                    groupValue: sexValue,
                    onChanged: (value) {
                      setState(() {
                        sexValue = value;
                        // _prefs.setString('p3_mp_sex', value!);
                        _writeToPrefs('p3_mp_sex', value!);
                      });
                    },
                  ),
                ),
                //female
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: RadioListTile(
                    title: const Text("Female"),
                    value: "Female",
                    groupValue: sexValue,
                    onChanged: (value) {
                      setState(() {
                        sexValue = value;
                        // _prefs.setString('p3_mp_sex', value!);
                        _writeToPrefs('p3_mp_sex', value!);
                      });
                    },
                  ),
                ),
              ],
            ),
            // CIVIL STATUS SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Civil Status',
                style: headingStyle,
              ),
            ),
            // dropdown for civil status
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: DropdownButtonFormField<String>(
                hint: const Text("Select Civil Status*"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                value: mp_civilStatValue,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black54),
                onChanged: (String? newValue) {
                  setState(() {
                    mp_civilStatValue = newValue;
                    // _prefs.setString('p3_mp_civilStatus', newValue!);
                    _writeToPrefs('p3_mp_civilStatus', newValue!);
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
            // ABSENT/MISSING PERSON BIRTHDATE SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Birth Date*',
                style: headingStyle,
              ),
            ),
            // date picker widget
            _verticalPadding,
            SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  controller: _mp_birthDate,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      labelText: "Birth Date*",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  onTap: () async {
                    FocusScope.of(context)
                        .requestFocus(FocusNode()); // hide keyboard
                    var pickedDate = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                          firstDate: DateTime(1900), lastDate: DateTime.now()),
                      dialogSize: const Size(325, 400),
                      value: [DateTime.now()],
                      borderRadius: BorderRadius.circular(15),
                    );
                    // get variable selectedDate type
                    dateTimeMPBirthDate = pickedDate![0];
                    var stringDatetimempbirthdate =
                        dateTimeMPBirthDate.toString();
                    List returnVal = reformatDate(
                        stringDatetimempbirthdate, dateTimeMPBirthDate!);
                    String reformattedMPBirthDate = returnVal[0];
                    ageFromMPBirthDate = returnVal[1];
                    // save picked date to text field
                    _mp_birthDate.text = reformattedMPBirthDate;
                    // save to shared preferences using onChanged
                    // _prefs.setString('p3_mp_birthDate', _mp_birthDate.text);
                    _writeToPrefs('p3_mp_birthDate', _mp_birthDate.text);
                    // also save age to shared preferences
                    // _prefs.setString('p3_mp_age', ageFromMPBirthDate!);
                    _writeToPrefs('p3_mp_age', ageFromMPBirthDate!);
                    // age controller update (to auto-fill age form field)
                    _mp_age.text = ageFromMPBirthDate!;
                    // from p1_classifier.dart, validator for p1_isMinor (<18)
                    if (int.parse(ageFromMPBirthDate!) < 18) {
                      _prefs.setBool('p1_isMinor', true);
                    } else {
                      _prefs.setBool('p1_isMinor', false);
                    }
                  },
                )),
            // AGE SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Age*',
                style: headingStyle,
              ),
            ),
            // pre-filled out and grayed out text field for age
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                controller: _mp_age,
                enabled: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Age (auto-computed)",
                ),
                // auto-fill age from birthdate using _mp_age.text
                onChanged: (value) {
                  // _prefs.setString('p3_mp_age', value);
                  _writeToPrefs('p3_mp_age', value);
                },
              ),
            ),
            _verticalPadding,
            // CONTACT INFO SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Contact Information',
                style: headingStyle,
              ),
            ),
            // homePhone
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_contact_homePhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Home Phone/Landline*",
                  hintText: "XXX-XXXX",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_contact_homePhone', value);
                  _writeToPrefs('p3_mp_contact_homePhone', value);
                },
              ),
            ),
            _verticalPadding,
            SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text('or',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center)),
            // mobilePhone
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_contact_mobilePhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Mobile Phone*",
                  hintText: "09XXXXXXXXX",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_contact_mobilePhone', value);
                  _writeToPrefs('p3_mp_contact_mobilePhone', value);
                },
              ),
            ),
            // alternate mobile phone
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_contact_mobilePhone_alt,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Alternate Mobile Phone",
                  hintText: "09XXXXXXXXX",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_contact_mobilePhone_alt', value);
                  _writeToPrefs('p3_mp_contact_mobilePhone_alt', value);
                },
              ),
            ),
            // email
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_contact_email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Email",
                  hintText: "juandelacruz@gmail.com",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_contact_email', value);
                  _writeToPrefs('p3_mp_contact_email', value);
                },
              ),
            ),
            // ADDRESS SECTION
            _verticalPadding,
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Address',
                style: headingStyle,
              ),
            ),
            // region
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_region,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Region*",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_region', value);
                  _writeToPrefs('p3_mp_address_region', value);
                },
              ),
            ),
            // province
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_province,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Province*",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_province', value);
                  _writeToPrefs('p3_mp_address_province', value);
                },
              ),
            ),
            // city
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_city,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Municipality/City*",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_city', value);
                  _writeToPrefs('p3_mp_address_city', value);
                },
              ),
            ),
            // barangay
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_barangay,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Barangay*",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_barangay', value);
                  _writeToPrefs('p3_mp_address_barangay', value);
                },
              ),
            ),
            // villageSitio
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_villageSitio,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Village, Sitio, Subdivision",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_villageSitio', value);
                  _writeToPrefs('p3_mp_address_villageSitio', value);
                },
              ),
            ),
            // streetHouseNum
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_address_streetHouseNum,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Street/House Number*",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_address_streetHouseNum', value);
                  _writeToPrefs('p3_mp_address_streetHouseNum', value);
                },
              ),
            ),
            // ALTERNATE ADDRESS SECTION
            _verticalPadding,
            // ask user if MP has an alternate address, if yes, show alternate address fields
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Alternate Address',
                style: headingStyle,
              ),
            ),

            // checkbox to ask user if MP has an alternate address
            Row(
              children: [
                Checkbox(
                  value: mp_hasAltAddress,
                  onChanged: (bool? value) {
                    setState(() {
                      mp_hasAltAddress = value!;
                      if (value == true) {
                        widget.addHeightParent();
                      } else {
                        widget.subtractHeightParent();
                      }
                      // set bool in prefs
                      _prefs.setBool('p3_mp_hasAltAddress', value);
                    });
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: const Text(
                      'Absent/Missing person has another location/alternate address',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ),
              ],
            ),

            if (mp_hasAltAddress)
              Column(
                children: [
                  // region
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_region_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Region",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_region_alt', value);
                        _writeToPrefs('p3_mp_address_region_alt', value);
                      },
                    ),
                  ),
                  // province
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_province_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Province",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_province_alt', value);
                        _writeToPrefs('p3_mp_address_province_alt', value);
                      },
                    ),
                  ),
                  // city
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_city_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Municipality/City",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_city_alt', value);
                        _writeToPrefs('p3_mp_address_city_alt', value);
                      },
                    ),
                  ),
                  // barangay
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_barangay_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Barangay",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_barangay_alt', value);
                        _writeToPrefs('p3_mp_address_barangay_alt', value);
                      },
                    ),
                  ),
                  // villageSitio
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_villageSitio_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Village, Sitio, Subdivision",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_villageSitio_alt', value);
                        _writeToPrefs('p3_mp_address_villageSitio_alt', value);
                      },
                    ),
                  ),
                  // streetHouseNum
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_address_streetHouseNum_alt,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Street/House Number",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_address_streetHouseNum_alt', value);
                        _writeToPrefs(
                            'p3_mp_address_streetHouseNum_alt', value);
                      },
                    ),
                  ),
                  _verticalPadding,
                ],
              ),
            // OCCUPATION SECTION
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Occupation',
                style: headingStyle,
              ),
            ),
            // occupation field
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: TextFormField(
                controller: _mp_occupation,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  labelText: "Occupation",
                  hintText: "Occupation",
                ),
                onChanged: (value) {
                  // _prefs.setString('p3_mp_occupation', value);
                  _writeToPrefs('p3_mp_occupation', value);
                },
              ),
            ),
            // EDUCATIONAL ATTAINMENT SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Highest Educational Attainment',
                style: headingStyle,
              ),
            ),
            // educational attainment dropdown
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: DropdownButtonFormField<String>(
                hint: const Text("Select Highest Educational Attainment"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                value: mp_educationalAttainment,
                icon: const Icon(Icons.arrow_drop_down),
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
                  'NA'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    mp_educationalAttainment = value;
                    // _prefs.setString('p3_mp_education', value!);
                    _writeToPrefs('p3_mp_education', value!);
                  });
                },
              ),
            ),
            // Current WORK/SCHOOL ADDRESS AND INFORMATION SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Current School/Work Address',
                style: headingStyle,
              ),
            ),
            // checkbox to ask if user has school/work address
            Row(
              children: [
                Checkbox(
                  value: mp_hasSchoolWorkAddress,
                  onChanged: (bool? value) {
                    setState(() {
                      mp_hasSchoolWorkAddress = value!;
                      if (value == true) {
                        widget.addHeightParent();
                      } else {
                        widget.subtractHeightParent();
                      }
                      // set bool in prefs
                      _prefs.setBool('p3_mp_hasSchoolWorkAddress', value);
                    });
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: const Text(
                    'Absent/Missing person has a current work/school address',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
            // school/work address
            if (mp_hasSchoolWorkAddress)
              Column(
                children: [
                  // region
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_region,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Region",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_region', value);
                        _writeToPrefs('p3_mp_workSchool_region', value);
                      },
                    ),
                  ),
                  // province
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_province,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Province",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_province', value);
                        _writeToPrefs('p3_mp_workSchool_province', value);
                      },
                    ),
                  ),
                  // city
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_city,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Municipality/City",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_city', value);
                        _writeToPrefs('p3_mp_workSchool_city', value);
                      },
                    ),
                  ),
                  // barangay
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_barangay,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Barangay",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_barangay', value);
                        _writeToPrefs('p3_mp_workSchool_barangay', value);
                      },
                    ),
                  ),
                  // villageSitio
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_villageSitio,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Village, Sitio, Subdivision",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_villageSitio', value);
                        _writeToPrefs('p3_mp_workSchool_villageSitio', value);
                      },
                    ),
                  ),
                  // streetHouseNum
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_streetHouseNum,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Street/House Number",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_streetHouseNum', value);
                        _writeToPrefs('p3_mp_workSchool_streetHouseNum', value);
                      },
                    ),
                  ),
                  // Work/School Name
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TextFormField(
                      controller: _mp_workSchool_name,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Work/School Name",
                      ),
                      onChanged: (value) {
                        // _prefs.setString('p3_mp_workSchool_name', value);
                        _writeToPrefs('p3_mp_workSchool_name', value);
                      },
                    ),
                  ),
                ],
              ),

            // DEBUGGER TOOL: check shared_preferences content
            // END OF PAGE
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "End of Absent/Missing Person Details Form. Swipe left to move to next page",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final prefs = await SharedPreferences.getInstance();
            //     print(prefs.getKeys());
            //     print(prefs.getString('p3_mp_birthDate'));
            //     print(prefs.getString('p3_mp_sex'));
            //     print(prefs.getString('p3_mp_civilStatus'));
            //     print(prefs.getString('p3_mp_age'));
            //     print(prefs.getString('p3_mp_education'));
            //     print(prefs.getString('p3_mp_firstName'));
            //     print(prefs.getBool('p1_isMinor'));
            //   },
            //   child: const Text('Print Shared Preferences'),
            // ),
          ]))
    ]);
  }
}
