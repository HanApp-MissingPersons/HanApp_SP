import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hanapp/views/main/navigation_view_main.dart';

void main() async {
  // initialize firebase
  // ensureInitialized is used to ensure that the app is initialized before the
  // runApp() function is called because the runApp() function is asynchronous
  // WidgetsFlutterBinding is needed because the app is a Flutter app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // this is where we check if the user is signed in
    loadUser();
    return MaterialApp(
      title: 'HanApp Initial Set Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // proceed to login page if user is not signed in, otherwise proceed to home page
      home: isUserSignedIn ? const NavigationField() : const LoginView(),
    );
  }
}

// this is the variable that we use to check if the user is signed in
bool isUserSignedIn = false;
// this is the function that we use to check if the user is signed in
Future<void> loadUser() async {
  isUserSignedIn = false;
  var tempuser = FirebaseAuth.instance.currentUser;
  if (tempuser != null && tempuser.emailVerified) {
    isUserSignedIn = true;
  }
  if (kDebugMode) {
    print('[LOGGED IN STATUS] $isUserSignedIn');
  }
}
