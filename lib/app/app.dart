import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import 'theme.dart';

class ShubXApp extends StatelessWidget {
  const ShubXApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHUBX',

      debugShowCheckedModeBanner: false,

      theme: ShubXTheme.darkTheme,

      // ==============================================
      // SHUBX STARTUP
      //
      // Always begin with the branded experience.
      //
      // Crois En Toi
      //      ↓
      // SHUBX
      //      ↓
      // Authentication / App
      // ==============================================

      home: const SplashScreen(),
    );
  }
}