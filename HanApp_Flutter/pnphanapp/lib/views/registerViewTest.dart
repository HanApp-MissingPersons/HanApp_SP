import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

// Firebase Realtime Database initialize
FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference registrationRef =
    FirebaseDatabase.instance.ref("PNP Accounts");

Future<void> registerSanJoaquin(context) async {
  try {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'sanJoaqin_hanapp@gmail.com', password: 'abc123');
    await registrationRef.child('SanJoaqin').set({
      'lat': 10.587563005612441,
      'long': 122.14228426782086,
      'uid': userCred.user!.uid,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('SAN JOAQIN REGISTERED')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: ${e.code}')));
  }
}

void registerMiagao(context) async {
  try {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'miagao_hanapp@gmail.com', password: 'abc123');
    // Realtime Database User
    await registrationRef.child('Miagao').set({
      'lat': 10.640882128439756,
      'long': 122.24802365770803,
      'uid': userCred.user!.uid,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('MIAGAO REGISTERED')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: ${e.code}')));
  }
}

void registerJaro(context) async {
  try {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'jaro_hanapp@gmail.com', password: 'abc123');
    await registrationRef.child('Jaro').set({
      'lat': 10.726473565638335,
      'long': 122.55836118446929,
      'uid': userCred.user!.uid,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('JARO REGISTERED')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: ${e.code}')));
  }
}

Future<void> registerNational(context) async {
  try {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'national_hanapp@gmail.com', password: 'abc123');
    await registrationRef.child('National').set({
      'uid': userCred.user!.uid,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('NATIONAL REGISTERED')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: ${e.code}')));
  }
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                registerSanJoaquin(context);
              },
              child: Text('Register SAN JOAQIN'),
            ),
            TextButton(
              onPressed: () {
                registerMiagao(context);
              },
              child: Text('Register MIAGAO'),
            ),
            TextButton(
              onPressed: () {
                registerJaro(context);
              },
              child: Text('Register JARO'),
            ),
            TextButton(
              onPressed: () {
                registerNational(context);
              },
              child: Text('Register NATIONAL'),
            ),
          ],
        ),
      ),
    );
  }
}
