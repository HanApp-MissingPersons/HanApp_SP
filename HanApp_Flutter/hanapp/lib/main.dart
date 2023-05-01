import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hanapp/views/main/navigation_view_main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  // initialize firebase
  // ensureInitialized is used to ensure that the app is initialized before the
  // runApp() function is called because the runApp() function is asynchronous
  // WidgetsFlutterBinding is needed because the app is a Flutter app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await notificationSettings();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('[FOREGROUND MESSAGE] onMessage: ${message.data}');
      if (message.notification != null) {
        print('[FOREGROUND NOTIFICATION] onMessage: ${message.notification}');
      }
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

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
        primarySwatch: Palette.indigo,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
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

Future<void> notificationSettings() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print('[NOTIFICATION SETTINGS] ${settings.authorizationStatus}');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('[BACKGROUND MESSAGE] onMessage: ${message.data}');
    if (message.notification != null) {
      print('[BACKGROUND NOTIFICATION] onMessage: ${message.notification}');
    }
  }
}

class Palette {
  static const MaterialColor indigo = MaterialColor(
    0xFF6B53FD, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF604be4), //10%
      100: Color(0xff5642ca), //20%
      200: Color(0xff4b3ab1), //30%
      300: Color(0xff403298), //40%
      400: Color(0xff362a7f), //50%
      500: Color(0xff2b2165), //60%
      600: Color(0xff20194c), //70%
      700: Color(0xff151133), //80%
      800: Color(0xff0b0819), //90%
      900: Color(0xff000000), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.
