import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';

import '../auth/auth_screen.dart';
import 'edit_x_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserPreferences preferences;

  final ValueChanged<UserPreferences>
  onPreferencesChanged;

  const ProfileScreen({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  late UserPreferences _preferences;

  final TextEditingController
  _heightController =
  TextEditingController();

  final TextEditingController
  _weightController =
  TextEditingController();

  User? _user;

  bool _accountLoading = true;
  bool _accountActionLoading = false;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();

    _preferences =
        widget.preferences;

    _loadPreferenceControllers();

    _loadAccount();
  }

  @override
  void didUpdateWidget(
      covariant ProfileScreen oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.preferences !=
        widget.preferences) {
      _preferences =
          widget.preferences;

      _loadPreferenceControllers();
    }
  }

  void _loadPreferenceControllers() {
    if (_preferences.heightCm != null) {
      _heightController.text =
          _preferences.heightCm!
              .toStringAsFixed(0);
    } else {
      _heightController.clear();
    }

    if (_preferences.weightKg != null) {
      _weightController.text =
          _preferences.weightKg!
              .toStringAsFixed(1);
    } else {
      _weightController.clear();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  // ==================================================
  // ACCOUNT
  // ==================================================

  Future<void> _loadAccount() async {
    setState(() {
      _accountLoading = true;
    });

    try {
      final current =
          AuthService.instance.currentUser;

      if (current != null) {
        await current.reload();
      }

      if (!mounted) return;

      setState(() {
        _user =
            FirebaseAuth.instance.currentUser;

        _accountLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _user =
            AuthService.instance.currentUser;

        _accountLoading = false;
      });
    }
  }

  String get _accountName {
    final name =
    _user?.displayName?.trim();

    if (name == null ||
        name.isEmpty) {
      return 'SHUBX USER';
    }

    return name;
  }

  String get _initial {
    final name =
    _accountName.trim();

    if (name.isEmpty) {
      return 'X';
    }

    return name[0].toUpperCase();
  }

  Future<void>
  _sendVerificationEmail() async {
    if (_accountActionLoading) {
      return;
    }

    setState(() {
      _accountActionLoading = true;
    });

    try {
      await AuthService.instance
          .resendVerificationEmail();

      if (!mounted) return;

      _showMessage(
        'Verification email sent.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Could not send verification email.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not send verification email: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _accountActionLoading = false;
        });
      }
    }
  }

  Future<void>
  _refreshVerification() async {
    if (_accountActionLoading) {
      return;
    }

    setState(() {
      _accountActionLoading = true;
    });

    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await user.reload();

      final refreshed =
          FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        _user = refreshed;
      });

      if (refreshed?.emailVerified ==
          true) {
        _showMessage(
          'Email verified.',
        );
      } else {
        _showMessage(
          'Email is not verified yet.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _accountActionLoading = false;
        });
      }
    }
  }

  Future<void>
  _sendPasswordReset() async {
    final email =
        _user?.email;

    if (email == null ||
        email.isEmpty) {
      _showMessage(
        'No email is associated with this account.',
      );

      return;
    }

    if (_accountActionLoading) {
      return;
    }

    setState(() {
      _accountActionLoading = true;
    });

    try {
      await AuthService.instance
          .sendPasswordReset(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Password reset email sent to $email.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Could not send password reset email.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _accountActionLoading = false;
        });
      }
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          ShubXColors.card,

          title: const Text(
            'Sign out?',
            style: TextStyle(
              color:
              ShubXColors.white,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          content: const Text(
            'Your workouts currently remain stored locally on this device.',
            style: TextStyle(
              color:
              ShubXColors.grey,
              height: 1.4,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'CANCEL',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'SIGN OUT',
                style: TextStyle(
                  color:
                  Colors.redAccent,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _signOut();
  }

  Future<void> _signOut() async {
    setState(() {
      _accountActionLoading = true;
    });

    try {
      await AuthService.instance
          .signOut();

      if (!mounted) return;

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
          const AuthScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _accountActionLoading = false;
      });

      _showMessage(
        'Could not sign out: $error',
      );
    }
  }

  // ==================================================
  // EDIT X
  // ==================================================

  Future<void> _editX() async {
    final updated =
    await Navigator.of(context)
        .push<UserPreferences>(
      MaterialPageRoute(
        builder: (_) =>
            EditXScreen(
              preferences:
              _preferences,
            ),
      ),
    );

    if (updated == null ||
        !mounted) {
      return;
    }

    setState(() {
      _preferences = updated;
    });

    widget.onPreferencesChanged(
      updated,
    );
  }

  // ==================================================
  // PROFILE PREFERENCES
  // ==================================================

  Future<void>
  _saveProfilePreferences() async {
    final height =
    double.tryParse(
      _heightController.text.trim(),
    );

    final enteredWeight =
    double.tryParse(
      _weightController.text.trim(),
    );

    if (_heightController.text
        .trim()
        .isNotEmpty &&
        height == null) {
      _showMessage(
        'Enter a valid height.',
      );

      return;
    }

    if (_weightController.text
        .trim()
        .isNotEmpty &&
        enteredWeight == null) {
      _showMessage(
        'Enter a valid weight.',
      );

      return;
    }

    if (height != null &&
        (height < 100 ||
            height > 250)) {
      _showMessage(
        'Enter a height between 100 and 250 cm.',
      );

      return;
    }

    if (enteredWeight != null &&
        (enteredWeight < 25 ||
            enteredWeight > 350)) {
      _showMessage(
        'Enter a valid weight.',
      );

      return;
    }

    setState(() {
      _savingProfile = true;
    });

    try {
      final updated =
      _preferences.copyWith(
        heightCm: height,
        weightKg:
        enteredWeight,
      );

      await PreferencesService.instance
          .savePreferences(
        updated,
      );

      if (!mounted) return;

      setState(() {
        _preferences = updated;
        _savingProfile = false;
      });

      widget.onPreferencesChanged(
        updated,
      );

      _showMessage(
        'Profile preferences saved.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _savingProfile = false;
      });

      _showMessage(
        'Could not save profile: $error',
      );
    }
  }

  // ==================================================
  // UNITS
  // ==================================================

  Future<void> _changeWeightUnit(
      String unit,
      ) async {
    final updated =
    _preferences.copyWith(
      weightUnit: unit,
    );

    await PreferencesService.instance
        .savePreferences(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _preferences = updated;
    });

    widget.onPreferencesChanged(
      updated,
    );
  }

  Future<void> _changeDistanceUnit(
      String unit,
      ) async {
    final updated =
    _preferences.copyWith(
      distanceUnit: unit,
    );

    await PreferencesService.instance
        .savePreferences(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _preferences = updated;
    });

    widget.onPreferencesChanged(
      updated,
    );
  }

  // ==================================================
  // MESSAGE
  // ==================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,

      body: SafeArea(
        child: RefreshIndicator(
          color:
          ShubXColors.gold,

          backgroundColor:
          ShubXColors.card,

          onRefresh:
          _loadAccount,

          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              110,
            ),

            children: [
              const Text(
                'PROFILE',
                style: TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 30,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ======================================
              // ACCOUNT
              // ======================================

              _buildAccountCard(),

              const SizedBox(
                height: 18,
              ),

              // ======================================
              // YOUR X
              // ======================================

              _SectionCard(
                title: 'YOUR X',

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children:
                      _preferences
                          .trainingTypes
                          .map(
                            (type) {
                          return _Tag(
                            label: type,
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'GOALS',
                      style: TextStyle(
                        color:
                        ShubXColors.grey,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children:
                      _preferences
                          .goals
                          .map(
                            (goal) {
                          return _Tag(
                            label: goal,
                            gold: true,
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          color:
                          ShubXColors.gold,
                          size: 17,
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        Text(
                          '${_preferences.weeklyTarget} sessions / week',
                          style:
                          const TextStyle(
                            color:
                            ShubXColors.white,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(
                      width:
                      double.infinity,

                      child:
                      OutlinedButton.icon(
                        onPressed:
                        _editX,

                        icon:
                        const Icon(
                          Icons.edit_outlined,
                        ),

                        label:
                        const Text(
                          'EDIT MY X',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ======================================
              // UNITS
              // ======================================

              _SectionCard(
                title: 'UNITS',

                child: Column(
                  children: [
                    _PreferenceRow(
                      label: 'Weight',

                      options:
                      const [
                        'kg',
                        'lb',
                      ],

                      selected:
                      _preferences
                          .weightUnit,

                      onSelected:
                      _changeWeightUnit,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _PreferenceRow(
                      label: 'Distance',

                      options:
                      const [
                        'km',
                        'mi',
                      ],

                      selected:
                      _preferences
                          .distanceUnit,

                      onSelected:
                      _changeDistanceUnit,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ======================================
              // OPTIONAL PROFILE DATA
              // ======================================

              _SectionCard(
                title:
                'OPTIONAL PROFILE DATA',

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    const Text(
                      'Height helps SHUBX estimate walking step count more personally.',
                      style: TextStyle(
                        color:
                        ShubXColors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    TextField(
                      controller:
                      _heightController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      style:
                      const TextStyle(
                        color:
                        ShubXColors.white,
                      ),

                      decoration:
                      _inputDecoration(
                        'Height',
                        'cm',
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      controller:
                      _weightController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      style:
                      const TextStyle(
                        color:
                        ShubXColors.white,
                      ),

                      decoration:
                      _inputDecoration(
                        'Weight',
                        'kg',
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(
                      width:
                      double.infinity,

                      child:
                      ElevatedButton(
                        onPressed:
                        _savingProfile
                            ? null
                            : _saveProfilePreferences,

                        child:
                        _savingProfile
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                            color:
                            ShubXColors.black,
                          ),
                        )
                            : const Text(
                          'SAVE PROFILE',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ======================================
              // ACCOUNT ACTIONS
              // ======================================

              if (_user != null)
                _SectionCard(
                  title:
                  'ACCOUNT ACTIONS',

                  child: Column(
                    children: [
                      _AccountAction(
                        icon:
                        Icons.lock_reset_outlined,

                        title:
                        'Reset Password',

                        subtitle:
                        'Send a secure password reset email.',

                        onTap:
                        _accountActionLoading
                            ? null
                            : _sendPasswordReset,
                      ),

                      const _ActionDivider(),

                      _AccountAction(
                        icon:
                        Icons.logout,

                        title:
                        'Sign Out',

                        subtitle:
                        'Sign out of this SHUBX account.',

                        destructive:
                        true,

                        onTap:
                        _accountActionLoading
                            ? null
                            : _confirmSignOut,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // ACCOUNT CARD
  // ==================================================

  Widget _buildAccountCard() {
    if (_accountLoading) {
      return const _SectionCard(
        title: 'ACCOUNT',
        child: SizedBox(
          height: 80,
          child: Center(
            child:
            CircularProgressIndicator(
              color:
              ShubXColors.gold,
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return _SectionCard(
        title: 'ACCOUNT',

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'No Firebase account is currently signed in.',
              style: TextStyle(
                color:
                ShubXColors.grey,
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              width: double.infinity,

              child:
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                      const AuthScreen(),
                    ),
                        (route) => false,
                  );
                },

                icon:
                const Icon(
                  Icons.login,
                ),

                label:
                const Text(
                  'SIGN IN',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final verified =
        _user!.emailVerified;

    return _SectionCard(
      title: 'ACCOUNT',

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,

            children: [
              Container(
                width: 54,
                height: 54,

                alignment:
                Alignment.center,

                decoration:
                BoxDecoration(
                  color:
                  ShubXColors.gold
                      .withValues(
                    alpha: 0.12,
                  ),

                  shape:
                  BoxShape.circle,

                  border:
                  Border.all(
                    color:
                    ShubXColors.gold
                        .withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),

                child: Text(
                  _initial,

                  style:
                  const TextStyle(
                    color:
                    ShubXColors.gold,

                    fontSize: 22,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      _accountName,

                      maxLines: 1,

                      overflow:
                      TextOverflow
                          .ellipsis,

                      style:
                      const TextStyle(
                        color:
                        ShubXColors.white,

                        fontSize: 17,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      _user!.email ??
                          'No email',

                      maxLines: 1,

                      overflow:
                      TextOverflow
                          .ellipsis,

                      style:
                      const TextStyle(
                        color:
                        ShubXColors.grey,

                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            width: double.infinity,

            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),

            decoration:
            BoxDecoration(
              color: verified
                  ? ShubXColors.gold
                  .withValues(
                alpha: 0.08,
              )
                  : ShubXColors
                  .charcoal,

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Row(
              children: [
                Icon(
                  verified
                      ? Icons
                      .verified_outlined
                      : Icons
                      .mark_email_unread_outlined,

                  color: verified
                      ? ShubXColors.gold
                      : ShubXColors.grey,

                  size: 19,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    verified
                        ? 'Email verified'
                        : 'Email not verified',

                    style:
                    TextStyle(
                      color: verified
                          ? ShubXColors.gold
                          : ShubXColors.grey,

                      fontSize: 11,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                if (!verified)
                  TextButton(
                    onPressed:
                    _accountActionLoading
                        ? null
                        : _sendVerificationEmail,

                    child:
                    const Text(
                      'RESEND',
                    ),
                  ),
              ],
            ),
          ),

          if (!verified) ...[
            const SizedBox(
              height: 8,
            ),

            Align(
              alignment:
              Alignment.centerRight,

              child: TextButton.icon(
                onPressed:
                _accountActionLoading
                    ? null
                    : _refreshVerification,

                icon:
                const Icon(
                  Icons.refresh,
                  size: 17,
                ),

                label:
                const Text(
                  'I VERIFIED MY EMAIL',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================================================
  // INPUT
  // ==================================================

  InputDecoration _inputDecoration(
      String label,
      String suffix,
      ) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,

      labelStyle:
      const TextStyle(
        color:
        ShubXColors.grey,
      ),

      suffixStyle:
      const TextStyle(
        color:
        ShubXColors.grey,
      ),

      filled: true,

      fillColor:
      ShubXColors.charcoal,

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        BorderSide.none,
      ),
    );
  }
}

// ====================================================
// SECTION CARD
// ====================================================

class _SectionCard
    extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(
        color:
        ShubXColors.card,

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style:
            const TextStyle(
              color:
              ShubXColors.gold,

              fontSize: 12,

              fontWeight:
              FontWeight.w700,

              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          child,
        ],
      ),
    );
  }
}

// ====================================================
// TAG
// ====================================================

class _Tag
    extends StatelessWidget {
  final String label;
  final bool gold;

  const _Tag({
    required this.label,
    this.gold = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration:
      BoxDecoration(
        color: gold
            ? ShubXColors.gold
            .withValues(
          alpha: 0.10,
        )
            : ShubXColors.charcoal,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        border: gold
            ? Border.all(
          color:
          ShubXColors.gold,
        )
            : null,
      ),

      child: Text(
        label,

        style: TextStyle(
          color: gold
              ? ShubXColors.gold
              : ShubXColors.white,

          fontSize: 11,
        ),
      ),
    );
  }
}

// ====================================================
// PREFERENCE ROW
// ====================================================

class _PreferenceRow
    extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;

  final ValueChanged<String>
  onSelected;

  const _PreferenceRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,

            style:
            const TextStyle(
              color:
              ShubXColors.white,

              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        ...options.map(
              (option) {
            final active =
                option == selected;

            return Padding(
              padding:
              const EdgeInsets.only(
                left: 8,
              ),

              child: InkWell(
                onTap: () {
                  onSelected(
                    option,
                  );
                },

                borderRadius:
                BorderRadius.circular(
                  10,
                ),

                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                  BoxDecoration(
                    color: active
                        ? ShubXColors.gold
                        : ShubXColors
                        .charcoal,

                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),

                  child: Text(
                    option
                        .toUpperCase(),

                    style:
                    TextStyle(
                      color: active
                          ? ShubXColors.black
                          : ShubXColors.grey,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ====================================================
// ACCOUNT ACTION
// ====================================================

class _AccountAction
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final VoidCallback? onTap;

  final bool destructive;

  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final color =
    destructive
        ? Colors.redAccent
        : ShubXColors.white;

    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(
        12,
      ),

      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 10,
        ),

        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,

              alignment:
              Alignment.center,

              decoration:
              BoxDecoration(
                color: destructive
                    ? Colors.redAccent
                    .withValues(
                  alpha: 0.08,
                )
                    : ShubXColors
                    .charcoal,

                borderRadius:
                BorderRadius.circular(
                  11,
                ),
              ),

              child: Icon(
                icon,
                color: color,
                size: 19,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    title,

                    style:
                    TextStyle(
                      color: color,

                      fontWeight:
                      FontWeight.w700,

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    subtitle,

                    style:
                    const TextStyle(
                      color:
                      ShubXColors.grey,

                      fontSize: 10,

                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: destructive
                  ? Colors.redAccent
                  .withValues(
                alpha: 0.7,
              )
                  : ShubXColors.grey,

              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================
// ACTION DIVIDER
// ====================================================

class _ActionDivider
    extends StatelessWidget {
  const _ActionDivider();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Divider(
      color:
      ShubXColors.darkGrey,
      height: 1,
    );
  }
}