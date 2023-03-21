import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// datepicker stuff
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

// end of datepicker stuff

class Page3MPDetails extends StatefulWidget {
  const Page3MPDetails({super.key});

  @override
  State<Page3MPDetails> createState() => _Page3MPDetailsState();
}

// initialize controller for the form

// padding variable for the rows
const _padding = SizedBox(height: 10);

// store sex value
String? _sexValue;
// store civil status value
String? _civilStatusValue;
// store date of birth value
DateTime? _dateOfBirth;
// int age
int? _age;
// store highest educational attainment value
String? _highestEduc;
// store reportee ID picture
File? _reportee_ID;

// initialize ImagePicker
final ImagePicker _picker = ImagePicker();

class _Page3MPDetailsState extends State<Page3MPDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);

// error message: empty field
  static const String _emptyFieldError = 'Field cannot be empty';

  // controllers to contain the text in the form
  late final TextEditingController _dateOfBirthController;

  // // @override
  // // void initState() {
  // //   _dateOfBirth = TextEditingController();
  // //   super.initState();
  // // }

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
                'Page 3 of 6: Absent/Missing Person Details',
                style: optionStyle,
              ),
            ), // Page 1 Text
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
            _padding,
            // Section: Reportee Name
            const Text(
              "Absent/Missing Person Name",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              // center the row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // last name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                ),
                _padding,
                // first name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name*',
                    ),
                    // add validator:
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _emptyFieldError;
                      }
                      return null;
                    },
                  ),
                ),
                _padding,
                // middle name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Middle Name',
                    ),
                  ),
                ),
                _padding,
                // qualifier (Jr, Sr, III, etc)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Qualifier',
                    ),
                  ),
                ),
                _padding,
                // Nickname / Known Aliases
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nickname / Known Aliases',
                    ),
                  ),
                ),
              ],
            ),
            _padding,

            // Section: Citizenship
            const Text(
              "Citizenship",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
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
            _padding,
            // Section: Sex
            const Text(
              "Sex",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            Column(
              // center the row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // sizedbox-radio for Male
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: RadioListTile(
                    title: const Text("Male"),
                    value: "male",
                    groupValue: _sexValue,
                    onChanged: (value) {
                      setState(() {
                        _sexValue = value.toString();
                      });
                    },
                  ),
                ),
                // sizedbox-radio for female
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: RadioListTile(
                    title: const Text("Female"),
                    value: "female",
                    groupValue: _sexValue,
                    onChanged: (value) {
                      setState(() {
                        _sexValue = value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            _padding,
            // Section: Civil Status
            const Text(
              "Civil Status",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // dropdown for civil status and update _civilStatusValue
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: DropdownButtonFormField<String>(
                // text to display when no value is selected
                hint: const Text("Select Civil Status*"),
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
            _padding,
            // Section: Date of Birth
            const Text(
              "Date of Birth",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // date picker for date of birth --- THIS IS NOT WORKING YET
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Date of Birth*',
                    ),
                    // on tap, show date picker:
                    onTap: () async {
                      var result = await showCalendarDatePicker2Dialog(
                        dialogSize: const Size(325, 400),
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now()),
                        initialValue: [DateTime.now()],
                        borderRadius: BorderRadius.circular(15),
                      );
                      _dateOfBirth = result![0];
                      // return date of birth as string
                      var dateOfBirthString = DateFormat('MM/dd/yyyy')
                          .format(_dateOfBirth!)
                          .toString();
                      // set text field to date of birth
                      setState(() {
                        _dateOfBirthController.text = dateOfBirthString;
                      });
                    },
                  ),
                ),
                //
              ],
            ),
            _padding,
            // Age
            const Text(
              "Age",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // age text field --- !!! this should be auto-calculated and filled out with DOB
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Age*',
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
            _padding,
            // Section: Contact Information
            const Text(
              "Contact Information",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // text fields for Home Phone, Mobile Phone, Alternate Mobile Phone, Email Address
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Home Phone',
                    ),
                  ),
                ),
                _padding,
                // Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Mobile Phone',
                    ),
                  ),
                ),
                _padding,
                // Alternate Mobile Phone
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Alternate Mobile Phone',
                    ),
                  ),
                ),
                _padding,
                // Email Address
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email Address',
                    ),
                  ),
                ),
              ],
            ),
            _padding,
            // SECTION: Address
            const Text(
              "Address",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // text fiels for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Region
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Region*',
                    ),
                  ),
                ),
                _padding,
                // Province
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Province*',
                    ),
                  ),
                ),
                _padding,
                // Town/City
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Town/City*',
                    ),
                  ),
                ),
                _padding,
                // Barangay
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Barangay*',
                    ),
                  ),
                ),
                _padding,
                // Village/Sitio
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Village/Sitio',
                    ),
                  ),
                ),
                _padding,
                // House Number/Street
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'House Number/Street',
                    ),
                  ),
                ),
              ],
            ),
            _padding,
            // ask if user has alternate address if yes, add another section for alternate address
            // this should be radio button
            Container(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text(
                "Does the Absent/Missing Person have an alternate address? ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Alternate Address
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Alternate Address (Enter NA if none)',
                    ),
                  ),
                ),
              ],
            ),
            _padding,
            // SECTION: Highest Educational Attainment
            const Text(
              "Highest Educational Attainment",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // dropdown for highest educational attainment (elementary, high school, college, etc.)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Highest Educational Attainment*',
                    ),
                    items: [
                      DropdownMenuItem(
                        child: const Text("Elementary"),
                        value: "Elementary",
                      ),
                      DropdownMenuItem(
                        child: const Text("High School"),
                        value: "High School",
                      ),
                      DropdownMenuItem(
                        child: const Text("College"),
                        value: "College",
                      ),
                      DropdownMenuItem(
                        child: const Text("Vocational"),
                        value: "Vocational",
                      ),
                      DropdownMenuItem(
                        child: const Text("Graduate Studies"),
                        value: "Graduate Studies",
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _highestEduc = value.toString();
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
            _padding,
            // textfield for occupation
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Occupation',
                    ),
                  ),
                ),
              ],
            ),
            _padding,
            // SECTION: Work/School Address
            // !NOTE: Radio button to show if work or  school address
            const Text(
              "Work (or School) Address",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            _padding,
            // text fields for Region, Province, Town/City, Barangay, Village/Sitio, House Number/Street
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Region
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Region',
                    ),
                  ),
                ),
                _padding,
                // Province
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Province',
                    ),
                  ),
                ),
                _padding,
                // Town/City
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Town/City',
                    ),
                  ),
                ),
                _padding,
                // Barangay
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Barangay',
                    ),
                  ),
                ),
                _padding,
                // Village/Sitio
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Village/Sitio',
                    ),
                  ),
                ),
                _padding,
                // House Number/Street
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'House Number/Street',
                    ),
                  ),
                ),
                // Name of School/Company
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name of School/Company',
                    ),
                  ),
                ),
              ],
            ),

            _padding,
            // "Swipe Right to Move to Next Page"
            Container(
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
  } // end of build
}
