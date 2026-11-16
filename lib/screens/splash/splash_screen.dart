import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';

import '../auth/auth_screen.dart';
import '../main/main_shell.dart';
import '../onboarding/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  bool _showShubX = false;

  UserPreferences? _preferences;

  User? _firebaseUser;

  @override
  void initState() {
    super.initState();

    _startLaunchSequence();
  }

  // ==================================================
  // STARTUP
  // ==================================================

  Future<void>
  _startLaunchSequence() async {
    // Load local SHUBX preferences while
    // the branding screens are displayed.
    final preferences =
    await PreferencesService.instance
        .loadPreferences();

    _preferences = preferences;

    // Firebase restores a previously authenticated
    // session automatically.
    _firebaseUser =
        AuthService.instance.currentUser;

    // ==============================================
    // SCREEN 1
    // Crois En Toi
    // ==============================================

    await Future.delayed(
      const Duration(
        milliseconds: 1200,
      ),
    );

    if (!mounted) return;

    setState(() {
      _showShubX = true;
    });

    // ==============================================
    // SCREEN 2
    // SHUBX
    // DEFINE YOUR X.
    // ==============================================

    await Future.delayed(
      const Duration(
        milliseconds: 1200,
      ),
    );

    if (!mounted) return;

    _continueIntoApp();
  }

  // ==================================================
  // ROUTING
  // ==================================================

  void _continueIntoApp() {
    // ----------------------------------------------
    // NOT SIGNED IN
    //
    // Account authentication now happens before
    // SHUBX onboarding or MainShell.
    // ----------------------------------------------

    if (_firebaseUser == null) {
      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
          const AuthScreen(),
        ),
      );

      return;
    }

    // ----------------------------------------------
    // SIGNED IN + LOCAL SETUP EXISTS
    // ----------------------------------------------

    if (_preferences != null) {
      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              MainShell(
                initialPreferences:
                _preferences!,
              ),
        ),
      );

      return;
    }

    // ----------------------------------------------
    // SIGNED IN + NEW INSTALL / NO SETUP
    //
    // Continue into the onboarding system you
    // already built.
    // ----------------------------------------------

    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
        const WelcomeScreen(),
      ),
    );
  }

  // ==================================================
  // UI
  // ==================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,

      body: SafeArea(
        child: AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds: 450,
          ),

          switchInCurve:
          Curves.easeOut,

          switchOutCurve:
          Curves.easeIn,

          child: _showShubX
              ? const _ShubXBrand()
              : const _CroisEnToiBrand(),
        ),
      ),
    );
  }
}

// ====================================================
// CROIS EN TOI
// ====================================================

class _CroisEnToiBrand
    extends StatelessWidget {
  const _CroisEnToiBrand();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const SizedBox.expand(
      key: ValueKey(
        'crois-en-toi',
      ),

      child: Center(
        child: Text(
          'Crois En Toi',

          style: TextStyle(
            color:
            ShubXColors.gold,

            fontSize: 25,

            fontWeight:
            FontWeight.w400,

            fontStyle:
            FontStyle.italic,

            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ====================================================
// SHUBX
// ====================================================

class _ShubXBrand
    extends StatelessWidget {
  const _ShubXBrand();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const SizedBox.expand(
      key: ValueKey(
        'shubx-brand',
      ),

      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Text(
              'SHUBX',

              style: TextStyle(
                color:
                ShubXColors.white,

                fontSize: 42,

                fontWeight:
                FontWeight.w900,

                letterSpacing: 6,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Text(
              'DEFINE YOUR X.',

              style: TextStyle(
                color:
                ShubXColors.gold,

                fontSize: 10,

                fontWeight:
                FontWeight.w700,

                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}