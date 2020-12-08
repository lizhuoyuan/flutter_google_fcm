import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///FCM配置

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);

class NotificationManager {
  static Future<String> getToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    print('Token:$token');
    return token;
  }

  static init() async {
    await Firebase.initializeApp();

    var initializationSettingsAndroid = new AndroidInitializationSettings('launch_background');
    var initializationSettingsIOS = new IOSInitializationSettings();

    FlutterLocalNotificationsPlugin().initialize(
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: initializationSettingsIOS),
        onSelectNotification: _onSelectNotification);

    ///ios , mac, web需要请求权限
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    ///ios启用前台通知
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    ///前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('在前台收到消息！');

      if (message.notification != null) {
        RemoteNotification notification = message.notification;

        ///显示通知
        if (notification != null && notification.android != null) {
          FlutterLocalNotificationsPlugin().show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                ),
              ),
              payload: message.data.toString());
        }
      }
    });

    ///后台消息
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    ///点击后台消息打开App
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('从后台打开！');
    });

    ///应用从终止状态打开
    var m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) {
      print('应用从终止状态打开:${m?.notification?.title}');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("收到后台消息: ${message.messageId}");
  }

  static Future _onSelectNotification(String payload) {
    print('前台通知点击:$payload');
  }
}
