import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SendNotif extends StatefulWidget {
  const SendNotif({Key? key}) : super(key: key);

  @override
  _SendNotifState createState() => _SendNotifState();
}

class _SendNotifState extends State<SendNotif> {
  final _formKey = GlobalKey<FormState>();
  String _notificationText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Messaging'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send notification to all users:'),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter notification text',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (value) {
                  _notificationText = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    sendNotificationToAllUsers(_notificationText);
                  }
                },
                child: Text('Send notification'),
              ),
              SizedBox(height: 16.0),
              Text('Subscribe to topic:'),
              ElevatedButton(
                onPressed: () {
                  FirebaseMessaging.instance.subscribeToTopic('all');
                },
                child: Text('Subscribe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendNotificationToAllUsers(String text) async {
    await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.sendMessage(
      to: '/topics/all',
      data: <String, String>{
        'title': 'New notification',
        'body': text,
      },
    );
    // await FirebaseMessaging.instance.sendAll(<String, dynamic>{
    //   'notification': <String, dynamic>{
    //     'title': 'New notification',
    //     'body': text,
    //   },
    //   'data': <String, dynamic>{
    //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    //     'type': 'NOTIFICATION',
    //   },
    // });
  }
}
