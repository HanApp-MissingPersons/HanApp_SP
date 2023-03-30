import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);

  // local variables for text fields
  // reportDate should be automatically filled with the current date, formatted (MM/DD/YYYY):
  String? reportDate = '${dateNow.month}/${dateNow.day}/${dateNow.year}';
  String? lastSeenDate;
  String? lastSeenTime;
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

  Future<void> getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('p5_reportDate', reportDate!);
      lastSeenDate = prefs.getString('p5_lastSeenDate');
      lastSeenTime = prefs.getString('p5_lastSeenTime');
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

  @override
  void initState() {
    try {
      print(prefs.getKeys());
    } catch (e) {
      print('[P5] prefs not initialized yet');
    }
    super.initState();
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: 100,
        left: 20,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Page 5: Incident Details',
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
              // Report Date
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Report Date: ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
              _verticalPadding,
              // filled in and grayed out text field with the current date
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
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
                      controller: TextEditingController(text: lastSeenDate),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Last Seen Date*',
                      ),
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
                          var dateReformatted = reformatDate(dateFormatted, date);
                          // set state
                          setState(() {
                            lastSeenDate = dateReformatted[0];
                            prefs.setString('p5_lastSeenDate', lastSeenDate!);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              _verticalPadding,
              // Last Seen Time Text
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Last Seen Time: ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
              _verticalPadding,
              // // Last Seen Time button
              // SizedBox(
              //   width: MediaQuery.of(context).size.width - 40,
              //   child: ElevatedButton(
              //     onPressed: _selectTime,
              //     child: const Text('Select Time'),
              //   ),
              // ),
              // Last Seen Time Text Field
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  controller: TextEditingController(text: lastSeenTime),
                  showCursor: false,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedTime = DateTime(now.year, now.month, now.day,
                            picked.hour, picked.minute);
                        lastSeenTime =
                            DateFormat('hh:mm a').format(_selectedTime!);
                        prefs.setString('p5_lastSeenTime', lastSeenTime!);
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    // holder text
                    labelText: 'Last Seen Time*',
                    hintText: 'Last Seen Time*',
                  ),
                ),
              ),
              _verticalPadding,
              // Last Seen Location
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Last Seen Location: ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
              ),
              _verticalPadding,
              // Last Seen Location Text Field
              // !NOTE: Replace with Google Maps API later on, for now use text field
              _verticalPadding,
              Center(
                child: Container(
                  alignment: Alignment.center,
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * .05),
                    width: MediaQuery.of(context).size.width * .8,
                    child: locSnapshot == null
                        ? const Text('No location selected') :
                    locSnapshot.runtimeType.toString() != 'Uint8List?'
                        ? Image.memory(locSnapshot!)
                        : Image.memory(base64Decode(locSnapshot!.toString()
                    )
                    )
                ),

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
                        prefs.setString('p5_lastSeenLoc', lastSeenLoc!);
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
                  'Incident Details: ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
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
                    color: Colors.black54,
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Incident Details*',
                  ),
                  onChanged: (value) {
                    incidentDetails = value;
                    prefs.setString('p5_incidentDetails', incidentDetails!);
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
            ],
          ),
        ),
      ),
    ]);
  }
}
