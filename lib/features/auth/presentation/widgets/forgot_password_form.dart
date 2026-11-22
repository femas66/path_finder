import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/error_mapper.dart';
import '../providers/auth_controller.dart';

enum ForgotPasswordStep {
  email,
  otp,
  newPassword,
  completed,
}

class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
    required this.onEmailChanged,
  });

  final ForgotPasswordStep currentStep;
  final ValueChanged<ForgotPasswordStep> onStepChanged;
  final ValueChanged<String> onEmailChanged;

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  String _verifiedCode = '';

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldownTimer(int seconds) {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSeconds = seconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  Future<void> _submitEmail() async {
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    if (_cooldownSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap tunggu $_cooldownSeconds detik sebelum meminta kode baru.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    widget.onEmailChanged(email);

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(email);

      if (!mounted) return;
      _startCooldownTimer(60);
      widget.onStepChanged(ForgotPasswordStep.otp);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          content: Text(
            'Kode verifikasi 6-digit telah dikirim ke $email',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      final appException = ErrorMapper.fromObject(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(appException.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_cooldownSeconds > 0 || _isLoading) return;

    final email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(email);

      if (!mounted) return;
      _startCooldownTimer(60);

      // Bersihkan input OTP sebelumnya
      for (final c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Kode verifikasi baru telah dikirimkan ke email Anda.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      final appException = ErrorMapper.fromObject(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(appException.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Silakan masukkan lengkap 6 digit kode verifikasi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await ref
          .read(authControllerProvider.notifier)
          .verifyResetCode(email: email, code: code);

      if (!mounted) return;
      if (isValid) {
        _verifiedCode = code;
        widget.onStepChanged(ForgotPasswordStep.newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('Kode verifikasi valid. Silakan atur password baru.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      final appException = ErrorMapper.fromObject(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(appException.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitNewPassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: email,
            code: _verifiedCode,
            password: newPassword,
            confirmPassword: confirmPassword,
          );

      if (!mounted) return;
      widget.onStepChanged(ForgotPasswordStep.completed);
    } catch (e, stackTrace) {
      if (!mounted) return;
      final appException = ErrorMapper.fromObject(e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(appException.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.currentStep) {
      case ForgotPasswordStep.email:
        return _buildEmailStep();
      case ForgotPasswordStep.otp:
        return _buildOtpStep();
      case ForgotPasswordStep.newPassword:
        return _buildNewPasswordStep();
      case ForgotPasswordStep.completed:
        return _buildCompletedStep();
    }
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EMAIL',
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF32343E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: InputDecoration(
              hintText: 'testing@gmail.com',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A5BA),
              ),
              filled: true,
              fillColor: const Color(0xFFF0F5FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2373F4),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email tidak boleh kosong';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Format email tidak valid (contoh: user@gmail.com)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Kami akan mengirimkan 6 digit kode verifikasi OTP ke alamat email terdaftar Anda.',
            style: GoogleFonts.sen(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _cooldownSeconds > 0
                          ? 'TUNGGU ${_cooldownSeconds}S'
                          : 'KIRIM KODE OTP',
                      style: GoogleFonts.sen(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingat kata sandi akun Anda? ',
                style: GoogleFonts.sen(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go(AppRoutePaths.login);
                },
                child: Text(
                  'Masuk',
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2373F4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Target Email Banner with edit action
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 20,
                color: Color(0xFF2373F4),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  email,
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        widget.onStepChanged(ForgotPasswordStep.email);
                      },
                child: Text(
                  'Ubah',
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2373F4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'KODE VERIFIKASI (6 DIGIT)',
          style: GoogleFonts.sen(
            fontSize: 13,
            color: const Color(0xFF32343E),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        // 6 Digit OTP Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: index == 0 || index == 5 ? 0 : 3,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 46,
                  minHeight: 48,
                  maxHeight: 52,
                ),
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.sen(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF0F5FA),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFF0F5FA),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFF0F5FA),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF2373F4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    } else {
                      if (index > 0) {
                        _otpFocusNodes[index - 1].requestFocus();
                      }
                    }
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Resend Timer Row
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Tidak menerima kode? ',
              style: GoogleFonts.sen(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            GestureDetector(
              onTap: (_cooldownSeconds == 0 && !_isLoading) ? _resendCode : null,
              child: Text(
                _cooldownSeconds > 0
                    ? 'Kirim ulang (${_cooldownSeconds}s)'
                    : 'Kirim Ulang',
                style: GoogleFonts.sen(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _cooldownSeconds > 0
                      ? const Color(0xFFA0A5BA)
                      : const Color(0xFF2373F4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2373F4),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'VERIFIKASI KODE',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PASSWORD BARU',
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF32343E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Minimal 6 karakter',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A5BA),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  size: 20,
                  color: const Color(0xFFB4B9CA),
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF0F5FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2373F4),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password baru tidak boleh kosong';
              }
              if (value.trim().length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          Text(
            'KONFIRMASI PASSWORD BARU',
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF32343E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Ulangi password baru',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A5BA),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  size: 20,
                  color: const Color(0xFFB4B9CA),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF0F5FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF0F5FA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2373F4),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              if (value != _newPasswordController.text) {
                return 'Konfirmasi password tidak cocok dengan password baru';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitNewPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'SIMPAN PASSWORD',
                      style: GoogleFonts.sen(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Password Berhasil Diubah!',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kata sandi untuk akun ${_emailController.text} telah berhasil diperbarui. Silakan masuk kembali dengan password baru Anda.',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 13,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.go(AppRoutePaths.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2373F4),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'MASUK SEKARANG',
              style: GoogleFonts.sen(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
