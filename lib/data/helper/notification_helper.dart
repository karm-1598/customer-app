// ignore_for_file: empty_catches, unnecessary_new, prefer_const_constructors, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages, unnecessary_null_comparison, avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shopperz/app/modules/order/views/order_history_screen.dart';
import 'package:shopperz/data/model/body/notification_body.dart';
import 'package:shopperz/data/model/body/payload_model.dart';

class NotificationHelper {
  void notificationPermission() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, 
      badge: true, 
      sound: true,
    );
    
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint("User denied permission");
    }
  }

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    
    const AndroidInitializationSettings androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await flutterLocalNotificationsPlugin.initialize(
       settings:initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        try {
          final String? payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            PayLoadBody payLoadBody = PayLoadBody.fromJson(jsonDecode(payload));
            if (payLoadBody.topicName == 'Order Notification') {
              Get.to(() => const OrderHistoryScreen());
            }
          }
        } catch (e) {
          debugPrint('Error handling notification response: $e');
        }
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }

      NotificationHelper.showNotification(
        message,
        flutterLocalNotificationsPlugin,
        false,
      );

      try {
        if (message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);

          if (notificationBody.topic == 'Order Notification') {
            // You might want to show a dialog or navigate based on app state
            // Get.to(() => const OrderHistoryScreen());
          }
        }
      } catch (e) {
        debugPrint('Error processing foreground message: $e');
      }
    });

    // Handle when user taps on notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      
      try {
        if (message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);
          
          if (notificationBody.topic == 'Order Notification' || 
              notificationBody.topic == 'general') {
            Get.to(() => const OrderHistoryScreen());
          }
        }
      } catch (e) {
        debugPrint('Error handling notification tap: $e');
      }
    });
  }

  static Future<void> showNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin fln,
    bool data,
  ) async {
    if (!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      String playLoad = jsonEncode(message.data);
      
      if (data) {
        title = message.data['title'];
        body = message.data['body'];
        image = (message.data['image'] != null && message.data['image'].isNotEmpty)
            ? message.data['image']
            : null;
      } else {
        title = message.notification?.title;
        body = message.notification?.body;
        
        if (GetPlatform.isAndroid) {
          image = (message.notification?.android?.imageUrl != null &&
                  message.notification!.android!.imageUrl!.isNotEmpty)
              ? message.notification!.android!.imageUrl!.startsWith('http')
                  ? message.notification!.android!.imageUrl
                  : message.data['image']
              : null;
        } else if (GetPlatform.isIOS) {
          image = (message.notification?.apple?.imageUrl != null &&
                  message.notification!.apple!.imageUrl!.isNotEmpty)
              ? message.notification!.apple!.imageUrl!.startsWith('http')
                  ? message.notification!.apple!.imageUrl
                  : message.data['image']
              : null;
        }
        
        // Fallback to data image if notification image is not available
        if (image == null || image.isEmpty) {
          image = (message.data['image'] != null && message.data['image'].isNotEmpty)
              ? message.data['image']
              : null;
        }
      }

      if (title != null && body != null) {
        if (image != null && image.isNotEmpty) {
          try {
            await showBigPictureNotificationHiddenLargeIcon(
              title,
              body,
              playLoad,
              image,
              fln,
            );
          } catch (e) {
            debugPrint('Error showing big picture notification: $e');
            await showBigTextNotification(title, body, playLoad, fln);
          }
        } else {
          await showBigTextNotification(title, body, playLoad, fln);
        }
      }
    }
  }

  static Future<void> showBigTextNotification(
    String title,
    String body,
    String payload,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'shopperz_channel_${Random.secure().nextInt(10000)}',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: bigTextStyleInformation,
      playSound: true,
      enableVibration: true,
    );
    
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await fln.show(
      id:Random.secure().nextInt(10000),
      title:title,
      body:body,
      notificationDetails:platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
    String title,
    String body,
    String payload,
    String image,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    try {
      final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon_${Random.secure().nextInt(10000)}');
      final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture_${Random.secure().nextInt(10000)}');
      
      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: body,
        htmlFormatSummaryText: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'shopperz_channel_${Random.secure().nextInt(10000)}',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications',
        importance: Importance.max,
        priority: Priority.max,
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        styleInformation: bigPictureStyleInformation,
        playSound: true,
        enableVibration: true,
      );
      
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await fln.show(
        id:Random.secure().nextInt(10000),
        title:title,
        body:body,
        notificationDetails:platformChannelSpecifics ,        
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error in showBigPictureNotificationHiddenLargeIcon: $e');
      rethrow;
    }
  }

  static NotificationBody convertNotification(Map<String, dynamic> data) {
    return NotificationBody.fromJson(data);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      rethrow;
    }
  }
}

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  
  const AndroidInitializationSettings androidInitialize =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings iOSInitialize = DarwinInitializationSettings();
  
  const InitializationSettings initializationsSettings = InitializationSettings(
    android: androidInitialize,
    iOS: iOSInitialize,
  );
  
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationsSettings,
  );
  
  await NotificationHelper.showNotification(
    message,
    flutterLocalNotificationsPlugin,
    true,
  );
}