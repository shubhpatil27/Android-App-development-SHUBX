import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================================================
  // FIREBASE
  // ================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ================================================
  // LOCAL DATABASE
  // ================================================

  await DatabaseService.instance.database;

  // ================================================
  // START SHUBX
  // ================================================

  runApp(
    const ShubXApp(),
  );
}