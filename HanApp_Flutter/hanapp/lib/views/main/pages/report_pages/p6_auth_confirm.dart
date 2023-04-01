/* IMPORTS */
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'p1_classifier.dart';
import 'p2_reportee_details.dart';
import 'p3_mp_info.dart';
import 'p4_mp_description.dart';
import 'p5_incident_details.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

/* SHARED PREFERENCE */
late SharedPreferences _prefs;
void clearPrefs() async {
  _prefs = await SharedPreferences.getInstance();
  _prefs.clear();
}

class Page6AuthConfirm extends StatefulWidget {
  const Page6AuthConfirm({super.key});

  @override
  State<Page6AuthConfirm> createState() => _Page6AuthConfirmState();
}

class _Page6AuthConfirmState extends State<Page6AuthConfirm> {
  // font style for the text
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  static const _verticalPadding = SizedBox(height: 10);

  // authorization and confirmation texts
  static const String _correctInfo =
      'I hereby certify to the correctness of the foregoing to the best of my knowledge and belief';
  static const String _authorization_PNP_upload =
      '“I hereby provide my consent and authorize the PNP to record and upload the information and photograph of the absent/missing person”. See full authorization text here (link).';
  static const String _hanapp_upload =
      '“I hereby provide my consent to have the information and photograph of the absent/missing person to be posted in HanApp’s “Missing Persons Near Me” page once the report is verified by the PNP”. See full authorization text here (link).';
  static const String _dataPrivacy =
      '"I hereby provide my consent to the processing of my personal data in accordance with the Data Privacy Act of 2012, and acknowledge that the information provided will only be used for the purposes of the the absent/missing persons case." See full Data Privacy Act text here (link).';

  // store user signature as Uint8List
  Uint8List? signaturePhoto;

