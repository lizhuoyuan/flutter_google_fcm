import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_fcm/notification_manager.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RemoteMessage message;
  String token;

  @override
  void initState() {
    super.initState();
    initFirebase();
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            Text('fcm token:$token'),
            Text('title:${message?.notification?.title},\nbody:${message?.notification?.body},'),
          ],
        ),
      ),
    );
  }

  void initFirebase() async {
    await NotificationManager.init();
    token = await NotificationManager.getToken();
    setState(() {});
  }
}
