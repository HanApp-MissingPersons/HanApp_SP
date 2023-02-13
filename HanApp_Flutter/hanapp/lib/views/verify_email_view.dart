import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // appBar can definitely be removed
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      // simple body will contain text and text button
      body: Column(children: [
        // simple text
        const Center(child: Text('Verify your email first:')),
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
              child: const Text('Send Email Verification')
          ),
        )
      ],
      ),
    );
  }
}