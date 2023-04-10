import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'mapDialog.dart';

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
  var daySpaceIndex = day.indexOf(' ');
  if (daySpaceIndex >= 0) {
    day = day.substring(0, daySpaceIndex);
  }
  if (day.isNotEmpty && int.parse(day) % 10 != 0) {
    day = day.replaceAll('0', '');
  }

  var year = dateParts[0];

  var age =
      (DateTime.now().difference(dateTimeBday).inDays / 365).floor().toString();
  var returnVal = '$month $day, $year';
  return [returnVal, age];
}

class Page5IncidentDetails extends StatefulWidget {
  const Page5IncidentDetails({super.key});

  @override
  State<Page5IncidentDetails> createState() => _Page5IncidentDetailsState();
}

DateTime now = DateTime.now();
DateTime dateNow = DateTime(now.year, now.month, now.day);

late SharedPreferences prefs;

class _Page5IncidentDetailsState extends State<Page5IncidentDetails> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87);
  static const _verticalPadding = SizedBox(height: 10);

  static const TextStyle headingStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54);

  // local variables for text fields
  // reportDate should be automatically filled with the current date, formatted (MM/DD/YYYY):
  String? reportDate = '${dateNow.month}/${dateNow.day}/${dateNow.year}';
  String? lastSeenDate;
  String? lastSeenTime;
  // totalHouseSinceLastSeen should be calculated by: CurrentDate+CurrentTime - LastSeenDate+LastSeenTime
  String? totalHoursSinceLastSeen;
  String? lastSeenLoc;
  String? incidentDetails;
  Uint8List? locSnapshot;

  // time
  DateTime? _selectedTime;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        lastSeenTime = DateFormat('hh:mm a').format(_selectedTime!);
      });
    }
  }

  /* SHARED PREF EMPTY CHECKER AND SAVER FUNCTION*/
  Future<void> _writeToPrefs(String key, String value) async {
    if (value != '') {
      prefs.setString(key, value);
    } else {
      prefs.remove(key);
    }
  }

  Future<void> getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('p5_reportDate', reportDate!);
      lastSeenDate = prefs.getString('p5_lastSeenDate');
      lastSeenTime = prefs.getString('p5_lastSeenTime');
      totalHoursSinceLastSeen = prefs.getString('p5_totalHoursSinceLastSeen');
      lastSeenLoc = prefs.getString('p5_lastSeenLoc');
      incidentDetails = prefs.getString('p5_incidentDetails');
      String? locSnapshotString = prefs.getString('p5_locSnapshot');
      if (locSnapshotString != null) {
        locSnapshot = base64Decode(locSnapshotString);
        // print('[p5] locSnapshot: $locSnapshot');
        // print('[p5] locSnapshot runtime: ${locSnapshot.runtimeType}');
      } else {
        print('[p5] No location snapshot');
      }
    });
  }

  // /* TOTAL HOURS SINCE LAST SEEN */
  // // function to calculate total hours since last seen, returns a string
  // Future<void> calculateHoursSinceLastSeen() async {
  //   if (lastSeenDate != null && lastSeenTime != null) {
  //     DateTime lastSeenDateTime =
  //         DateFormat('MM/dd/yyyy hh:mm a').parse('$lastSeenDate $lastSeenTime');
  //     DateTime currentDateTime = DateTime.now();

  //     Duration timeDifference = currentDateTime.difference(lastSeenDateTime);

  //     int totalHoursSinceLastSeenInt = timeDifference.inHours;
  //     totalHoursSinceLastSeen = totalHoursSinceLastSeenInt.toString();

  //     // save to shared prefs
  //     prefs.setString('p5_totalHoursSinceLastSeen', totalHoursSinceLastSeen!);

  //     // print
  //     print('[p5] totalHoursSinceLastSeen: $totalHoursSinceLastSeen');
  //   }
  // }

  @override
  void initState() {
    try {
      print(prefs.getKeys());
    } catch (e) {
      print('[P5] prefs not initialized yet');
    }
    super.initState();
    getSharedPrefs();
    // calculateHoursSinceLastSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: MediaQuery.of(context).size.height / 8,
        left: 20,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Page 5 of 6: Incident Details',
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
              // Report Date
              _verticalPadding,
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Report Date:',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // filled in and grayed out text field with the current date
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: reportDate,
                  ),
                ),
              ),
              _verticalPadding,
              // Last Seen Date and Time section
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Last Seen Date',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // Last Seen Date (using date picker widget)
              _verticalPadding,
              // date picker widget
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child: TextFormField(
                      showCursor: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      readOnly: true,
                      keyboardType: TextInputType.datetime,
                      controller: TextEditingController(text: lastSeenDate),
                      decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          hintText: 'Tap to select date'),
                      // on tap, show date picker:
                      onTap: () async {
                        var result = await showCalendarDatePicker2Dialog(
                          dialogSize: const Size(325, 400),
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now()),
                          value: [DateTime.now()],
                          borderRadius: BorderRadius.circular(15),
                        );
                        if (result != null) {
                          // reformat date
                          var date = result[0];
                          var dateFormatted =
                              DateFormat('yyyy-MM-dd').format(date!);
                          var dateReformatted =
                              reformatDate(dateFormatted, date);
                          // set state
                          setState(() {
                            lastSeenDate = dateReformatted[0];
                            // prefs.setString('p5_lastSeenDate', lastSeenDate!);
                            _writeToPrefs('p5_lastSeenDate', lastSeenDate!);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              _verticalPadding,
              // Last Seen Time Text
              if (lastSeenDate != null)
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Text(
                        'Last Seen Time',
                        style: headingStyle,
                      ),
                    ),
                    _verticalPadding,
                    // Last Seen Time Text Field
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: TextFormField(
                        showCursor: false,
                        autocorrect: false,
                        enableSuggestions: false,
                        readOnly: true,
                        controller: TextEditingController(text: lastSeenTime),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = DateTime(now.year, now.month,
                                  now.day, picked.hour, picked.minute);
                              lastSeenTime =
                                  DateFormat('hh:mm a').format(_selectedTime!);
                              // prefs.setString('p5_lastSeenTime', lastSeenTime!);
                              _writeToPrefs('p5_lastSeenTime', lastSeenTime!);
                              // calculate hours since last seen from last seen date and time
                              // print lastSeenDate and lastSeenTime in one string
                              print('DateTime: $lastSeenDate $lastSeenTime');
                              DateFormat inputFormat =
                                  DateFormat('MMMM d, y hh:mm a');
                              DateTime lastSeenDateAndTime = inputFormat
                                  .parse('$lastSeenDate $lastSeenTime');
                              print('LastSeenDateTime: $lastSeenDateAndTime');
                              DateTime currentDateAndTime = DateTime.now();
                              print('CurrentDateTime: $currentDateAndTime');
                              Duration timeDifference = currentDateAndTime
                                  .difference(lastSeenDateAndTime);
                              print('TimeDifference: $timeDifference');
                              int hoursSinceLastSeen = timeDifference.inHours;
                              print('HoursSinceLastSeen: $hoursSinceLastSeen');
                              totalHoursSinceLastSeen =
                                  hoursSinceLastSeen.toString();
                              _writeToPrefs('p5_totalHoursSinceLastSeen',
                                  totalHoursSinceLastSeen!);
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          // holder text
                          hintText: 'Tap to select time',
                        ),
                      ),
                    ),
                  ],
                ),
              _verticalPadding,
              /* HOURS SINCE LAST SEEN */
              // print result of calculateHoursSinceLastSeen() in a text field
              // if last seen date and time are not null, show sized box
              if (lastSeenDate != null && lastSeenTime != null)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextField(
                    controller:
                        TextEditingController(text: totalHoursSinceLastSeen),
                    enabled: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Hours Since Last Seen",
                    ),
                    onChanged: (value) {
                      totalHoursSinceLastSeen = value;
                      // prefs.setString('p5_hoursSinceLastSeen', value);
                      _writeToPrefs('p5_hoursSinceLastSeen', value);
                    },
                  ),
                )
              else
                const SizedBox(),
              _verticalPadding,
              // end of hours since last seen
              // Last Seen Location
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Last Seen Location',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // Last Seen Location Text Field
              // !NOTE: Replace with Google Maps API later on, for now use text field
              _verticalPadding,
              Center(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .05),
                    width: MediaQuery.of(context).size.width * .8,
                    child: locSnapshot == null
                        ? const Text('No location selected')
                        : locSnapshot.runtimeType.toString() != 'Uint8List?'
                            ? Image.memory(locSnapshot!)
                            : Image.memory(
                                base64Decode(locSnapshot!.toString()))),
              ),
              _verticalPadding,
              Container(
                width: MediaQuery.of(context).size.width * .9,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic>? result =
                        await showDialog<Map<String, dynamic>?>(
                      context: context,
                      builder: (BuildContext context) {
                        return const MapDialog();
                      },
                    );
                    if (result != null) {
                      LatLng location = result['location'];
                      Uint8List? image;
                      try {
                        image = result['image'];
                      } catch (e) {
                        print(e);
                      }
                      print(
                          'Selected location: ${location.latitude}, ${location.longitude}');
                      setState(() {
                        locSnapshot = image;
                        lastSeenLoc =
                            'Lat: ${location.latitude}, Long: ${location.longitude}';
                        // prefs.setString('p5_lastSeenLoc', lastSeenLoc!);
                        _writeToPrefs('p5_lastSeenLoc', lastSeenLoc!);
                      });
                    }
                  },
                  child: const Text('Select Location'),
                ),
              ),
              _verticalPadding,
              // Incident Details
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Incident Details',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // Hint Text: "Please provide as much detail as possible. Answering the "Who, What, When, Where, Why, and How" questions will help us better understand the incident."
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  '''Please provide as much detail as possible. Answering the "Who, What, When, Where, Why, and How" questions will help us better understand the incident.''',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ),
              _verticalPadding,
              // multi-line text field
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: TextField(
                  controller: TextEditingController(text: incidentDetails),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: 'Incident Details*',
                  ),
                  onChanged: (value) {
                    incidentDetails = value;
                    // prefs.setString('p5_incidentDetails', incidentDetails!);
                    _writeToPrefs('p5_incidentDetails', incidentDetails!);
                  },
                ),
              ),
              _verticalPadding,
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: const Text(
                  "End of Absent/Missing Person Details Form. Swipe left to move to next page",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              // DEBUG TOOL: SHARED PREF PRINTER
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  print(prefs.getKeys());
                  print(prefs.getString('p5_lastSeenDate'));
                  print(prefs.getString('p5_lastSeenTime'));
                  // print p5_totalHoursSinceLastSeen
                  print(prefs.getString('p5_totalHoursSinceLastSeen'));
                },
                child: const Text('Print Shared Preferences'),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
