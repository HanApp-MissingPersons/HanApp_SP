import 'package:firebase_auth/firebase_auth.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/pnpLogin.png',
                height: MediaQuery.of(context).size.height * 0.8),
            Padding(
              padding: EdgeInsets.only(
                  top: 15, left: MediaQuery.of(context).size.height / 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: SizedBox(
                      //EMAIL
                      width: 360,
                      child: TextFormField(
                        //controller: _email,
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
                        //validator: put here...
                      ),
                    ),
                  ),
                  SizedBox(
                    //PASSWORD
                    width: 360,
                    child: TextFormField(
                      //controller: _password,
                      //obscureText: _obscured,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          // this button is used to toggle the password visibility
                          // CHANGE INTO ICON BUTTON ...
                          suffixIcon: Icon(Icons.visibility_outlined)
                          //IconButton(icon: Icons.visibility_outlined, onPressed: null,),
                          // if the password is obscured, show the visibility icon
                          // if the password is not obscured, show the visibility_off icon
                          //    icon: Icon(_obscured
                          //        ? Icons.visibility_outlined
                          //        : Icons.visibility_off_outlined),
                          //onPressed: () {
                          //  setState(() {
                          //    _obscured = !_obscured;
                          //  });
                          //})
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: SizedBox(
                      height: 35,
                      width: 360.0,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                const MaterialStatePropertyAll<Color>(
                                    Color(0xFF6B53FD)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                        onPressed: () {
                          const NavRailView();
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
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
                  //
                  // text button to register hard-coded pnp accounts
                  kDebugMode
                      ? TextButton(
                          onPressed: () {
                            // navigate to registerView
                            if (kDebugMode) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const RegisterView()));
                            } else {
                              // snackbar to tell user to contact developers
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Not in debug mode, contact developers.')));
                            }
                          },
                          child: Text(
                            'Register (for testing only)',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.black),
                          ),
                        )
                      : const SizedBox(),
                  //
                  // login hard-coded pnp accounts
                  kDebugMode
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: 'miagao_hanapp@gmail.com',
                                      password: 'abc123');
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NavRailView()),
                                  (route) => false);
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
                                      password: 'abc123');
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NavRailView()),
                                  (route) => false);
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
                                      password: 'abc123');
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NavRailView()),
                                  (route) => false);
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
                                      password: 'abc123');
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NavRailView()),
                                  (route) => false);
                            },
                            child: Text('Login as National'),
                          ),
                        )
                      : const SizedBox(),
                  // end of login hard-coded pnp accounts
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
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
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: 'hanapp.sp@gmail.com',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                )),
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
