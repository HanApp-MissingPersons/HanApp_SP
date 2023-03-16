import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
  // DatabaseReference mainUserRef =
  //     FirebaseDatabase.instance.ref('Main Users').child(user.uid);

  late final Future<FirebaseApp> _firebaseInit;
  @override
  void initState() {
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Balls'),
        ),
        body: FutureBuilder(
          future: _firebaseInit,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Oops! something went wrong!'));
            } else {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(child: Text('None oh no'));
                case ConnectionState.waiting:
                  return const Center(
                    child: Center(
                      child: SpinKitCubeGrid(
                        color: Palette.indigo,
                        size: 50.0,
                      ),
                    ),
                  );
                case ConnectionState.active:
                  return const Center(child: Text('Connection active.'));
                case ConnectionState.done:
                  final user = FirebaseAuth.instance.currentUser;
                  DatabaseReference mainUserRef = FirebaseDatabase.instance
                      .ref('Main Users')
                      .child(user!.uid);

                  return Column(
                    children: [
                      Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 3),
                          child: Text('Current User data: \n\n$mainUserRef')),
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
                  );
              }
            }
          },
        ));
  }
}
