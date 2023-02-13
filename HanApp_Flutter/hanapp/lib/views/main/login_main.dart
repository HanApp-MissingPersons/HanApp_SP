import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:hanapp/views/main/homepage_main.dart';
import 'package:hanapp/views/main/register_main.dart';

import '../verify_email_view.dart';
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
  bool _obscured = true;

  // initialize the controllers
  @override
  void initState() {
    // binding?
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // dispose of the controllers
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // build the view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar to be removed, preferably
      appBar: AppBar(
        title: const Center(child: Text('Login')) ,
      ),
      // body is the main part of the view
      body: Center(
        // FutureBuilder's purpose is to wait for the Firebase initialization
        // to complete before proceeding to the rest of the code
        child: FutureBuilder(
          // the future is the Firebase initialization, which is asynchronous
          // this is required because without future, the code will not wait for the Firebase initialization to complete
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          // context and snapshot are required parameters because the builder is a function that returns a widget
          builder: (context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.none:
                return const Text('No Connection');
              case ConnectionState.waiting:
                return const Text('Loading . . .');
              case ConnectionState.active:
                return const Text('Connection active!');
              case ConnectionState.done:
                return Center(
                  child: Column(
                    children: [
                      TextFormField( // email
                        controller: _email,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          hintText: 'Enter valid Email',
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          else if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          } else {
                            return null;
                          }
                        },
                      ), // email
                      TextFormField(
                        controller: _password,
                        obscureText: _obscured,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.key),
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            // this button is used to toggle the password visibility
                            suffixIcon: IconButton(
                                // if the password is obscured, show the visibility icon
                                // if the password is not obscured, show the visibility_off icon
                                icon: Icon(
                                    _obscured ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscured = !_obscured;
                                  });
                                })
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          } else {
                            return null;
                          }
                        },
                      ), // password
                      TextButton(
                        onPressed: () async {
                          if (kDebugMode) {
                            print("[PRESS] Logging in User");
                          }
                          final email = _email.text;
                          final password = _password.text;
                          // login user with email and password and check if email is verified
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                email: email, password: password
                            );
                            // if user has an unverified email address, proceed to verify email view
                            if (!userCredential.user!.emailVerified){
                              if (kDebugMode) {
                                print('[UNVERIFIED] Email not verified!');
                              }
                              // navigate to verify email view and pass the user's email address through the route
                              // this is done so that the user does not have to enter their email address again
                              if(mounted){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerifyEmailView()));
                              }
                            }
                            // if user has a verified email address, proceed to homepage
                            else {
                              if (kDebugMode) {
                                print('[LOGGED IN] as: $userCredential');
                              }
                              // navigate to homepage
                              if (mounted) {
                                // pushReplacement will remove the login view from the stack, so that the user cannot go back to the login view
                                // pushAndRemoveUntil will remove all the views from the stack, so that the user cannot go back to any view
                                // for now, pushReplacement will be used
                                // preferably, pushReplacement should be used when the user is logging in, and pushAndRemoveUntil should be used when the user is logging out
                                // this is because the user should not be able to go back to the login view after logging in, and the user should not be able to go back to the homepage after logging out
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (
                                        context) => const HomePage()));

                                // Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(builder: (context) => const HomePage()),
                                //     (
                                //             (route) => false
                                //     )
                                // );
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            if(e.code == 'user-not-found'){
                              if (kDebugMode) {
                                print('User not found!');
                              }
                            } else if(e.code == 'wrong-password'){
                              if(kDebugMode){
                                print('Wrong Password');
                              }
                            } else if(e.code == 'invalid-email'){
                              if(kDebugMode){
                                print('Invalid Email Format');
                              }
                            }
                            if(kDebugMode){
                              var error = e;
                              print('error logging in, [$error]');
                            }
                          }
                          // logging in with verified email, go to homepage
                        },
                        onLongPress: () {
                          if (kDebugMode) {
                            print('[LONG PRESS] Button has been long pressed');
                          }
                        },
                        child: const Text('Login'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Register View
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const RegisterView()
                              )
                          );
                          if (kDebugMode) {
                            print('[PRESS] Navigating to Register');
                          }
                        },
                        child: const Text('Register Instead'),
                      ),
                    ], // children
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