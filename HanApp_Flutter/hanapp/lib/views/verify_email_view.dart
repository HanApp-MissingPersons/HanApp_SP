import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Container(
        padding: const EdgeInsets.only(top: 140.0),
        child: Column(children: [
          // simple text
          Padding(
            padding: const EdgeInsets.only(bottom: 45.0),
            child: Center(
                child: Text(
                    'Send Email Verification',
                style: GoogleFonts.inter(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
                )
            ),
          ),

          Center(
            child: Image.asset('images/verify-email.png',
              height: 384,
              fit: BoxFit.fitWidth,),
          ),

          Center(
            // text button
            child: TextButton(
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
                    if(mounted){
                      // show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent'),
                        ),
                      );
                    }
                  }
                },
                // text for text button
                child: const Text('Confirm')
            ),
          )
        ],
        ),
      ),
    );
  }
}