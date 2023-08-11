import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutterwavepayment/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'package:http/http.dart' as http;

import 'firebase_options.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

DocumentSnapshot? userProfile;
bool isFlutterLocalNotificationsInitialized = false;
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<DocumentSnapshot> getUserProfile(String uid) async {
  userProfile = await firestore.collection('user').doc(uid).get();
  return await firestore.collection('user').doc(uid).get();
}

Future<void> backgroundMessagingHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setUpFlutterNotifications();
  showFlutterNotification(message);
}

Future<void> setUpFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

Future<void> sendEmailNotification(
    GoogleSignInAccount? googleSignInAccount) async {
  Email emailMessage = Email(
      recipients: [googleSignInAccount!.email],
      subject: 'You have logged in using Email: ${googleSignInAccount.email}',
      body: 'You have successfully logged in to your account');

  await FlutterEmailSender.send(emailMessage);
}

Future<void> sendPushMessage(GoogleSignInAccount? googleSignInAccount) async {
  if (googleSignInAccount == null) {
    log('Unable to send FCM message, no token exists.');
    return;
  }

  try {
    await http.post(
      Uri.parse('https://api.rnfirebase.io/messaging/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: constructPayload(googleSignInAccount.id),
    );
    log('FCM request for device sent!');
  } catch (err) {
    log('Error: $err');
  }
}

String constructPayload(String? id) {
  return jsonEncode({
    'token': id,
    'notification': {
      'title': 'Log in notifications',
      'body': 'You have logged in to a device using ',
    },
  });
}

Future<void> sendNotification(GoogleSignInAccount? googleSignInAccount) async {
  final data = {
    "title": "Login Notification",
    "body":
        "You have logged in to a device using ${googleSignInAccount!.email}",
  };
  try {
    await messaging.sendMessage(
      to: googleSignInAccount.email,
      data: data,
      messageType: 'Notification',
    );
    log('Success');
  } catch (err) {
    log('Error: $err');
  }
}

void sendSMSMessage({required String message, List<String>? recipients}) async {
  String result = await sendSMS(message: message, recipients: recipients!)
      .catchError((onError) {
    log(onError);
    return null;
  });
  log(result);
}
