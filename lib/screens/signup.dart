import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/auth_service.dart';
import 'Welcome/input_screen.dart';
import 'login.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: SignUp()),
);

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _agree = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  String? _validatePassword(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return "Password is required";
    if (v.length < 6) return "Min 6 characters";

    // Optional “stronger” checks
    final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
    final hasLower = RegExp(r'[a-z]').hasMatch(v);
    final hasNumber = RegExp(r'\d').hasMatch(v);

    if (!hasUpper || !hasLower || !hasNumber) {
      return "Use upper, lower, and a number";
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Privacy Policy"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUpWithEmailPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (user != null && mounted) {
        // Save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameCtrl.text.trim());
        await prefs.setString('user_email', _emailCtrl.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Color(0xFF3FAE4A),
          ),
        );

        // Navigate to input screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const InputDetails()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user.displayName ?? 'User');
        await prefs.setString('user_email', user.email ?? '');

        String welcomeName = user.displayName ?? 'User';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome $welcomeName!'),
            backgroundColor: const Color(0xFF3FAE4A),
          ),
        );

        // Navigate to input screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const InputDetails()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _glassFieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.55),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('lib/images/Umuhinzi.png', fit: BoxFit.cover),
          ),

          // Dark overlay
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/images/logo.png',
                        width: 110,
                        height: 110,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "UMUHINZI+",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Create your account to start farming smarter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Glass card (preffered UI)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Sign up to continue",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Full name
                                  TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.next,
                                    decoration: _glassFieldDecoration(
                                      label: "Full name",
                                      icon: Icons.badge_outlined,
                                    ),
                                    validator: (value) {
                                      final v = (value ?? '').trim();
                                      if (v.isEmpty) return "Name is required";
                                      if (v.length < 2)
                                        return "Enter a valid name";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Email
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.next,
                                    decoration: _glassFieldDecoration(
                                      label: "Email",
                                      icon: Icons.email_outlined,
                                    ),
                                    validator: (value) {
                                      final v = (value ?? '').trim();
                                      if (v.isEmpty) return "Email is required";
                                      if (!_isValidEmail(v))
                                        return "Enter a valid email";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _hidePassword,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.next,
                                    decoration: _glassFieldDecoration(
                                      label: "Password",
                                      icon: Icons.lock_outline,
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                          () => _hidePassword = !_hidePassword,
                                        ),
                                        icon: Icon(
                                          _hidePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                  const SizedBox(height: 14),

                                  // Confirm password
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    obscureText: _hideConfirm,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.done,
                                    decoration: _glassFieldDecoration(
                                      label: "Confirm password",
                                      icon: Icons.lock_outline,
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                          () => _hideConfirm = !_hideConfirm,
                                        ),
                                        icon: Icon(
                                          _hideConfirm
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      final v = (value ?? '').trim();
                                      if (v.isEmpty)
                                        return "Confirm your password";
                                      if (v != _passCtrl.text.trim())
                                        return "Passwords do not match";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Agree terms and Privacy
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agree,
                                        onChanged: (val) => setState(
                                          () => _agree = val ?? false,
                                        ),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        checkColor: Colors.white,
                                        activeColor: const Color(0xFF2FA84F),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "I agree to the Terms & Privacy Policy",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Create Account button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2FA84F,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _handleSignUp,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              "Create Account",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Google sign up button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.35),
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        backgroundColor: Colors.white
                                            .withOpacity(0.10),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _handleGoogleSignUp,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "lib/images/google_logo.png",
                                            height: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          const Flexible(
                                            child: Text(
                                              "Sign up with Google",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Back to login
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
