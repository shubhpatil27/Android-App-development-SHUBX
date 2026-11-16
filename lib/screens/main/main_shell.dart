import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../training/train_screen.dart';

class MainShell extends StatefulWidget {
  final UserPreferences initialPreferences;

  const MainShell({
    super.key,
    required this.initialPreferences,
  });

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late UserPreferences _preferences;

  @override
  void initState() {
    super.initState();

    _preferences = widget.initialPreferences;
  }

  // ==================================================
  // PREFERENCES
  // ==================================================

  void _preferencesChanged(
      UserPreferences updated,
      ) {
    setState(() {
      _preferences = updated;
    });
  }

  // ==================================================
  // SCREEN BUILDER
  // ==================================================

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
    // ----------------------------------------------
    // HOME
    // ----------------------------------------------

      case 0:
        return HomeScreen(
          preferences: _preferences,
        );

    // ----------------------------------------------
    // TRAIN
    // ----------------------------------------------

      case 1:
        return TrainScreen(
          preferences: _preferences,
        );

    // ----------------------------------------------
    // PROGRESS
    // ----------------------------------------------

      case 2:
        return ProgressScreen(
          key: ValueKey(
            'progress-${_preferences.hashCode}',
          ),
          preferences: _preferences,
        );

    // ----------------------------------------------
    // PROFILE
    // ----------------------------------------------

      case 3:
        return ProfileScreen(
          preferences: _preferences,
          onPreferencesChanged:
          _preferencesChanged,
        );

      default:
        return HomeScreen(
          preferences: _preferences,
        );
    }
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,

      body: _buildCurrentScreen(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        backgroundColor:
        ShubXColors.charcoal,

        indicatorColor:
        ShubXColors.gold.withValues(
          alpha: 0.16,
        ),

        labelBehavior:
        NavigationDestinationLabelBehavior
            .alwaysShow,

        onDestinationSelected: (index) {
          if (_currentIndex == index) {
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          // ==========================================
          // HOME
          // ==========================================

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: ShubXColors.gold,
            ),
            label: 'Home',
          ),

          // ==========================================
          // TRAIN
          // ==========================================

          NavigationDestination(
            icon: Icon(
              Icons.fitness_center_outlined,
            ),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: ShubXColors.gold,
            ),
            label: 'Train',
          ),

          // ==========================================
          // PROGRESS
          // ==========================================

          NavigationDestination(
            icon: Icon(
              Icons.show_chart,
            ),
            selectedIcon: Icon(
              Icons.show_chart,
              color: ShubXColors.gold,
            ),
            label: 'Progress',
          ),

          // ==========================================
          // PROFILE
          // ==========================================

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
              color: ShubXColors.gold,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}