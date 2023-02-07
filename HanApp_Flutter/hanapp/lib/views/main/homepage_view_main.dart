import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../verify_email_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(heightFactor: 240, widthFactor: 240, child: Text('Landing Page')) ,
      ),
      body: FutureBuilder(
        // initialize firebase
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return const Center(child: Text('None oh no'));
            case ConnectionState.waiting:
              return const Center(child: Text('Loading . . .'));
            case ConnectionState.active:
              return const Center(child: Text('App loading in...'));
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              final emailVerifiedCheck = user?.emailVerified ?? false;
              if(emailVerifiedCheck) {
                if (kDebugMode) {
                  print('[VERIFIED] User is Verified');
                }
                return const Center(child: Text('User is verified'));
              }
              else {
                if (kDebugMode) {
                  print('[UNVERIFIED] User is not verified');
                }
                return const VerifyEmailView();
              }
            default:
              return const Center(child: Text('Loading . . . '));
          }
        },
      ),
    );
  }
}