import 'package:flutter/material.dart';
import 'package:hanapp/views/login_view.dart';

void main() {
  // initialize firebase
  // ensureInitialized is used to ensure that the app is initialized before the
  // runApp() function is called because the runApp() function is asynchronous
  // WidgetsFlutterBinding is needed because the app is a Flutter app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanApp Initial Set Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // proceed to login
      home: const LoginView(),
    );
  }
}
