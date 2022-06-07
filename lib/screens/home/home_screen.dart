// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_chat/screens/auth/userController.dart';
import 'package:get_chat/screens/chat/all_users.dart';

import '../../main.dart';

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser!.uid;
  //String? userEmail = FirebaseAuth.instance.currentUser!.email;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': token.toString()
    // FieldValue.arrayUnion([token]),
  });
}

Future<void> getFirebaseToken() async {
  // Get the token each time the application loads
  String? token = await FirebaseMessaging.instance.getToken();
  // Save the initial token to the database

  await saveTokenToDatabase(token!);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getFirebaseToken();

    //gives message on which user taps and opens app from terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print('opened app from terminated');
      if (message != null) {
        print('received message from terminated: $message');
      }
    });

    // end different video

    //When App is in Foreground, does not show popup, but gets message, does not run when app is in background
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      print('onMessage in foreground: $message');
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher'),
          ),
        );
      }
    });

    //Fires when User CLICKS notification while app only is in background and not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!: $message');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print('on message opened app: $message');
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? '-1'),
                content: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body ?? '-1'),
                  ],
                )),
              );
            });
      }
      //final routeFromMessage = message.data["route"];
      //Navigator.pushNamed(context, routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    var userController = Get.put(UserController());

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 48, 207, 208),
              Color.fromARGB(255, 51, 8, 103),
            ],
          ),
        ),
        child: Column(
          children: [
            //TITLE
            const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Text(
                "Get Chat",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 50,
                ),
              ),
            ),

            //Greeting
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 30.0),
                child: Obx(
                  () => Text(
                    "Hello ${userController.user.firstName ?? 'User'},",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
            ),
            // CHAT SCREEN BUTTON
            InkWell(
              onTap: () {
                Get.to(() => const AllUsers());
              },
              child: Container(
                margin: const EdgeInsets.only(top: 200),
                height: 80,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        "Go Chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.people,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 40,
        width: 40,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.grey,
            elevation: 0,
            child: const Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              Get.to(() => const Settings());
            },
          ),
        ),
      ),
    );
  }
}
