import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:hanapp/views/main/homepage_main.dart';
import 'package:hanapp/views/main/register_main.dart';

import '../verify_email_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  // variables
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // binding?
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Login')) ,
      ),
      body: Center(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.none:
              // TODO: Handle this case.
                return const Text('No Connection');
              case ConnectionState.waiting:
              // TODO: Handle this case.
                return const Text('Waiting for Connection');
              case ConnectionState.active:
              // TODO: Handle this case.
                return const Text('Connection active!');
              case ConnectionState.done:
                return Center(
                  child: Column(
                    children: [
                      TextField( // email
                        controller: _email,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter Email',
                        ),
                      ),
                      TextField( // password
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (kDebugMode) {
                            print("[PRESS] Balls");
                          }
                          final email = _email.text;
                          final password = _password.text;
                          // login user
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                email: email, password: password
                            );
                            // if user has an unverified email
                            if (!userCredential.user!.emailVerified){
                              if (kDebugMode) {
                                print('Email not verified!');
                              }
                              if(mounted){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerifyEmailView()));
                              }
                            }
                            else {
                              if (kDebugMode) {
                                print('[LOGGED IN] as: $userCredential');
                              }
                              if(mounted){
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
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