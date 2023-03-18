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
  String _usrFullName = 'Data Loading';
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
      String nameFromDB = usrProfileDict['fullName'];
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
        _usrFullName = nameFromDB;
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
    return _usrFullName != 'Data Loading'
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    _usrFullName,
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    _usrEmail,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    _usrNumber,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Birth Date: $_birthDateFormatted',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Age: $_usrAge',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Sex: $_usrSex',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()),
                      );
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: SpinKitCubeGrid(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          );
  }
}
