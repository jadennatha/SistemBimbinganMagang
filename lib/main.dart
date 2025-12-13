import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications
  final notificationService = LocalNotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();

  // Start listening for notifications
  // This will be called again after login to ensure user context
  await notificationService.startListening();

  // Jalur biasa, mulai dari splash lalu ke alur mahasiswa
  runApp(const MyApp());
}
