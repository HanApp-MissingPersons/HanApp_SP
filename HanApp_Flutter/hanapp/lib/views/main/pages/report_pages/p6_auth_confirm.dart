import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import dart ui
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
// import p1 to p5
import 'p1_classifier.dart';
import 'p2_reportee_details.dart';
import 'p3_mp_info.dart';
import 'p4_mp_description.dart';
import 'p5_incident_details.dart';
import 'package:image_picker/image_picker.dart';

// import dart ui
import 'dart:ui';

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
  Uint8List? _signaturePhoto;
  // store user signature as Image
  Image? _reporteeSignature;

  // save user signature to shared preferences
  Future<void> _saveSignature() async {
    final prefs = await SharedPreferences.getInstance();
    if (_signaturePhoto != null) {
      String signatureString = base64Encode(_signaturePhoto!);
      prefs.setString('p6_reporteeSignature', signatureString);
    }
  }

  // load user signature from shared preferences
  Future<void> _loadSignature() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('p6_reporteeSignature') != null) {
      String signatureString = prefs.getString('p6_reporteeSignature')!;
      _signaturePhoto = base64Decode(signatureString);
    }
  }

  // initialize shared preferences
  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

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
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
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
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
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
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _hanapp_upload,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  Row(
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dataPrivacy,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  _verticalPadding,
                  // insert signature here text
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: const Text(
                      'Draw your signature here:',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(
                    // add border to signaturepad:
                    // https://www.syncfusion.com/forums/121400/how-to-add-border-to-signature-pad
                    width: MediaQuery.of(context).size.width - 40,
                    height: 200,
                    child: SfSignaturePad(
                      key: _signaturePadKey,
                      minimumStrokeWidth: 2,
                      maximumStrokeWidth: 2,
                      strokeColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 221, 214, 214),
                    ),
                  ),

                  // clear signaturepad button using clear() method
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          // button color here
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            _signaturePadKey.currentState!.clear();
                          },
                          child: const Text('Clear Signature'),
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
                                await _signaturePadKey.currentState!.toImage();
                            // pop up dialog box showing preview of signature
                            // save in gallery
                            final data = await image.toByteData(
                                format: ImageByteFormat.png);
                            final bytes = data!.buffer.asUint8List();
                            _signaturePhoto = bytes;
                            setState(() {
                              // save in shared preferences
                              _saveSignature();
                            });
                          },
                          child: const Text('Save Signature'),
                        ),
                      ),
                    ],
                  ),
                  // text saying: Preview of submitted signature
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: const Text(
                      'Preview of submitted signature:',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                  // preview of saved signatur
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: _signaturePhoto != null
                        ? Image.memory(_signaturePhoto!)
                        : const Text('No signature saved'),
                  ),

                  // submit button
                  _verticalPadding,
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
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
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: const Text('Submit Report'),
                      // use sharedpreferences getAll() method to get all the data
                    ),
                  ),
                  // print all sharedpreferences data
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      print(prefs.getKeys());
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
}
