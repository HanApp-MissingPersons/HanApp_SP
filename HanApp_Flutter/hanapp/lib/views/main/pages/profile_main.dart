import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../../firebase_options.dart';
import '../../../main.dart';
import '../../register_view.dart';

class ProfileMain extends StatefulWidget {
  const ProfileMain({super.key});

  @override
  State<ProfileMain> createState() => _ProfileMain();
}

class _ProfileMain extends State<ProfileMain> {
  String _usrFullName = '';
  String _usrFirstName = 'Data Loading';
  String _usrLastName = '';
  String _usrMiddleName = '';
  String _usrQualifiers = '';
  String _usrEmail = ' ';
  String _usrNumber = ' ';
  // ignore: unused_field
  String _usrBirthDate = ' ';
  String _usrAge = ' ';
  String _birthDateFormatted = ' ';
  String _usrSex = ' ';
  DatabaseReference mainUsersRef = FirebaseDatabase.instance.ref('Main Users');
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    // user profile details from RTDB
    mainUsersRef.child(user!.uid).onValue.listen((event) {
      var usrProfileDict = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      String firstNameFromDB = usrProfileDict['firstName'];
      String lastNameFromDB = usrProfileDict['lastName'];
      String middleNameFromDB = usrProfileDict['middleName'] == 'N/A'
          ? ''
          : usrProfileDict['middleName'];
      String qualifiersFromDB = usrProfileDict['qualifiers'] == 'N/A'
          ? ''
          : usrProfileDict['qualifiers'];
      String numberFromDB = usrProfileDict['phoneNumber'];
      String emailFromDB = usrProfileDict['email'];
      String sexFromDB = usrProfileDict['sex'];

      String birthDate = usrProfileDict['birthDate'];
      List birthDateList = reformatDate(birthDate, DateTime.parse(birthDate));
      String birthDateFormatted = birthDateList[0];
      String age = birthDateList[1];

      if (kDebugMode) {
        print('[RETRIEVED] $usrProfileDict');
        print('$birthDateList');
      }

      setState(() {
        _usrFirstName = firstNameFromDB;
        _usrLastName = lastNameFromDB;
        _usrMiddleName = middleNameFromDB;
        _usrQualifiers = qualifiersFromDB;
        _usrNumber = numberFromDB;
        _usrEmail = emailFromDB;
        _usrSex = sexFromDB;
        _usrBirthDate = birthDate;
        _usrAge = age;
        _birthDateFormatted = birthDateFormatted;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _usrFullName =
        '$_usrFirstName $_usrMiddleName $_usrLastName $_usrQualifiers';
    return _usrFirstName != 'Data Loading'
        ? Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const BackButton(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 4,
                              right: MediaQuery.of(context).size.width / 4),
                          child: const Text(
                            'Profile',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const IconButton(
                          icon: Icon(Icons.manage_accounts_outlined,
                              color: Colors.black),
                          onPressed: null,
                        )
                      ],
                    ),

                    // PROFILE
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 40.0,
                            backgroundImage: NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Text(
                                  textAlign: TextAlign.center,
                                  _usrFullName,
                                  style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 5),
                                SelectableText(
                                  _usrEmail,
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Phone Number
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.phone_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Phone Number',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 9,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: SelectableText(
                              _usrNumber,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Birthdate
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.event_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Birthdate',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 9,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              _birthDateFormatted,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // AGE
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.timeline_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Age',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 9,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              _usrAge,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sex
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.wc_outlined),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Sex',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 9,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              _usrSex,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    FractionallySizedBox(
                      widthFactor: 0.60,
                      child: SizedBox(
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginView()),
                            );
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: SpinKitCubeGrid(
                color: Palette.indigo,
                size: 40.0,
              ),
            ),
          );
  }
}
