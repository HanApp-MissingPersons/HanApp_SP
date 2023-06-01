import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/views/main/pages/reports.dart';
import 'package:pnphanapp/views/main/pnp_navigation_view.dart';
import 'package:pnphanapp/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pnphanapp/views/registerViewTest.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    DatabaseReference mainUserRef = FirebaseDatabase.instance.ref('Main Users');

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(screenHeight * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            screenWidth > 1000
                ? Expanded(
                    child: Image.asset(
                      'assets/images/pnpLogin.png',
                      height: screenHeight * 0.8,
                    ),
                  )
                : SizedBox(),
            Padding(
              padding: EdgeInsets.only(
                  top: 15,
                  left: screenWidth > 600 ? screenHeight / 20 : 0,
                  right: screenWidth / 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: screenWidth > 600 ? 29 : 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: SizedBox(
                      width: screenWidth > 600 ? 360 : screenWidth * 0.8,
                      child: TextFormField(
                        controller: _email,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                          ),
                          labelText: 'Email address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth > 600 ? 360 : screenWidth * 0.8,
                    child: TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: SizedBox(
                      height: 35,
                      width: screenWidth > 600 ? 360.0 : screenWidth * 0.8,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF6B53FD)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            if (_email.text.isNotEmpty &&
                                _password.text.isNotEmpty) {
                              bool isUserPNP = true;
                              mainUserRef.onValue.listen((event) async {
                                var usersData = Map<String, dynamic>.from(event
                                    .snapshot.value as Map<dynamic, dynamic>);
                                for (var value in usersData.values) {
                                  if (_email.text.toString() ==
                                      value['email'].toString()) {
                                    isUserPNP = false;
                                  }
                                }
                                if (isUserPNP) {
                                  print('[FOUND] USER IS PNP');

                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: _email.text,
                                    password: _password.text,
                                  );

                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NavRailView(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'PNP Account error. Contact the developers for assistance.'),
                                    ),
                                  );
                                }
                                // end of conditional logging in
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fields cannot be empty!'),
                                ),
                              );
                              setState(() {});
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              if (kDebugMode) {
                                print('User not found!');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not found!'),
                                ),
                              );
                            } else if (e.code == 'wrong-password') {
                              if (kDebugMode) {
                                print('Wrong Password');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wrong password!'),
                                ),
                              );
                            } else if (e.code == 'invalid-email') {
                              if (kDebugMode) {
                                print('Invalid Email Format');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid Email Format!'),
                                ),
                              );
                            } else if (e.code == 'user-disabled') {
                              if (kDebugMode) {
                                print('User has been disabled');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('User account has been disabled'),
                                ),
                              );
                            } else if (e.code == 'too-many-requests') {
                              if (kDebugMode) {
                                print(
                                    'Too many requests, please try again later');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Too many requests, please try again later'),
                                ),
                              );
                            } else if (e.code == 'network-request-failed') {
                              if (kDebugMode) {
                                print('Not Connected to the internet');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Connection failed, check your internet connection'),
                                ),
                              );
                            } else {
                              if (kDebugMode) {
                                print('Unknown Error');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Oops! Something went wrong'),
                                ),
                              );
                              setState(() {});
                            }
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      'Forgot Password?',
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  kDebugMode
                      ? TextButton(
                          onPressed: () {
                            // navigate to registerView
                            if (kDebugMode) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterView(),
                                ),
                              );
                            } else {
                              // snackbar to tell user to contact developers
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Not in debug mode, contact developers.'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Register (for testing only)',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.black),
                          ),
                        )
                      : const SizedBox(),
                  kDebugMode
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: 'miagao_hanapp@gmail.com',
                                password: 'abc123',
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const NavRailView(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text('Login as Miagao'),
                          ),
                        )
                      : const SizedBox(),
                  kDebugMode
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: 'sanjoaqin_hanapp@gmail.com',
                                password: 'abc123',
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const NavRailView(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text('Login as San Joaqin'),
                          ),
                        )
                      : const SizedBox(),
                  kDebugMode
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: 'jaro_hanapp@gmail.com',
                                password: 'abc123',
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const NavRailView(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text('Login as Jaro'),
                          ),
                        )
                      : const SizedBox(),
                  kDebugMode
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: 'national_hanapp@gmail.com',
                                password: 'abc123',
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const NavRailView(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text('Login as National'),
                          ),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight / 15),
                    child: Container(
                      width: 250,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12.0, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(text: 'Having Troubles Logging in?'),
                            TextSpan(
                              text: ' Contact the Developers: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: 'hanapp.sp@gmail.com',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
