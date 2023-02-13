import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hanapp/views/main/login_main.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // variables
  // Controllers to contain the text in the text fields
  late final TextEditingController _email;
  late final TextEditingController _password;

  //
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference registrationRef = FirebaseDatabase.instance.ref("Main Users");


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
        title: const Center(child: Text('Register')) ,
      ),
      body: Center(
        // FutureBuilder's purpose is to wait for the Firebase initialization
        // to complete before proceeding the rest of the code
        child: FutureBuilder(
          // the future is the Firebase initialization, which is asynchronous
          // without future, the code will not wait for the Firebase initialization to complete
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          // context and snapshot are required parameters because the builder is a function that returns a widget
          // what it does is it builds the widget based on the snapshot's connection state
          builder: (context, snapshot) {
            // switch statement to check the connection state
            switch (snapshot.connectionState){
              case ConnectionState.none:
                return const Text("No Connection!");
              case ConnectionState.waiting:
                return const Text('Waiting for Connection');
              case ConnectionState.active:
                return const Text('Connection is active!');
              case ConnectionState.done:
                // if the connection is done, then the code will proceed to the next step
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
                        // onPressed is an asynchronous function because it will wait for the Firebase to complete the registration
                        // before proceeding to the next step
                        onPressed: () async {
                          // get the text from the text fields
                          final email = _email.text;
                          final password = _password.text;
                          // try to register the user
                          try {
                            // create the user
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email, password: password
                            );

                            // Realtime Database User
                            await registrationRef.child(userCredential.user!.uid).set({
                              'email': email,
                              'password': password,
                            });

                            // if the user is created, then proceed to the next step
                            if (kDebugMode) {
                              print('[REGISTERED] $userCredential');
                            }
                            // navigate to the login page
                            if(mounted){
                              Navigator.pop(context);
                            }
                            // if the user is not created, then show the error message
                          } on FirebaseAuthException catch (e) {
                            if(e.code == 'email-already-in-use' ){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email already in use!'),
                                  ),
                              );
                            } else if (e.code == 'weak-password'){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Weak Password!'),
                                ),
                              );
                            } else if (e.code == 'invalid-email') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid email!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something Wrong Happened'),
                                ),
                              );
                              if (kDebugMode) {
                                print('[ERROR]: $e');
                              }
                            }
                          }

                        },
                        onLongPress: () {
                          if (kDebugMode) {
                            // this will be removed later
                            print('[LONG PRESS] long press done, we can do something here');
                          }
                          //
                          // show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Long Pressed'),
                            )
                          );
                        },
                        child: const Text('Register'),
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