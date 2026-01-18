import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/network/network.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  ApiClient().init(
    onLogout: () {
      // This will be called when token refresh fails
      // Navigation will be handled by auth state listener
      debugPrint('Session expired, logging out...');
    },
  );

  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: InformaticsTutorApp(),
    ),
  );
}