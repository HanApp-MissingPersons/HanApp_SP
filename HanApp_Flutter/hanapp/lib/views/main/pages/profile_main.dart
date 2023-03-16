import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/views/login_view.dart';

import '../../../firebase_options.dart';
import '../../../main.dart';

class ProfileMain extends StatefulWidget {
  const ProfileMain({super.key});

  @override
  State<ProfileMain> createState() => _ProfileMain();
}

class _ProfileMain extends State<ProfileMain> {
  String _usrFullName = ' ';
  String _usrEmail = ' ';
  String _usrNumber = ' ';
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
      if (kDebugMode) {
        print('[RETRIEVED] $usrProfileDict');
      }

      setState(() {
        _usrFullName = nameFromDB;
        _usrNumber = numberFromDB;
        _usrEmail = emailFromDB;
      });
    });
  }

  // void setUserDetails(data) {
  //   setState(() {
  //     usersData = data;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // // var usersData;
    // mainUserRef.onValue.listen((event) {
    //   final usersData = Map<String, dynamic>.from(
    //       event.snapshot.value as Map<dynamic, dynamic>);
    // });
    return Scaffold(
      appBar: AppBar(
        title: const Text('profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_usrFullName),
            Text(_usrEmail),
            Text(_usrNumber),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()));
                  },
                  child: const Text('Sign Out')),
            ),
          ],
        ),
      ),
    );
  }
}
