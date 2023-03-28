import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pnphanapp/views/main/report_dashboard_main.dart';
import 'package:pnphanapp/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
            Image.asset('assets/images/pnpLogin.png', height: MediaQuery.of(context).size.height * 0.8),
            Padding(
              padding: EdgeInsets.only(top: 150, left: MediaQuery.of(context).size.height / 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Login',
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
                          prefixIcon:
                          Icon(Icons.lock_outline_rounded),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
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
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                        onPressed: null,
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      width: 250,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 12.0, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                'Having Troubles Logging in?'),
                            TextSpan(
                                text: ' Contact the Developers:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: ' hanapp.sp@gmail.com',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                )
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