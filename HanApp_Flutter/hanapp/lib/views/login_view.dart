import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:hanapp/views/main/homepage_main.dart';
import 'package:hanapp/views/main/navigation_view_main.dart';
import 'package:hanapp/views/register_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'GmapsTest.dart';
import 'companion/homepage_companion.dart';
import 'verify_email_view.dart';

// this is the login view
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  // creating state means that the view is stateful, which means that it can change
  // the state of the view and the data that the view contains
  @override
  State<LoginView> createState() => _LoginViewState();
}

// this class is the state of the view, which means that it contains the data
// that the view contains
class _LoginViewState extends State<LoginView> {
  // variables
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final Future<FirebaseApp> _firebaseInit;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  // obscured is used to obscure the password
  bool _obscured = true;
  // _formKey is used to validate the form
  final _formKey = GlobalKey<FormState>();

  // initialize the controllers
  @override
  void initState() {
    // binding?
    _email = TextEditingController();
    _password = TextEditingController();
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  // dispose of the controllers
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firebaseInit.asStream().drain();
    super.dispose();
  }

  // build the view
  @override
  Widget build(BuildContext context) {
    // return a scaffold
    return Scaffold(
      // body is the main part of the view
      body: Center(
        // FutureBuilder's purpose is to wait for the Firebase initialization
        // to complete before proceeding to the rest of the code
        child: FutureBuilder(
          // the future is the Firebase initialization, which is asynchronous
          // this is required because without future, the code will not wait for the Firebase initialization to complete
          future: _firebaseInit,
          // context and snapshot are required parameters because the builder is a function that returns a widget
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('No Connection');
              case ConnectionState.waiting:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('HanApp is loading...'),
                  ],
                );
              case ConnectionState.active:
                return const Text('Connection active!');
              case ConnectionState.done:
                DatabaseReference mainUserRef =
                    FirebaseDatabase.instance.ref('Main Users');

                return Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Image.asset(
                              'assets/images/login.png',
                              height: MediaQuery.of(context).size.height * .4,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.inter(
                                    fontSize: 29,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            // email
                            controller: _email,
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                              ),
                              labelText: 'Email address',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email';
                              } else {
                                return null;
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _password,
                              obscureText: _obscured,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  // this button is used to toggle the password visibility
                                  suffixIcon: IconButton(
                                      // if the password is obscured, show the visibility icon
                                      // if the password is not obscured, show the visibility_off icon
                                      icon: Icon(_obscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () {
                                        setState(() {
                                          _obscured = !_obscured;
                                        });
                                      })),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else {
                                  return null;
                                }
                              },
                            ), // password),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              child: SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      //backgroundColor:
                                      //    const MaterialStatePropertyAll<Color>(
                                      //        Color(0xFF6B53FD)),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ))),
                                  onPressed: () async {
                                    if (kDebugMode) {
                                      print("[PRESS] Logging in User");
                                    }
                                    final email = _email.text;
                                    final password = _password.text;
                                    // login user with email and password and check if email is verified
                                    try {
                                      if (_formKey.currentState!.validate()) {
                                        // set _autoValidate to disabled so that the form does not autovalidate
                                        setState(() => _autoValidate =
                                            AutovalidateMode.disabled);
                                        // sign in user with email and password
                                        final userCredential =
                                            await FirebaseAuth.instance
                                                .signInWithEmailAndPassword(
                                                    email: email,
                                                    password: password);
                                        // if user has an unverified email address, proceed to verify email view
                                        if (!userCredential
                                            .user!.emailVerified) {
                                          if (kDebugMode) {
                                            print(
                                                '[UNVERIFIED] Email not verified!');
                                          }
                                          // navigate to verify email view and pass the user's email address through the route
                                          // this is done so that the user does not have to enter their email address again
                                          if (mounted) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const VerifyEmailView()));
                                          }
                                        }
                                        // if user has a verified email address, proceed to homepage
                                        else {
                                          // Conditional Logging in
                                          bool isUserMain = false;
                                          mainUserRef.onValue.listen((event) {
                                            var usersData =
                                                Map<String, dynamic>.from(event
                                                        .snapshot.value
                                                    as Map<dynamic, dynamic>);
                                            for (var value
                                                in usersData.values) {
                                              if (_email.text.toString() ==
                                                  value['email'].toString()) {
                                                isUserMain = true;
                                              }
                                            }
                                            if (isUserMain) {
                                              print('[FOUND] USER IS MAIN');
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const NavigationField()),
                                                      (route) => false);
                                            } else {
                                              print(
                                                  '[NOT FOUND] USER IS COMPANION');
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const NavigationField()),
                                                      (route) => false);
                                            }
                                            // end of conditional logging in
                                          });
                                          if (kDebugMode) {
                                            print(
                                                '[LOGGED IN] as: $userCredential');
                                          }
                                        }
                                      } else {
                                        // set _autoValidate to always so that the form autovalidates
                                        setState(() => _autoValidate =
                                            AutovalidateMode.always);
                                        // if the form is not valid, then show the error message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Please fill up the form correctly')));
                                      }
                                      // FirebaseAuthException is the exception thrown by Firebase when there is an error
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'user-not-found') {
                                        if (kDebugMode) {
                                          print('User not found!');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('User not found!')));
                                      } else if (e.code == 'wrong-password') {
                                        if (kDebugMode) {
                                          print('Wrong Password');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Wrong password!')));
                                      } else if (e.code == 'invalid-email') {
                                        if (kDebugMode) {
                                          print('Invalid Email Format');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Invalid Email Format!')));
                                      } else if (e.code == 'user-disabled') {
                                        if (kDebugMode) {
                                          print('User has been disabled');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'User account has been disabled')));
                                      } else if (e.code ==
                                          'too-many-requests') {
                                        if (kDebugMode) {
                                          print(
                                              'Too many requests, please try again later');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Too many requests, please try again later')));
                                      } else if (e.code ==
                                          'network-request-failed') {
                                        if (kDebugMode) {
                                          print(
                                              'Not Connected to the internet');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Connection failed, check your internet connection')));
                                      } else {
                                        if (kDebugMode) {
                                          print('Unknown Error');
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Oops! Something went wrong')));
                                      }
                                      if (kDebugMode) {
                                        var error = e;
                                        print('error logging in, [$error]');
                                      }
                                    }
                                    // logging in with verified email, go to homepage
                                  },
                                  onLongPress: () {
                                    if (kDebugMode) {
                                      print(
                                          '[LONG PRESS] Button has been long pressed');
                                    }
                                  },
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to Register View
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const RegisterView()));
                              if (kDebugMode) {
                                print('[PRESS] Navigating to Register');
                              }
                            },
                            child: Text(
                              'New to Hanapp? Register',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // for testing only
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const GmapsTest()));
                              },
                              child: const Text('Google Maps Test')),
                          // for testing only
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: 'hanapp.sp@gmail.com',
                                      password: 'abc123');
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavigationField()),
                                    (route) => false);
                              }
                            },
                            child: const Text(
                                'Login as hanapp.sp@gmail.com (for easier testing)'),
                          ),
                          TextButton(
                              onPressed: () {
                                // Navigate to homepage_main.dart
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const SharedPreferencesDemo()));
                              },
                              child: Text('Go test preferences'))
                        ], // children
                      ),
                    ),
                  ),
                );
              default:
                return const Center(child: Text('Loading . . . '));
            }
          },
        ),
      ),
    );
  }
}
