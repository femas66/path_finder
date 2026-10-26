import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/job_posting.dart';

class PostJobForm extends StatefulWidget {
  const PostJobForm({
    super.key,
    required this.onSubmitSuccess,
  });

  final ValueChanged<JobPosting> onSubmitSuccess;

  @override
  State<PostJobForm> createState() => _PostJobFormState();
}

class _PostJobFormState extends State<PostJobForm> {
  final _formKey = GlobalKey<FormState>();

  final _judulPosisiController = TextEditingController();
  final _bidangController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _tanggalPelaksanaanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _fasilitasController = TextEditingController();
  final _keahlianController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _judulPosisiController.dispose();
    _bidangController.dispose();
    _kuotaController.dispose();
    _tanggalPelaksanaanController.dispose();
    _deskripsiController.dispose();
    _fasilitasController.dispose();
    _keahlianController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final newJob = JobPosting(
        id: 'job-${DateTime.now().millisecondsSinceEpoch}',
        title: _judulPosisiController.text.trim(),
        field: _bidangController.text.trim(),
        quota: int.tryParse(_kuotaController.text.trim()) ?? 1,
        executionPeriod: _tanggalPelaksanaanController.text.trim(),
        description: _deskripsiController.text.trim(),
        facilities: _fasilitasController.text.trim(),
        requiredSkills: _keahlianController.text.trim(),
        companyName: 'PT Inovasi Teknologi Nusantara',
        location: 'Bandung (Hybrid)',
        applicantsCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      widget.onSubmitSuccess(newJob);

      _formKey.currentState!.reset();
      _judulPosisiController.clear();
      _bidangController.clear();
      _kuotaController.clear();
      _tanggalPelaksanaanController.clear();
      _deskripsiController.clear();
      _fasilitasController.clear();
      _keahlianController.clear();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lowongan "${newJob.title}" berhasil dipublikasikan!',
            style: GoogleFonts.sen(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2373F4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF32343E),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFFA0A5BA),
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF0F5FA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0F5FA), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0F5FA), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2373F4), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Judul Posisi
          _buildFieldLabel('Judul Posisi'),
          TextFormField(
            controller: _judulPosisiController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Mobile Flutter Engineer Intern',
              prefixIcon: const Icon(Icons.work_outline_rounded,
                  color: Color(0xFFA0A5BA), size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul posisi wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 2. Bidang
          _buildFieldLabel('Bidang'),
          TextFormField(
            controller: _bidangController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Software Engineering / IT',
              prefixIcon: const Icon(Icons.category_outlined,
                  color: Color(0xFFA0A5BA), size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bidang pekerjaan wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 3. Kuota Anak Magang
          _buildFieldLabel('Kuota Anak Magang'),
          TextFormField(
            controller: _kuotaController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: 3',
              prefixIcon: const Icon(Icons.group_outlined,
                  color: Color(0xFFA0A5BA), size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Masukkan kuota magang yang valid';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Masukkan kuota magang yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 4. Tanggal Pelaksanaan
          _buildFieldLabel('Tanggal Pelaksanaan'),
          TextFormField(
            controller: _tanggalPelaksanaanController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: 1 Januari 2027 s.d. 31 Juli 2027',
              prefixIcon: const Icon(Icons.date_range_outlined,
                  color: Color(0xFFA0A5BA), size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Tanggal pelaksanaan wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 5. Deskripsi
          _buildFieldLabel('Deskripsi'),
          TextFormField(
            controller: _deskripsiController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Jelaskan tanggung jawab dan lingkup pekerjaan magang...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Deskripsi wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 6. Fasilitas Apa Saja
          _buildFieldLabel('Fasilitas Apa Saja'),
          TextFormField(
            controller: _fasilitasController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText:
                  'Contoh: Uang saku, laptop kerja, sertifikat magang, mentoring...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Fasilitas wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 7. Keahlian yang Dibutuhkan
          _buildFieldLabel('Keahlian yang Dibutuhkan'),
          TextFormField(
            controller: _keahlianController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Python, TensorFlow, PyTorch, REST API...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Keahlian wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Tombol Submit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF2373F4).withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Publikasikan Lowongan',
                          style: GoogleFonts.sen(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
