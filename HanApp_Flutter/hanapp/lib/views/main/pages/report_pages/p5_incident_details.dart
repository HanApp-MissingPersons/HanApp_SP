import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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
String userUID = FirebaseAuth.instance.currentUser!.uid;
late SharedPreferences prefs;

class _Page5IncidentDetailsState extends State<Page5IncidentDetails> {
  String reportCount = 'NONE';

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
  // for geocoding
  String? lastSeenLoc_lat;
  String? lastSeenLoc_lng;
  String? placeName;
  String? nearestLandmark;
  String? cityName;
  String? brgyName;
  //
  TimeOfDay? picked_time = null;

  retrieveUserData() async {
    prefs = await SharedPreferences.getInstance();
    await FirebaseDatabase.instance
        .ref("Main Users")
        .child(userUID)
        .get()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> userDict = snapshot.value as Map<dynamic, dynamic>;
      print('${userDict['firstName']} ${userDict['lastName']}');
      reportCount = userDict['reportCount'];
    });
    print('[REPORT COUNT] report count: $reportCount');
  }

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
      // for geocoding
      placeName = prefs.getString('p5_placeName');
      nearestLandmark = prefs.getString('p5_nearestLandmark');
      cityName = prefs.getString('p5_cityName');
      brgyName = prefs.getString('p5_brgyName');
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

  /* FUNCTIONS FOR GEOCODING */
  Future<void> _getAddress() async {
    // _getPinLocName();
    // _getLandmark();
    // _getCity();
    // _getBrgy();
    final lat = double.tryParse(lastSeenLoc_lat!);
    final lng = double.tryParse(lastSeenLoc_lng!);
    if (lat == null || lng == null) {
      return;
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    // print placemarks to see what is available
    for (var placemark in placemarks) {
      // print('placemark = $placemark');
    }

    setState(() {
      // for pinned location place name
      placeName = placemarks.isNotEmpty
          ? placemarks.first.name ?? 'Place not found.'
          : 'Place not found.';
      _writeToPrefs('p5_placeName', placeName!);
      // for landmark
      nearestLandmark = placemarks.isNotEmpty
          ? placemarks
                  .firstWhere((element) =>
                          !element.name!.contains('+') && // is NOT a plus code
                          int.tryParse(element.name!.trim()) ==
                              null && // is not only a number
                          (!RegExp(r'^\d+([-+*/]\d+)*$').hasMatch(element.name!
                              .trim())) // does not contain only numbers and symbols
                      )
                  .name ??
              'Landmark not found.'
          : 'Landmark not found.';
      _writeToPrefs('p5_nearestLandmark', nearestLandmark!);

      // for city
      cityName = placemarks.isNotEmpty
          ? placemarks.first.locality ?? 'City not found.'
          : 'City not found.';
      _writeToPrefs('p5_cityName', cityName!);
      // for brgy
      if (placemarks.isNotEmpty) {
        if (placemarks.first.subLocality == '') {
          brgyName = "Not Registered in GMaps";
        } else {
          brgyName = placemarks.first.subLocality!;
        }
      }
      _writeToPrefs('p5_brgyName', brgyName!);
    });
  }

  // // get Name of Place from lat/lng
  // Future<void> _getPinLocName() async {
  //   final lat = double.tryParse(lastSeenLoc_lat!);
  //   final lng = double.tryParse(lastSeenLoc_lng!);
  //   if (lat == null || lng == null) {
  //     return;
  //   }
  //   List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  //   // print placemarks to see what is available
  //   for (var placemark in placemarks) {
  //     print('placemark = $placemark');
  //   }

  //   setState(() {
  //     placeName = placemarks.isNotEmpty
  //         ? placemarks.first.name ?? 'Place not found.'
  //         : 'Place not found.';
  //     // write to shared preferences
  //     _writeToPrefs('p5_placeName', placeName!);
  //   });
  // }

  /* END OF FUNCTIONS FOR GEOCODING */

  @override
  void initState() {
    getSharedPrefs();
    try {
      print(prefs.getKeys());
    } catch (e) {
      print('[P5] prefs not initialized yet');
    }
    super.initState();
    retrieveUserData();
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
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: const Text(
                      '''Fields with (*) require user input.\nThe rest are auto-generated.''',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
                  'Last Seen Date*',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // Last Seen Date (using date picker widget)
              _verticalPadding,
              // DATE PICKER WIDGET
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
                        // add hour calculator code from last seen time here as well
                        if (lastSeenDate != null && lastSeenTime != null) {
                          setState(() {
                            _selectedTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                picked_time!.hour,
                                picked_time!.minute);
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
                    ),
                  ),
                ],
              ),
              // END OF DATE PICKER WIDGET
              _verticalPadding,
              // TIME PICKER WIDGET (for last seen time)
              if (lastSeenDate != null)
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Text(
                        'Last Seen Time*',
                        style: headingStyle,
                      ),
                    ),
                    // small text saying "provide an estimate if exact time is unknown"
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Text(
                        'Provide an estimate if exact time is unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
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
                              picked_time = picked;
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: "Hours Since Last Seen",
                        labelStyle: TextStyle(color: Colors.black)),
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
                        ? Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .1,
                              ),
                              Icon(
                                Icons.not_listed_location_outlined,
                                size: MediaQuery.of(context).size.width * .8,
                                color: Colors.grey[200],
                              ),
                              const Text('No location selected'),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .1,
                              ),
                            ],
                          )
                        : locSnapshot.runtimeType.toString() != 'Uint8List?'
                            ? Image.memory(locSnapshot!, fit: BoxFit.cover)
                            : Image.memory(
                                base64Decode(locSnapshot!.toString()),
                                fit: BoxFit.cover)),
              ),
              _verticalPadding,
              Container(
                width: MediaQuery.of(context).size.width * .9,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic>? result;
                    reportCount != 'NONE'
                        ? result = await showDialog<Map<String, dynamic>?>(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              print('User UID: $userUID');
                              print('Report Count: $reportCount');
                              return MapDialog(
                                  uid: userUID, reportCount: reportCount);
                            },
                          )
                        : // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Retrieving user data is taking longer than usual'),
                            ),
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
                        _writeToPrefs('p5_lastSeenLoc', lastSeenLoc!);
                        // geocoding stuff
                        lastSeenLoc_lat = location.latitude.toString();
                        lastSeenLoc_lng = location.longitude.toString();
                        _getAddress(); // run getAddress() to get address from lat,lng
                        placeName != null
                            ? _writeToPrefs('p5_placeName', placeName!)
                            : _writeToPrefs('p5_placeName', 'No Place Name');

                        nearestLandmark != null
                            ? _writeToPrefs(
                                'p5_nearestLandmark', nearestLandmark!)
                            : _writeToPrefs(
                                'p5_nearestLandmark', 'No Landmark');

                        cityName != null
                            ? _writeToPrefs('p5_cityName', cityName!)
                            : _writeToPrefs('p5_cityName', 'No City Name');

                        brgyName != null
                            ? _writeToPrefs('p5_brgyName', brgyName!)
                            : _writeToPrefs('p5_brgyName', 'No Barangay name');
                      });
                      // _getAddress;
                      // set lastSeenLoc_lat and lastSeenLoc_long
                    }
                  },
                  child: const Text('Select Location'),
                ),
              ),
              _verticalPadding,
              // Pinned Loc Details
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Pinned Location',
                  style: headingStyle,
                ),
              ),
              _verticalPadding,
              // Pinned Loc Details Text Field
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  controller: TextEditingController(text: placeName),
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: "Pinned Location (may show location code)",
                  ),
                  onChanged: (placeName) {},
                ),
              ),
              _verticalPadding,
              // Nearest Landmark
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  controller: TextEditingController(text: nearestLandmark),
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: "Nearest Landmark",
                  ),
                  onChanged: (nearestLandmark) {},
                ),
              ),
              _verticalPadding,
              // City
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  controller: TextEditingController(text: cityName),
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: "City/Municipality",
                  ),
                  onChanged: (cityName) {},
                ),
              ),
              _verticalPadding,
              // Barangay/District
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: TextField(
                  controller: TextEditingController(text: brgyName),
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: "Barangay/District",
                  ),
                  onChanged: (brgyName) {},
                ),
              ),
              _verticalPadding,
              // Incident Details
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  'Incident Details*',
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
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
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
                width: MediaQuery.of(context).size.width - 40,
                child: const Text(
                  '''Note: If "Victim of Crime" or "Victim of Calamity or Accident", please provide specific details regarding the crime or calamity/accident.''',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ),
              _verticalPadding,
              // END OF PAGE
              _verticalPadding,
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      // Icons.info_outline_rounded,
                      Icons.swipe_left_rounded,
                      color: Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: const Text(
                        'End of Incident Details Form. \nSwipe left to continue.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // DEBUG TOOL: SHARED PREF PRINTER
              // TextButton(
              //   onPressed: () async {
              //     final prefs = await SharedPreferences.getInstance();
              //     print(prefs.getKeys());
              //     print(prefs.getString('p5_lastSeenDate'));
              //     print(prefs.getString('p5_lastSeenTime'));
              //     // print p5_totalHoursSinceLastSeen
              //     print(prefs.getString('p5_totalHoursSinceLastSeen'));
              //     print('Address Details:');
              //     print(prefs.getString('p5_placeName'));
              //     print(prefs.getString('p5_nearestLandmark'));
              //     print(prefs.getString('p5_cityName'));
              //     print(prefs.getString('p5_brgyName'));
              //   },
              //   child: const Text('Print Shared Preferences'),
              // ),
            ],
          ),
        ),
      ),
    ]);
  }
}
