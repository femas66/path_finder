import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/error_mapper.dart';
import '../providers/auth_controller.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key, this.onRegisterSuccess});

  /// Dipanggil setelah pendaftaran berhasil dan sesi terbentuk.
  final VoidCallback? onRegisterSuccess;

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmationVisible = false;
  bool _isLoading = false;

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final session = await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          );

      if (!mounted) return;

      if (session == null) {
        // Backend belum mengirim token: minta pengguna login manual.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF2373F4),
            content: Text('Pendaftaran berhasil. Silakan masuk ke akunmu.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppRoutePaths.login);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Pendaftaran berhasil'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.onRegisterSuccess != null) {
        widget.onRegisterSuccess!();
      } else {
        // Langsung lanjut mengisi cerita diri setelah register.
        context.go(AppRoutePaths.story);
      }
    } catch (error, stackTrace) {
      if (!mounted) return;

      // Selalu tampilkan pesan dari ErrorMapper agar penyebab asli terlihat.
      debugPrint('RegisterForm error: $error\n$stackTrace');
      final message = ErrorMapper.fromObject(error, stackTrace).message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _decoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFFA0A5BA),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF0F5FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(const Color(0xFFF0F5FA)),
      enabledBorder: border(const Color(0xFFF0F5FA)),
      focusedBorder: border(const Color(0xFF2373F4), 1.5),
      errorBorder: border(const Color(0xFFDC2626)),
      focusedErrorBorder: border(const Color(0xFFDC2626), 1.5),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.sen(
          fontSize: 13,
          color: const Color(0xFF32343E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _label('Nama Lengkap'),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _decoration(hintText: 'Budi Santoso'),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Nama lengkap tidak boleh kosong';
              if (text.length < 3) return 'Nama minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 18),

          _label('Email'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _decoration(hintText: 'budi.santoso@example.com'),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Email tidak boleh kosong';
              if (!_emailPattern.hasMatch(text)) {
                return 'Masukkan alamat email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          _label('Password'),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _decoration(
              hintText: 'Minimal 8 karakter',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  size: 20,
                  color: const Color(0xFFB4B9CA),
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            validator: (value) {
              final text = value ?? '';
              if (text.isEmpty) return 'Kata sandi tidak boleh kosong';
              if (text.length < 8) return 'Kata sandi minimal 8 karakter';
              return null;
            },
          ),
          const SizedBox(height: 18),

          _label('Konfirmasi Password'),
          TextFormField(
            controller: _passwordConfirmationController,
            obscureText: !_isConfirmationVisible,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _decoration(
              hintText: 'Ulangi kata sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmationVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  size: 20,
                  color: const Color(0xFFB4B9CA),
                ),
                onPressed: () {
                  setState(
                    () => _isConfirmationVisible = !_isConfirmationVisible,
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi kata sandi tidak boleh kosong';
              }
              if (value != _passwordController.text) {
                return 'Konfirmasi kata sandi tidak cocok';
              }
              return null;
            },
            onFieldSubmitted: (_) => _isLoading ? null : _submit(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
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
                      'DAFTAR',
                      style: GoogleFonts.sen(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Sudah punya akun? ',
                  style: GoogleFonts.sen(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF646982),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutePaths.login),
                  child: Text(
                    'MASUK',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2373F4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
