import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hanapp/views/main/login_main.dart';

import '../verify_email_view.dart';

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
  late final TextEditingController _fullName;
  late final TextEditingController _phoneNumber;
  late final Future<FirebaseApp> _firebaseInit;
  // _formKey is used to validate the form
  final _formKey = GlobalKey<FormState>();
  // _obscured is used to obscure the password, and is set to true by default
  bool _obscured = true;
  // Firebase Realtime Database initialize
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference registrationRef = FirebaseDatabase.instance.ref("Main Users");


  // initialize the controllers
  @override
  void initState() {
    // binding?
    _email = TextEditingController();
    _password = TextEditingController();
    _fullName = TextEditingController();
    _phoneNumber = TextEditingController();
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
    _fullName.dispose();
    _phoneNumber.dispose();
    _firebaseInit.asStream().drain();
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
          future: _firebaseInit,
          // context and snapshot are required parameters because the builder is a function that returns a widget
          // what it does is it builds the widget based on the snapshot's connection state
          builder: (context, snapshot) {
            // switch statement to check the connection state
            switch (snapshot.connectionState){
              case ConnectionState.none:
                return const Text("No Connection!");
              case ConnectionState.waiting:
                return const Text('Loading . . .');
              case ConnectionState.active:
                return const Text('Connection is active!');
              case ConnectionState.done:
                // if the connection is done, then the code will proceed to the next step
                return Center(
                  child: Form(
                    key: _formKey,
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
                          validator: (String? value) {
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
                          validator: (String? value) {
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
                        TextFormField(
                          // full name
                          controller: _fullName,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            hintText: 'Enter Full Name',
                            labelText: 'Full Name',
                          ),
                        ),
                        TextFormField(
                          // phone number
                          controller: _phoneNumber,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.phone),
                            hintText: 'Enter Phone Number',
                            labelText: 'Phone Number',
                          ),
                        ),
                        ElevatedButton(
                          // onPressed is an asynchronous function because it will wait for the Firebase to complete the registration
                          // before proceeding to the next step
                          onPressed: () async {
                            // get the text from the text fields
                            final email = _email.text;
                            final password = _password.text;
                            final fullName = _fullName.text;
                            final phoneNumber = _phoneNumber.text;
                            // try to register the user
                            try {
                              if(_formKey.currentState!.validate()){
                                // if the form is valid, then proceed to the next step:
                                // create the user
                                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: email, password: password
                                );

                                // Realtime Database User
                                await registrationRef.child(userCredential.user!.uid).set({
                                  'email': email,
                                  'fullName': fullName,
                                  'phoneNumber': phoneNumber,
                                });

                                if (kDebugMode) {
                                  print('[REGISTERED] $userCredential');
                                }

                                // navigate to the login page
                                // if(mounted){
                                //   Navigator.pop(context);
                                // }

                                if (mounted) {
                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerifyEmailView()));
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const VerifyEmailView()));
                                }

                              } else {
                                // if the form is not valid, then show the error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill up the form correctly')));
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