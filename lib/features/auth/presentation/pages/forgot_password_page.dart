import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  String _email = '';

  void _handleBack() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutePaths.login);
        }
        break;
      case ForgotPasswordStep.otp:
        setState(() {
          _currentStep = ForgotPasswordStep.email;
        });
        break;
      case ForgotPasswordStep.newPassword:
        setState(() {
          _currentStep = ForgotPasswordStep.otp;
        });
        break;
      case ForgotPasswordStep.completed:
        context.go(AppRoutePaths.login);
        break;
    }
  }

  String _getHeaderTitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Forgot Password';
      case ForgotPasswordStep.otp:
        return 'Verifikasi Kode';
      case ForgotPasswordStep.newPassword:
        return 'Reset Password';
      case ForgotPasswordStep.completed:
        return 'Selesai';
    }
  }

  String _getHeaderSubtitle() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return 'Masukkan email akun Anda untuk verifikasi';
      case ForgotPasswordStep.otp:
        return _email.isNotEmpty
            ? 'Masukkan 6 digit kode yang dikirim ke $_email'
            : 'Masukkan 6 digit kode yang dikirim ke email';
      case ForgotPasswordStep.newPassword:
        return 'Buat kata sandi baru untuk akun Anda';
      case ForgotPasswordStep.completed:
        return 'Password akun Anda telah berhasil diperbarui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == ForgotPasswordStep.email,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF121223),
          body: Column(
            children: [
              // Top Dark Header (#121223) with bg-asset.png
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Asset
                    Image.asset(
                      'assets/login/bg-asset.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    // Top-Left Circular Back Button (1:1 White Circle)
                    Positioned(
                      top: 12,
                      left: 24,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleBack,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18,
                                      color: Color(0xFF5E616F),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Header Content (Title & Subtitle)
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Title
                            Text(
                              _getHeaderTitle(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sen(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle
                            Text(
                              _getHeaderSubtitle(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 38),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom White Card - Extends edge-to-edge horizontally and full to bottom
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: ForgotPasswordForm(
                            currentStep: _currentStep,
                            onStepChanged: (newStep) {
                              setState(() {
                                _currentStep = newStep;
                              });
                            },
                            onEmailChanged: (email) {
                              setState(() {
                                _email = email;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
