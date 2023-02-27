import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanapp/views/login_view.dart';

import '../../firebase_options.dart';
import '../verify_email_view.dart';

// <!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!>
// TODO: DO NOT REMOVE USING AS REFERENCE
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // returns simple scaffold with appbar and body
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            heightFactor: 240, widthFactor: 240, child: Text('Home Page')),
      ),
      body: FutureBuilder(
        // initialize firebase
        // FutureBuilder is used to handle the async nature of the firebase initialization
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        // build a switch statement to handle the different connection states
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if there is no connection, return a text widget
            case ConnectionState.none:
              return const Center(child: Text('None oh no'));
            // if there is a connection, return a text widget
            case ConnectionState.waiting:
              return const Center(child: Text('Loading . . .'));
            // if the connection is active, return a text widget
            case ConnectionState.active:
              return const Center(child: Text('App loading in...'));
            // if the connection is done, return a text widget
            case ConnectionState.done:
              // get the current user
              final user = FirebaseAuth.instance.currentUser;
              return Center(
                child: Column(
                  children: [
                    const Text('This will be the Homepage'),
                    Text('Current User: ${user!.email}'),
                    ElevatedButton(
                      onPressed: () {
                        // sign out the user
                        FirebaseAuth.instance.signOut();
                        // navigate to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            // if none of the above, return a text widget
            default:
              return const Center(child: Text('Loading . . . '));
          }
        },
      ),
    );
  }
}
