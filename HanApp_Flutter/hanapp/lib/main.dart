import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/views/main/login_view_main.dart';
import 'package:hanapp/views/main/register_view_main.dart';

import 'firebase_options.dart';

void main() {
  // initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // LANDING PAGE HERE
      home: const RegisterView(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(heightFactor: 240, widthFactor: 240, child: Text('HOMEPAGE')) ,
      ),
      body: FutureBuilder(
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
                return const Center(child: Text('BRO DONEZA'));
              }
              else {
                if (kDebugMode) {
                  print('[UNVERIFIED] User is not verified');
                }
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VerifyEmailView(),
                    )
                );
              }
              return const Center(child: Text('Verify your email first'));
            default:
              return const Center(child: Text('Loading . . . '));
          }
        },
      ),
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: 11:25:21
      appBar: AppBar(
        title: const Center(child: Text('Verify Email')),
      ),
      body: const Center(child: Text('verify email here')),
    );
  }
}





