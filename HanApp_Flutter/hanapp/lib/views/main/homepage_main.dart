import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../verify_email_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(heightFactor: 240, widthFactor: 240, child: Text('HOME Page')) ,
      ),
      body: FutureBuilder(
        // initialize firebase
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
              return const Center(child: Text('None oh no'));
            case ConnectionState.waiting:
              return const Center(child: Text('Loading . . .'));
            case ConnectionState.active:
              return const Center(child: Text('App loading in...'));
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              return Center(
                child: Column(
                  children: [
                  const Text('This will be the Homepage'),
                    Text('Current User: ${user!.email}'),
                ],),
              );
            default:
              return const Center(child: Text('Loading . . . '));
          }
        },
      ),
    );
  }
}