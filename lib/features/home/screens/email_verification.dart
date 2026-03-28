import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/page_transitions.dart';
import '../presentation/bloc/auth/auth_cubit.dart';
import '../presentation/bloc/auth/auth_state.dart';
import '../service/auth_service.dart';
import 'Welcome/input_screen.dart';
import 'home_screen.dart';
import 'login.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthService()),
      child: _EmailVerificationView(email: email),
    );
  }
}

class _EmailVerificationView extends StatelessWidget {
  final String email;

  const _EmailVerificationView({required this.email});

  void _navigateAfterSuccess(BuildContext context, bool hasOnboarded) {
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute(page: hasOnboarded ? const Home() : const InputDetails()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateAfterSuccess(context, state.hasOnboarded);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthVerificationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent! Check your inbox.'),
              backgroundColor: Color(0xFF3FAE4A),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'lib/images/Umuhinzi.png',
                  fit: BoxFit.cover,
                ),
              ),
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
                          const SizedBox(height: 18),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.mark_email_unread,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      "Verify Your Email",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "A verification link has been sent to:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      email,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF3FAE4A),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Open your email, click the link, then come back and tap Continue.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.75),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Continue button — checks verification
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2FA84F),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                                .read<AuthCubit>()
                                                .checkVerification(),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                "I've Verified — Continue",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Resend button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.10),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                                .read<AuthCubit>()
                                                .resendVerificationEmail(),
                                        child: const Text(
                                          "Resend Verification Email",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Back to login
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          FadeRoute(
                                            page: const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: Text(
                                        "Back to Login",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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
      },
    );
  }
}
