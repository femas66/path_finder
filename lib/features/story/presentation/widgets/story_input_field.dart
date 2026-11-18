import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Textarea cerita diri dengan penghitung karakter dan validasi panjang.
class StoryInputField extends StatelessWidget {
  const StoryInputField({
    super.key,
    required this.controller,
    this.minLength = minStoryLength,
    this.maxLength = maxStoryLength,
    this.enabled = true,
    this.onChanged,
  });

  static const int minStoryLength = 50;
  static const int maxStoryLength = 2000;

  final TextEditingController controller;
  final int minLength;
  final int maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  /// Validasi isi cerita. Dipakai juga oleh test agar aturan tidak terduplikasi.
  static String? validate(
    String? value, {
    int minLength = minStoryLength,
    int maxLength = maxStoryLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Cerita tidak boleh kosong';
    }
    if (text.length < minLength) {
      final remaining = minLength - text.length;
      return 'Tulis minimal $minLength karakter (kurang $remaining karakter)';
    }
    if (text.length > maxLength) {
      return 'Cerita maksimal $maxLength karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          enabled: enabled,
          minLines: 8,
          maxLines: 14,
          maxLength: maxLength,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
          ],
          onChanged: onChanged,
          validator: (value) => validate(
            value,
            minLength: minLength,
            maxLength: maxLength,
          ),
          style: GoogleFonts.sen(
            fontSize: 14,
            height: 1.6,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText:
                'Contoh: Saya suka mengotak-atik tampilan aplikasi dan sering '
                'membuat prototipe di Figma. Saat menemui masalah, saya '
                'memecahnya menjadi langkah kecil lalu mencoba satu per satu...',
            hintStyle: GoogleFonts.sen(
              fontSize: 13.5,
              height: 1.5,
              color: const Color(0xFFA0A5BA),
            ),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.all(16),
            border: _border(const Color(0xFFE2E8F0)),
            enabledBorder: _border(const Color(0xFFE2E8F0)),
            focusedBorder: _border(const Color(0xFF2373F4), 1.5),
            errorBorder: _border(const Color(0xFFDC2626)),
            focusedErrorBorder: _border(const Color(0xFFDC2626), 1.5),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final length = value.text.trim().length;
            final isTooShort = length < minLength;
            final isNearLimit = length >= (maxLength * 0.95).round();

            final Color counterColor;
            if (isNearLimit) {
              counterColor = const Color(0xFFD97706);
            } else if (length == 0) {
              counterColor = const Color(0xFF94A3B8);
            } else if (isTooShort) {
              counterColor = const Color(0xFF64748B);
            } else {
              counterColor = const Color(0xFF059669);
            }

            return Row(
              children: [
                Icon(
                  isTooShort
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 14,
                  color: counterColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isTooShort
                        ? 'Minimal $minLength karakter · kurang '
                            '${minLength - length} lagi'
                        : 'Ceritamu sudah cukup panjang untuk dianalisis',
                    style: GoogleFonts.sen(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: counterColor,
                    ),
                  ),
                ),
                Text(
                  '$length/$maxLength',
                  style: GoogleFonts.sen(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: counterColor,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