  // save user signature to shared preferences
  Future<void> _saveSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (signaturePhoto != null) {
      String signaturePhotoString = base64Encode(signaturePhoto!);
      prefs.setString('p6_reporteeSignature', signaturePhotoString);
    }
  }

  // load user signature from shared preferences
  Future<void> _loadSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('p6_reporteeSignature') != null) {
      String signaturePhotoString = prefs.getString('p6_reporteeSignature')!;
      signaturePhoto = base64Decode(signaturePhotoString);
    }
  }

  // getSignature Future function
  Future<void> _getSignature(image) async {
    final data = await image.toByteData(format: ImageByteFormat.png);
    final imageBytes = await data!.buffer.asUint8List();
    setState(() {
      signaturePhoto = imageBytes;
    });
    await _saveSignature();
  }

  // initialize shared preferences
  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

    return Stack(children: [
      Positioned(
        top: 100,
        left: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'Page 6: Confirmation and Authorization',
                style: optionStyle,
              ),
            ),
            _verticalPadding,
            // text saying "By affixing my signature below"
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: const Text(
                'By affixing my signature below:',
                style: TextStyle(fontSize: 14),
              ),
            ),
            _verticalPadding,
            // show all the authorization and confirmation texts, each with their leading check mark
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _correctInfo,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  Row(
                    children: const [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _authorization_PNP_upload,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  Row(
                    children: const [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _hanapp_upload,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  Row(
                    children: const [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dataPrivacy,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  // Signature hint text
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: const Text(
                      'Draw your signature here:',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                  // signature pad
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 200,
                    child: SfSignaturePad(
                      key: signaturePadKey,
                      minimumStrokeWidth: 2,
                      maximumStrokeWidth: 2,
                      strokeColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 221, 214, 214),
                    ),
                  ),
                  // clear signaturepad button using clear() method
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.03,
                            right: MediaQuery.of(context).size.width * 0.03),
                        child: ElevatedButton(
                          // button color here
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            signaturePadKey.currentState!.clear();
                          },
                          child: const Text(
                            'Clear Signature Pad',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      _verticalPadding,
                      // save signature button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          // button color here
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            ui.Image image =
                                await signaturePadKey.currentState!.toImage();
                            await _getSignature(image);
                            print(signaturePhoto);

                            // pop-up showing preview of signature
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Preview of Saved Signature'),
                                    content: Image.memory(signaturePhoto!),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Text('Save Signature'),
                        ),
                      ),
                    ],
                  ),
                  // text saying: no signature saved yet if signaturePhoto is null
                  // signaturePhoto == null
                  //     ? const Text(
                  //         'No signature saved yet.',
                  //         style: TextStyle(fontSize: 14),
                  //       )
                  //     : const Text(
                  //         'Signature saved.',
                  //         style: TextStyle(fontSize: 14),
                  //       ),
                  // button to show preview of signature
                  prefs.getString('p6_reporteeSignature') != null
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: ElevatedButton(
                            // button color here
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              // pop-up showing preview of signature
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Preview of Saved Signature'),
                                      content: signaturePhoto != null
                                          ? Image.memory(signaturePhoto!)
                                          : const Text(
                                              'No signature saved yet.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              // set p6_reporteeSignature to null
                                              signaturePhoto = null;
                                              try {
                                                prefs.remove(
                                                    'p6_reporteeSignature');
                                              } catch (e) {
                                                print(e);
                                              }
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Delete Signature'),
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: const Text('View Saved Signature'),
                          ),
                        )
                      : const Text('No signature submitted'),
                  _verticalPadding,
                  // SUBMIT BUTTON
                  prefs.getString('p6_reporteeSignature') != null
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: ElevatedButton(
                            child: const Text('Submit Report'),
                            onPressed: () async {
                              // show popup dialog asking to confirm submission
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Submission'),
                                      content: const Text(
                                          'Are you sure you want to submit this report?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Submit'),
                                          onPressed: () async {
                                            checkReportValidity()
                                                ? submitReport()
                                                : await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Incomplete form'),
                                                        content: Text(
                                                            formErrorMessage()),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text(
                                                                'Close'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },

                            // use sharedpreferences getAll() method to get all the data
                          ),
                        )
                      : // show a submit button that is grayed out
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: const ElevatedButton(
                            onPressed: null,
                            child: Text('Submit Report'),
                          ),
                        ),
                  // print all sharedpreferences data
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      print(prefs.getKeys());
                      // preview of saved signature in a popup dialog
                    },
                    child: const Text('Print Shared Preferences'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  List<String> dialogMessage = ['none'];
  checkReportValidity() {
    List<String> keysList = prefs.getKeys().toList();
    bool returnval = true;
    print('[KEYSLIST] $keysList');
    // p2 required values
    if (!(keysList.contains('p2_citizenship') &&
        keysList.contains('p2_civil_status') &&
        keysList.contains('p2_region') &&
        keysList.contains('p2_province') &&
        keysList.contains('p2_townCity') &&
        keysList.contains('p2_barangay') &&
        keysList.contains('p2_reportee_ID_Photo') &&
        keysList.contains('p2_relationshipToMP') &&
        keysList.contains('p2_singlePhoto_face'))) {
      print('[p2 report not valid] p2 values are not complete');
      dialogMessage.add('p2');
      returnval = false;
    } else {
      if (dialogMessage.contains('p2')) {
        dialogMessage.remove('p2');
      }
    }
    // p3 required values
    if (!(keysList.contains('p3_mp_lastName') &&
        keysList.contains('p3_mp_firstName') &&
        keysList.contains('p3_mp_civilStatus') &&
        keysList.contains('p3_mp_sex') &&
        keysList.contains('p3_mp_birthDate') &&
        keysList.contains('p3_mp_age') &&
        keysList.contains('p3_mp_nationalityEthnicity') &&
        keysList.contains('p3_mp_citizenship') &&
        (keysList.contains('p3_mp_contact_homePhone') ||
            keysList.contains('p3_mp_contact_mobilePhone')) &&
        keysList.contains('p3_mp_address_region') &&
        keysList.contains('p3_mp_address_province') &&
        keysList.contains('p3_mp_address_city') &&
        keysList.contains('p3_mp_address_barangay'))) {
      print('[p3 report not valid] p3 values are not complete');
      dialogMessage.add('p3');
      returnval = false;
    } else {
      if (dialogMessage.contains('p3')) {
        dialogMessage.remove('p3');
      }
    }
    // p5 required values
    if (!(keysList.contains('p5_reportDate') &&
        keysList.contains('p5_lastSeenDate') &&
        keysList.contains('p5_lastSeenTime') &&
        keysList.contains('p5_locSnapshot') &&
        keysList.contains('p5_lastSeenLoc') &&
        keysList.contains('p5_incidentDetails'))) {
      print('[p5 report not valid] p5 values are not complete');
      dialogMessage.add('p5');
      returnval = false;
    } else {
      if (dialogMessage.contains('p5')) {
        dialogMessage.remove('p5');
      }
    }
    return returnval;
  }

  formErrorMessage() {
    String returnVal = 'Incomplete fields on:';
    if (dialogMessage.contains('p2')) {
      returnVal = '$returnVal\nPage 2: Reportee details';
    }
    if (dialogMessage.contains('p3')) {
      returnVal = '$returnVal\nPage 3: Missing person details';
    }
    if (dialogMessage.contains('p5')) {
      returnVal = '$returnVal\nPage 5: Incident details';
    }
    return returnVal;
  }

  submitReport() {
    print('Report submitted');
  }
}
