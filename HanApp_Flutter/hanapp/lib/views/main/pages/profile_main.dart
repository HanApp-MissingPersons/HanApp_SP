import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/views/login_view.dart';

class ProfileMain extends StatefulWidget {
  const ProfileMain({super.key});

  @override
  State<ProfileMain> createState() => _ProfileMain();
}

// class User(var name, var email, var phone, var user){
//   late String name;
//   late String email;
//   late String phone;
//   User(){
//     name = name;
//     email = email;
//     phone = phone;
//   }
// }

class _ProfileMain extends State<ProfileMain> {
  // ignore: prefer_typing_uninitialized_variables
  late var user;
  late String fullName = 'Loading...';
  late DatabaseReference mainUserRef;
  _ProfileMain() {
    user = FirebaseAuth.instance.currentUser;
    mainUserRef = FirebaseDatabase.instance.ref('Main Users').child(user!.uid);
    mainUserRef.onValue.listen((event) {
      var usersData = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      for (var element in usersData.values) {
        fullName = element['fullName'];
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Balls'),
        ),
        body: Center(
            child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3),
                child: Text('Current User data: \n\n$user')),
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()));
                  },
                  child: const Text('Sign Out')),
            )
          ],
        )));
  }
}
