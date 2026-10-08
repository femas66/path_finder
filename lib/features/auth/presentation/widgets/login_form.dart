import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate authentication processing with immediate clean feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        context.go(AppRoutePaths.story);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label: Username / Email
          Text(
            'Email',
            style: GoogleFonts.sen(
              fontSize: 13,
              color: Color(0xFF32343E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          // Input: Username / Email
          TextFormField(
            controller: _usernameOrEmailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: InputDecoration(
              hintText: 'testing@gmail.com',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A5BA), // Slate 400
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
                return 'Username atau email tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Row: Password Label & Forgot Password Link

          Text(
            'Password',
            style: GoogleFonts.sen(
              fontSize: 13,
              color: Color(0xFF32343E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          // Input: Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'juragansengon88',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A5BA), // Slate 400
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  size: 20,
                  color: const Color(0xFFB4B9CA),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
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
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          // Row: Remember Me & Lupa Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2373F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE3EBF2),
                        width: 1.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    child: Text(
                      'Remember Me',
                      style: GoogleFonts.sen(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7E8A97),
                      ),
                    ),
                  ),
                ],
              ),
              // Lupa Password
              GestureDetector(
                onTap: () {
                  context.push(AppRoutePaths.forgotPassword);
                },
                child: Text(
                  'Lupa password?',
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2373F4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Button: Masuk
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
                      'Masuk'.toUpperCase(),
                      style: GoogleFonts.sen(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Link: Daftar Akun Baru
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Belum punya akun? ',
                  style: GoogleFonts.sen(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF646982),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutePaths.register);
                  },
                  child: Text(
                    'sign up'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2373F4),
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
