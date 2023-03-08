import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanapp/views/login_view.dart';

// stateful widget boilerplate
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

// view state
class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    // will build a scaffold in verify email view/page
    return Scaffold(
      // simple body will contain text and text button
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
          child: Column(
            children: [
              // simple text
              Container(
                padding: const EdgeInsets.only(bottom: 20.0),
                // added margin to top of text to prevent it from being too close to the top of the screen
                margin: const EdgeInsets.only(top: 60.0),
                child: Center(
                    child: Text(
                  'Send Email Verification',
                  style: GoogleFonts.inter(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                )),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 45.0),
                child: Center(
                    child: Text(
                  'Once sent, check your inbox for a verification email.\nIf you don\'t see it, check your spam folder.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                )),
              ),

              Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Image.asset(
                    "assets/images/verify-email_2.png",
                    height: 304,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              Center(
                // text button
                child: SizedBox(
                  height: MediaQuery.of(context).size.width*0.1,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              const MaterialStatePropertyAll<Color>(Color(0xFF6B53FD)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      // on pressed will send email verification, should be async since FirebaseAuth is async
                      onPressed: () async {
                        // get current logged in user
                        final user = FirebaseAuth.instance.currentUser;
                        // gatekeeper, make sure user is valid and email is unverified before sending verification email
                        if (user != null && !user.emailVerified) {
                          // send verification email
                          await user.sendEmailVerification();
                          // show snackbar to notify user that verification email has been sent
                          // mounted is a bool that checks if the widget is mounted or live,
                          // since this is a stateful widget, it is necessary to check if the widget is mounted before showing a snackbar
                          if (mounted) {
                            // show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification email sent'),
                              ),
                            );
                            // navigate to login page

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const LoginView()));
                          }
                        }
                      },
                      // text for text button
                      child: Text('Send Verification Email',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),)),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: TextButton(
                    onPressed: () {
                      // navigate to login page
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginView()));
                    },
                    child: const Text('Already verified? Log In'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
