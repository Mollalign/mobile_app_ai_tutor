import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/network/network.dart';
import 'core/network/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient().init(
    onLogout: () {
      debugPrint('Session expired, logging out...');
    },
  );

  await ConnectivityService().init();

  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: InformaticsTutorApp(),
    ),
  );
}