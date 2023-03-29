/* IMPORTS */
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
  const Page3MPDetails({super.key});

  @override
  State<Page3MPDetails> createState() => _Page3MPDetailsState();
}

/* PAGE 3 STATE */
// skeleton, prints only "page 3"
class _Page3MPDetailsState extends State<Page3MPDetails> {
  /* FORMATTERS */
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);

  /* CONTROLLERS */
  // for basic info
  late final TextEditingController _mp_lastName = TextEditingController();
  late final TextEditingController _mp_firstName = TextEditingController();
  late final TextEditingController _mp_middleName = TextEditingController();
  late final TextEditingController _mp_qualifier = TextEditingController();
  late final TextEditingController _mp_nickname = TextEditingController();
  late final TextEditingController _mp_citizenship = TextEditingController();
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
        _mp_lastName.text = prefs.getString('p3_mp_lastName') ?? '';
        _mp_firstName.text = prefs.getString('p3_mp_firstName') ?? '';
        _mp_middleName.text = prefs.getString('p3_mp_middleName') ?? '';
        _mp_qualifier.text = prefs.getString('p3_mp_qualifier') ?? '';
        _mp_nickname.text = prefs.getString('p3_mp_nickname') ?? '';
        _mp_citizenship.text = prefs.getString('p3_mp_citizenship') ?? '';
        _mp_sex.text = prefs.getString('p3_mp_sex') ?? '';
        _mp_civilStatus.text = prefs.getString('p3_mp_civilStatus') ?? '';
        _mp_birthDate.text = prefs.getString('p3_mp_birthDate') ?? '';
        ageFromMPBirthDate = prefs.getString('p3_mp_age') ?? '';
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
        _mp_education.text = prefs.getString('p3_mp_education') ?? '';
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
          top: 100,
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
            // ABSENT/MISSING PERSON NAME SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Absent/Missing Person Name',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                    decoration: const InputDecoration(
                        labelText: "Last Name*",
                        hintText: "Last Name*",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_lastName', value);
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
                    decoration: const InputDecoration(
                        labelText: "First Name*",
                        hintText: "First Name*",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_firstName', value);
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
                    decoration: const InputDecoration(
                        labelText: "Middle Name",
                        hintText: "Middle Name",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_middleName', value);
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
                    decoration: const InputDecoration(
                        labelText: "Qualifier",
                        hintText: "Qualifier",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_qualifier', value);
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
                    decoration: const InputDecoration(
                        labelText: "Nickname / Known Aliases",
                        hintText: "Nickname / Known Aliases",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_nickname', value);
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
                'Citizenship',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                    controller: _mp_civilStatus,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        labelText: "Citizenship*",
                        hintText: "Citizenship*",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    onChanged: (value) {
                      setState(() {
                        _prefs.setString('p3_mp_civilStatus', value);
                      });
                    },
                  ),
                ),
              ],
            ),
            // SEX SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Sex',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            // rows for Male and Female radio buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //male
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: RadioListTile(
                    title: const Text("Male"),
                    value: "male",
                    groupValue: sexValue,
                    onChanged: (value) {
                      setState(() {
                        sexValue = value;
                        _prefs.setString('p3_mp_sex', value!);
                      });
                    },
                  ),
                ),
                //female
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: RadioListTile(
                    title: const Text("Female"),
                    value: "female",
                    groupValue: sexValue,
                    onChanged: (value) {
                      setState(() {
                        sexValue = value;
                        _prefs.setString('p3_mp_sex', value!);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            // dropdown for civil status
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: DropdownButtonFormField<String>(
                hint: const Text("Select Civil Status*"),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: mp_civilStatValue,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black54),
                onChanged: (String? newValue) {
                  setState(() {
                    mp_civilStatValue = newValue;
                    _prefs.setString('p3_mp_civilStatus', newValue!);
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                      labelText: "Birth Date",
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
                      initialValue: [DateTime.now()],
                      borderRadius: BorderRadius.circular(15),
                    );
                    // get variable selectedDate type
                    dateTimeMPBirthDate = pickedDate![0];
                    var string_dateTimeMPBirthdate =
                        dateTimeMPBirthDate.toString();
                    List returnVal = reformatDate(
                        string_dateTimeMPBirthdate, dateTimeMPBirthDate!);
                    String reformattedMPBirthDate = returnVal[0];
                    ageFromMPBirthDate = returnVal[1];
                    // save picked date to text field
                    _mp_birthDate.text = reformattedMPBirthDate;
                    // save to shared preferences using onChanged
                    _prefs.setString('p3_mp_birthDate', _mp_birthDate.text);
                    // also save age to shared preferences
                    _prefs.setString('p3_mp_age', ageFromMPBirthDate!);
                  },
                )),
            // AGE SECTION
            _verticalPadding,
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Age*',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                  labelText: "Age",
                ),
                onChanged: (value) {
                  _mp_age.text = ageFromMPBirthDate!;
                },
              ),
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
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                print(prefs.getKeys());
                print(prefs.getString('p3_mp_birthDate'));
                print(prefs.getString('p3_mp_sex'));
                print(prefs.getString('p3_mp_civilStatus'));
                print(prefs.getString('p3_mp_age'));
              },
              child: const Text('Print Shared Preferences'),
            ),
          ]))
    ]);
  }
}
