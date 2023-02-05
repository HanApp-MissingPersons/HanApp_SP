import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:hanapp/views/register_view.dart';

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
        title: const Center(child: Text('HOMEPAGE'), heightFactor: 240, widthFactor: 240) ,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return Center(child: Text('None oh no'));
              break;
            case ConnectionState.waiting:
              return Center(child: Text('Loading . . .'));
              break;
            case ConnectionState.active:
              return Center(child: Text('App loading in...'));
              break;
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              final emailVerifiedCheck = user?.emailVerified ?? false;
              if(emailVerifiedCheck) {
                print('[VERIFIED] User is Verified');
                return const Center(child: Text('BRO DONEZA'));
              }
              else {
                print('[UNVERIFIED] User is not verified');
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
    );
  }
}





