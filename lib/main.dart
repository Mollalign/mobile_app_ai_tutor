import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/network/network.dart';
import 'core/network/connectivity_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init failed (notifications disabled): $e');
  }

  ApiClient().init(
    onLogout: () {
      debugPrint('Session expired, logging out...');
    },
  );

  await ConnectivityService().init();

  // Initialize notification service
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service init failed: $e');
  }

  runApp(
    const ProviderScope(
      child: InformaticsTutorApp(),
    ),
  );
}