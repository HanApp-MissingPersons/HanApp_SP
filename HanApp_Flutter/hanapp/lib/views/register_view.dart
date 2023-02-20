import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'verify_email_view.dart';

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
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
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
      //appBar: AppBar(
      //  title: const Center(child: Text('Register')) ,),
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
                return SingleChildScrollView(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/register.png',
                            height: 250,
                            fit: BoxFit.fitWidth,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 40, bottom: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.inter(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: TextFormField( // email
                              controller: _email,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                else if (!value.contains('@') || !value.contains('.')) {
                                  return 'Please enter a valid email';
                                } else {
                                  return null;
                                }
                              },
                            ), // email)
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                            child: TextFormField(
                              controller: _password,
                              obscureText: _obscured,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.key),
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
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
                            ), // password),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                            child: TextFormField(
                              // full name
                              controller: _fullName,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                            child: TextFormField(
                              // phone number
                              controller: _phoneNumber,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone),
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                } else if ( value.length < 10 || value.length > 11) {
                                  return 'Please enter a valid phone number';
                                } else if ( isNumeric(value) == false) {
                                  return 'Please enter a valid phone number';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              width: 250.0,
                              height: 40.0,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        )
                                    )
                                ),
                                // onPressed is an asynchronous function because it will wait for the Firebase to complete the registration
                                // before proceeding to the next step
                                onPressed: () async {
                                  // validate the form and if it is not valid, set the autovalidate mode to always
                                  // get the text from the text fields
                                  final email = _email.text;
                                  final password = _password.text;
                                  final fullName = _fullName.text;
                                  final phoneNumber = _phoneNumber.text;
                                  // try to register the user
                                  try {
                                    // set the autovalidate mode to disabled so that the form will not show errors
                                    if(_formKey.currentState!.validate()){
                                      // if the form is valid, set the autovalidate mode to disabled:
                                      setState(() => _autoValidate = AutovalidateMode.disabled);
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

                                      // // navigate to the login page
                                      // if(mounted){
                                      //   Navigator.pop(context);
                                      // }
                                      if(mounted){
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmailView()));
                                      }

                                    } else {
                                      // if the form is not valid, set the autovalidate mode to always
                                      setState(() => _autoValidate = AutovalidateMode.always);
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
                                    } else if(e.code == 'network-request-failed'){
                                      if(kDebugMode){
                                        print('Not Connected to the internet');
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Connection failed, check your internet connection')));
                                    }
                                    else {
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
                            ),
                          ),
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

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}