import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('Local notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screen here
    // For now, just print the payload
  }

  /// Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'logbook_verification_channel',
      'Verifikasi Logbook',
      channelDescription: 'Notifikasi untuk verifikasi logbook mahasiswa',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    print('Notification shown: $title');
  }

  /// Start listening to Firestore for new notifications
  Future<void> startListening() async {
    if (_isListening) {
      print('Already listening to notifications');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in, cannot start listening');
      return;
    }

    await initialize();

    // Listen to notifications collection for current user
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final notification = NotificationModel.fromFirestore(change.doc);

              // Only show notification if it's recent (within last 10 seconds)
              final now = DateTime.now();
              final diff = now.difference(notification.createdAt).inSeconds;

              if (diff < 10) {
                // Show local notification
                showNotification(
                  id: notification.createdAt.millisecondsSinceEpoch ~/ 1000,
                  title: notification.title,
                  body: notification.message,
                  payload: notification.logbookId,
                );
              }
            }
          }
        });

    _isListening = true;
    print('Started listening to notifications for user: ${user.uid}');
  }

  /// Stop listening to notifications
  void stopListening() {
    _isListening = false;
    print('Stopped listening to notifications');
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('Notification permission granted: $granted');
      return granted ?? false;
    }

    return true; // For older Android versions
  }
}
