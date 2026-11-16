import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../main/main_shell.dart';
import '../onboarding/welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
  });

  @override
  State<AuthScreen> createState() =>
      _AuthScreenState();
}

class _AuthScreenState
    extends State<AuthScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  final _confirmPasswordController =
  TextEditingController();

  bool _createAccount = false;
  bool _loading = false;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==================================================
  // ERROR MESSAGE
  // ==================================================

  String _firebaseMessage(
      FirebaseAuthException error,
      ) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Use a stronger password.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      case 'network-request-failed':
        return 'Check your internet connection.';

      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';

      default:
        return error.message ??
            'Authentication failed.';
    }
  }

  void _message(
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
  // SUBMIT
  // ==================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (_createAccount) {
        await AuthService.instance
            .createAccount(
          name:
          _nameController.text,
          email:
          _emailController.text,
          password:
          _passwordController.text,
        );
      } else {
        await AuthService.instance.signIn(
          email:
          _emailController.text,
          password:
          _passwordController.text,
        );
      }

      if (!mounted) return;

      await _continueAfterAuthentication();
    } on FirebaseAuthException catch (error) {
      _message(
        _firebaseMessage(error),
      );
    } catch (error) {
      _message(
        'Something went wrong: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ==================================================
  // CONTINUE
  // ==================================================

  Future<void>
  _continueAfterAuthentication() async {
    final UserPreferences? preferences =
    await PreferencesService.instance
        .loadPreferences();

    if (!mounted) return;

    if (preferences != null) {
      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              MainShell(
                initialPreferences:
                preferences,
              ),
        ),
            (route) => false,
      );

      return;
    }

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
        const WelcomeScreen(),
      ),
          (route) => false,
    );
  }

  // ==================================================
  // PASSWORD RESET
  // ==================================================

  Future<void>
  _forgotPassword() async {
    final email =
    _emailController.text.trim();

    if (email.isEmpty ||
        !email.contains('@')) {
      _message(
        'Enter your email address first.',
      );

      return;
    }

    try {
      await AuthService.instance
          .sendPasswordReset(
        email: email,
      );

      _message(
        'Password reset email sent.',
      );
    } on FirebaseAuthException catch (error) {
      _message(
        _firebaseMessage(error),
      );
    }
  }

  // ==================================================
  // INPUT DECORATION
  // ==================================================

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: ShubXColors.grey,
      ),

      suffixIcon: suffix,

      labelStyle: const TextStyle(
        color: ShubXColors.grey,
      ),

      filled: true,

      fillColor:
      ShubXColors.card,

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color:
          ShubXColors.darkGrey,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color:
          ShubXColors.gold,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
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
        child: Form(
          key: _formKey,

          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior
                .onDrag,

            padding:
            const EdgeInsets.fromLTRB(
              24,
              38,
              24,
              40,
            ),

            children: [
              // ======================================
              // BRAND
              // ======================================

              const Text(
                'SHUBX',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 35,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'DEFINE YOUR X.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  ShubXColors.gold,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),

              const SizedBox(
                height: 48,
              ),

              Text(
                _createAccount
                    ? 'CREATE ACCOUNT'
                    : 'WELCOME BACK',
                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 25,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                _createAccount
                    ? 'Create your account. Your X comes next.'
                    : 'Sign in to continue your training.',
                style:
                const TextStyle(
                  color:
                  ShubXColors.grey,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ======================================
              // NAME
              // ======================================

              if (_createAccount) ...[
                TextFormField(
                  controller:
                  _nameController,

                  textCapitalization:
                  TextCapitalization
                      .words,

                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                  ),

                  decoration:
                  _decoration(
                    label: 'Name',
                    icon:
                    Icons.person_outline,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .length <
                            2) {
                      return 'Enter your name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),
              ],

              // ======================================
              // EMAIL
              // ======================================

              TextFormField(
                controller:
                _emailController,

                keyboardType:
                TextInputType
                    .emailAddress,

                textInputAction:
                TextInputAction.next,

                autofillHints:
                const [
                  AutofillHints.email,
                ],

                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                ),

                decoration:
                _decoration(
                  label: 'Email',
                  icon:
                  Icons.mail_outline,
                ),

                validator: (value) {
                  final email =
                      value
                          ?.trim() ??
                          '';

                  if (email.isEmpty ||
                      !email.contains('@') ||
                      !email.contains('.')) {
                    return 'Enter a valid email.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 14,
              ),

              // ======================================
              // PASSWORD
              // ======================================

              TextFormField(
                controller:
                _passwordController,

                obscureText:
                _hidePassword,

                textInputAction:
                _createAccount
                    ? TextInputAction.next
                    : TextInputAction.done,

                autofillHints:
                _createAccount
                    ? const [
                  AutofillHints
                      .newPassword,
                ]
                    : const [
                  AutofillHints
                      .password,
                ],

                onFieldSubmitted:
                _createAccount
                    ? null
                    : (_) {
                  _submit();
                },

                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                ),

                decoration:
                _decoration(
                  label: 'Password',
                  icon:
                  Icons.lock_outline,

                  suffix:
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword =
                        !_hidePassword;
                      });
                    },

                    icon: Icon(
                      _hidePassword
                          ? Icons
                          .visibility_outlined
                          : Icons
                          .visibility_off_outlined,

                      color:
                      ShubXColors.grey,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.length < 6) {
                    return 'Use at least 6 characters.';
                  }

                  return null;
                },
              ),

              // ======================================
              // CONFIRM PASSWORD
              // ======================================

              if (_createAccount) ...[
                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                  _confirmPasswordController,

                  obscureText:
                  _hideConfirmPassword,

                  textInputAction:
                  TextInputAction.done,

                  onFieldSubmitted: (_) {
                    _submit();
                  },

                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                  ),

                  decoration:
                  _decoration(
                    label:
                    'Confirm Password',

                    icon:
                    Icons.lock_outline,

                    suffix:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword =
                          !_hideConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons
                            .visibility_outlined
                            : Icons
                            .visibility_off_outlined,

                        color:
                        ShubXColors.grey,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value !=
                        _passwordController
                            .text) {
                      return 'Passwords do not match.';
                    }

                    return null;
                  },
                ),
              ],

              // ======================================
              // FORGOT PASSWORD
              // ======================================

              if (!_createAccount) ...[
                const SizedBox(
                  height: 5,
                ),

                Align(
                  alignment:
                  Alignment.centerRight,

                  child: TextButton(
                    onPressed:
                    _loading
                        ? null
                        : _forgotPassword,

                    child:
                    const Text(
                      'Forgot password?',
                    ),
                  ),
                ),
              ],

              const SizedBox(
                height: 22,
              ),

              // ======================================
              // PRIMARY BUTTON
              // ======================================

              SizedBox(
                height: 54,

                child:
                ElevatedButton.icon(
                  onPressed:
                  _loading
                      ? null
                      : _submit,

                  icon: _loading
                      ? const SizedBox(
                    width: 19,
                    height: 19,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,

                      color:
                      ShubXColors.black,
                    ),
                  )
                      : Icon(
                    _createAccount
                        ? Icons
                        .person_add_alt_1
                        : Icons.login,
                  ),

                  label: Text(
                    _loading
                        ? 'PLEASE WAIT'
                        : _createAccount
                        ? 'CREATE ACCOUNT'
                        : 'SIGN IN',
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ======================================
              // SWITCH MODE
              // ======================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  Text(
                    _createAccount
                        ? 'Already have an account?'
                        : 'New to SHUBX?',

                    style:
                    const TextStyle(
                      color:
                      ShubXColors.grey,

                      fontSize: 12,
                    ),
                  ),

                  TextButton(
                    onPressed:
                    _loading
                        ? null
                        : () {
                      setState(() {
                        _createAccount =
                        !_createAccount;

                        _passwordController
                            .clear();

                        _confirmPasswordController
                            .clear();
                      });
                    },

                    child: Text(
                      _createAccount
                          ? 'Sign In'
                          : 'Create Account',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'Your training data remains stored locally on this device for now.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  ShubXColors.darkGrey,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}