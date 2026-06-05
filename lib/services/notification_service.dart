import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../const.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. INISIALISASI UTAMA LAYANAN NOTIFIKASI
  Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Status izin notifikasi: ${settings.authorizationStatus}');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notifikasi GasTugas',
      description:
          'Channel untuk memunculkan pengingat tugas kuliah secara real-time.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Mendengarkan notifikasi masuk saat aplikasi sedang dibuka (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Menerima pesan: ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'Notifikasi GasTugas',
        channelDescription: 'Channel untuk notifikasi tugas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  // 3. MENGIRIM TOKEN FCM KE SERVER LARAGON
  Future<void> dapatkanDanSimpanToken(int idUser) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("Token FCM Anda: $token");

      if (token != null) {
        final urlEndpoint = Uri.parse("${BaseUrl.url}/register_token.php");

        final respon = await http.post(
          urlEndpoint,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id_user": idUser,
            "fcm_token": token,
          }),
        );

        if (respon.statusCode == 200) {
          debugPrint("Token FCM berhasil disimpan ke database via BaseUrl!");
        } else {
          debugPrint("Gagal simpan token. Status code: ${respon.statusCode}");
        }
      }
    } catch (e) {
      debugPrint("Terjadi kesalahan FCM Token: $e");
    }
  }
}
