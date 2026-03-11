import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Background message handler — must be a top-level function (outside any class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background FCM message: ${message.messageId}');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  // FCM V1 API constants
  static const String _projectId = 'unitask-app';
  static const String _fcmV1Endpoint =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const String _tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const String _fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  // Cached access token
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;

  // ─── Initialize ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Request permission from the user
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notifications for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) print('Foreground notification tapped: ${response.payload}');
      },
    );

    // Create the channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Handle foreground messages
    // FCM automatically shows a notification when the app is in background/terminated.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
          'Foreground FCM message: ${message.notification?.title} - ${message.notification?.body}',
        );
      }

      final notification = message.notification;
      final android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle notification taps when app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('App opened from notification: ${message.data}');
    });
  }

  // ─── FCM Token ──────────────────────────────────────────────────────────────

  /// Get this device's FCM token (needed to send notifications TO this device).
  Future<String?> getToken() async {
    try {
      final token = await _fcm.getToken();
      if (kDebugMode) print('FCM Token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
      return null;
    }
  }

  // ─── Service Account OAuth2 ─────────────────────────────────────────────────

  /// Load the service account JSON from Flutter assets (returns null if not found).
  static Future<Map<String, dynamic>?> _loadServiceAccount() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/service_account.json',
      );
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print(
          'No service_account.json found. Push notifications will be disabled locally.',
        );
      }
      return null;
    }
  }

  /// Create a signed JWT from the service account and exchange it for
  /// a short-lived Google OAuth2 access token (valid 1 hour).
  static Future<String?> _getAccessToken() async {
    // Return cached token if still valid (60s buffer before expiration)
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(seconds: 60)),
        )) {
      return _cachedAccessToken!;
    }

    final sa = await _loadServiceAccount();
    if (sa == null) {
      return null; // Silent failure for teammates without the file
    }

    final privateKeyPem = sa['private_key'] as String;
    final clientEmail = sa['client_email'] as String;

    final now = DateTime.now().toUtc();
    final expiry = now.add(const Duration(hours: 1));

    // Build and sign the JWT with RS256
    final jwt = JWT({
      'iss': clientEmail,
      'scope': _fcmScope,
      'aud': _tokenEndpoint,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    });
    final signedToken = jwt.sign(
      RSAPrivateKey(privateKeyPem),
      algorithm: JWTAlgorithm.RS256,
    );

    // Exchange the signed JWT for a Google OAuth2 access token
    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': signedToken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get access token: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _cachedAccessToken = body['access_token'] as String;
    _tokenExpiry = expiry;
    return _cachedAccessToken!;
  }

  // ─── Send Push Notification ──────────────────────────────────────────────────

  /// Send a push notification using Firebase Cloud Messaging V1 API.
  /// Uses Service Account authentication — no Blaze plan or Cloud Functions needed.
  static Future<void> sendPushNotification({
    required String targetFcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      if (accessToken == null) {
        if (kDebugMode) {
          print(
            'Skipping push notification send: No access token due to missing service_account.json',
          );
        }
        return;
      }

      final payload = {
        'message': {
          'token': targetFcmToken,
          'notification': {'title': title, 'body': body},
          'android': {
            'priority': 'high',
            'notification': {'sound': 'default'},
          },
          'data': ?data,
        },
      };

      final response = await http.post(
        Uri.parse(_fcmV1Endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('FCM V1 response: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error sending push notification: $e');
    }
  }
}
