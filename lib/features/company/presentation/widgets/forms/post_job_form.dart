import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/job_posting.dart';

class PostJobForm extends StatefulWidget {
  const PostJobForm({super.key, required this.onSubmitSuccess});

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
  final _lokasiController = TextEditingController(text: 'Bandung (Hybrid)');
  final _durasiSeleksiController = TextEditingController(text: '7 Hari Kerja');

  final _fasilitasScrollController = ScrollController();
  final _keahlianScrollController = ScrollController();

  bool _isLoading = false;
  bool _hasSubmitted = false;

  static const List<String> _bidangSuggestions = [
    'Software Engineering',
    'Web Engineering',
    'Mobile Development',
    'Data & AI',
    'UI/UX Design',
    'Network & IT Support',
    'Cyber Security',
  ];

  static const List<String> _durasiSuggestions = [
    '3 Hari Kerja',
    '7 Hari Kerja',
    '14 Hari Kerja',
    '30 Hari',
  ];

  static const List<String> _fasilitasSuggestions = [
    'Uang saku bulanan kompetitif',
    'Laptop kerja MacBook',
    'Sertifikat magang resmi industri',
    'Bimbingan mentor 1-on-1',
    'Makan siang gratis & snack',
    'Akses kursus teknologi berbayar',
  ];

  static const List<String> _keahlianSuggestions = [
    'Flutter',
    'Dart',
    'React',
    'TypeScript',
    'Golang',
    'Python',
    'PostgreSQL',
    'Docker',
    'Git',
    'REST API',
    'Figma',
  ];

  @override
  void dispose() {
    _judulPosisiController.dispose();
    _bidangController.dispose();
    _kuotaController.dispose();
    _tanggalPelaksanaanController.dispose();
    _deskripsiController.dispose();
    _fasilitasController.dispose();
    _keahlianController.dispose();
    _lokasiController.dispose();
    _durasiSeleksiController.dispose();
    _fasilitasScrollController.dispose();
    _keahlianScrollController.dispose();
    super.dispose();
  }

  void _fillTemplate() {
    setState(() {
      _judulPosisiController.text = 'Mobile Flutter Engineer Intern';
      _bidangController.text = 'Software Engineering';
      _kuotaController.text = '3';
      _tanggalPelaksanaanController.text = '1 Januari 2027 s.d. 31 Juli 2027';
      _deskripsiController.text = 'Mengembangkan fitur aplikasi mobile PathFinder, mengimplementasikan Clean Architecture, dan integrasi API RESTful.';
      _fasilitasController.text = 'Uang saku bulanan kompetitif, laptop kerja MacBook, sertifikat magang resmi, bimbingan mentor 1-on-1.';
      _keahlianController.text =
          'Flutter, Dart, State Management (Riverpod), Git, REST API';
      _lokasiController.text = 'Bandung (Hybrid)';
      _durasiSeleksiController.text = '7 Hari Kerja';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Formulir terisi dengan template contoh lowongan magang!',
          style: GoogleFonts.sen(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2373F4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _judulPosisiController.clear();
    _bidangController.clear();
    _kuotaController.clear();
    _tanggalPelaksanaanController.clear();
    _deskripsiController.clear();
    _fasilitasController.clear();
    _keahlianController.clear();
    _lokasiController.text = 'Bandung (Hybrid)';
    _durasiSeleksiController.text = '7 Hari Kerja';
    setState(() {
      _hasSubmitted = false;
    });
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: DateTime(now.year + 1, 1, 1),
      end: DateTime(now.year + 1, 6, 30),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2373F4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = picked.start;
      final end = picked.end;
      setState(() {
        _tanggalPelaksanaanController.text =
            '${start.day} ${_monthName(start.month)} ${start.year} s.d. ${end.day} ${_monthName(end.month)} ${end.year}';
      });
    }
  }

  void _addSuggestionToField(
    TextEditingController controller,
    String textToAdd, {
    bool isCommaSeparated = false,
    ScrollController? scrollController,
  }) {
    final currentText = controller.text.trim();
    String newText;
    if (currentText.isEmpty) {
      newText = textToAdd;
    } else {
      if (isCommaSeparated) {
        if (!currentText.contains(textToAdd)) {
          newText = '$currentText, $textToAdd';
        } else {
          newText = currentText;
        }
      } else {
        newText = textToAdd;
      }
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController != null && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submit() {
    setState(() {
      _hasSubmitted = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mohon periksa kembali kolom formulir yang belum valid.',
            style: GoogleFonts.sen(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
        location: _lokasiController.text.trim().isEmpty
            ? 'Bandung (Hybrid)'
            : _lokasiController.text.trim(),
        selectionDuration: _durasiSeleksiController.text.trim().isEmpty
            ? '7 Hari Kerja'
            : _durasiSeleksiController.text.trim(),
        applicantsCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      widget.onSubmitSuccess(newJob);

      _resetForm();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lowongan "${newJob.title}" berhasil dipublikasikan!',
            style: GoogleFonts.sen(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  Widget _buildFieldLabel(
    String label, {
    bool isRequired = true,
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.sen(
                      fontSize: 13,
                      color: const Color(0xFF32343E),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          ),
          if (helper != null) ...[
            const SizedBox(width: 8),
            Text(
              helper,
              textAlign: TextAlign.end,
              style: GoogleFonts.sen(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA0A5BA)),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF0F5FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      autovalidateMode: _hasSubmitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Cepat: Template Contoh & Reset
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _fillTemplate,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: Text(
                      'Gunakan Template Contoh',
                      style: GoogleFonts.sen(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2373F4),
                      side: const BorderSide(color: Color(0xFF2373F4)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  tooltip: 'Reset Formulir',
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 1. Judul Posisi
          _buildFieldLabel('Judul Posisi', helper: 'Min. 3 karakter'),
          TextFormField(
            controller: _judulPosisiController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Mobile Flutter Engineer Intern',
              prefixIcon: const Icon(
                Icons.work_outline_rounded,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul posisi wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Judul posisi minimal 3 karakter';
              }
              if (value.trim().length > 100) {
                return 'Judul posisi maksimal 100 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 2. Bidang
          _buildFieldLabel('Bidang', helper: 'Pilih / ketik'),
          TextFormField(
            controller: _bidangController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Software Engineering / IT',
              prefixIcon: const Icon(
                Icons.category_outlined,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bidang pekerjaan wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Bidang pekerjaan minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _bidangSuggestions.map((bidang) {
                final isSelected = _bidangController.text == bidang;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      bidang,
                      style: GoogleFonts.sen(
                        fontSize: 10.5,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? const Color(0xFF2373F4)
                        : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2373F4)
                          : const Color(0xFFE2E8F0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    onPressed: () {
                      _addSuggestionToField(_bidangController, bidang);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Kuota Anak Magang
          _buildFieldLabel('Kuota Anak Magang', helper: '1 s.d. 100 orang'),
          TextFormField(
            controller: _kuotaController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: 3',
              prefixIcon: const Icon(
                Icons.group_outlined,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Masukkan kuota magang yang valid';
              }
              final parsed = int.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Masukkan kuota magang yang valid';
              }
              if (parsed > 100) {
                return 'Kuota magang maksimal 100 orang';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 4. Tanggal Pelaksanaan
          _buildFieldLabel('Tanggal Pelaksanaan', helper: 'Pilih kalender'),
          TextFormField(
            controller: _tanggalPelaksanaanController,
            onTap: _pickDateRange,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: 1 Januari 2027 s.d. 31 Juli 2027',
              prefixIcon: const Icon(
                Icons.date_range_outlined,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF2373F4),
                  size: 22,
                ),
                tooltip: 'Buka Kalender Rentang Tanggal',
                onPressed: _pickDateRange,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Tanggal pelaksanaan wajib diisi';
              }
              if (value.trim().length < 5) {
                return 'Tanggal pelaksanaan minimal 5 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 5. Durasi Seleksi
          _buildFieldLabel('Durasi Seleksi', helper: 'Timeline seleksi'),
          TextFormField(
            controller: _durasiSeleksiController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: 7 Hari Kerja / 14 Hari',
              prefixIcon: const Icon(
                Icons.hourglass_bottom_rounded,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Durasi seleksi wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Durasi seleksi minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _durasiSuggestions.map((durasi) {
                final isSelected = _durasiSeleksiController.text == durasi;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      durasi,
                      style: GoogleFonts.sen(
                        fontSize: 10.5,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? const Color(0xFF2373F4)
                        : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2373F4)
                          : const Color(0xFFE2E8F0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    onPressed: () {
                      _addSuggestionToField(_durasiSeleksiController, durasi);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 5. Lokasi & Tipe Magang (Opsional / Tambahan)
          _buildFieldLabel('Lokasi & Tipe Kerja', isRequired: false),
          TextFormField(
            controller: _lokasiController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Bandung (Hybrid) / Jakarta (Onsite)',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFA0A5BA),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 6. Deskripsi
          _buildFieldLabel('Deskripsi', helper: 'Min. 15 karakter'),
          TextFormField(
            controller: _deskripsiController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText:
                  'Jelaskan tanggung jawab dan lingkup pekerjaan magang...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Deskripsi wajib diisi';
              }
              if (value.trim().length < 15) {
                return 'Deskripsi minimal 15 karakter agar informatif bagi pelamar';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 7. Fasilitas Apa Saja
          _buildFieldLabel('Fasilitas Apa Saja', helper: 'Min. 5 karakter'),
          TextFormField(
            controller: _fasilitasController,
            scrollController: _fasilitasScrollController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Uang saku, laptop kerja, sertifikat magang, mentoring...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Fasilitas wajib diisi';
              }
              if (value.trim().length < 5) {
                return 'Fasilitas magang minimal 5 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _fasilitasSuggestions.map((fasilitas) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      '+ $fasilitas',
                      style: GoogleFonts.sen(
                        fontSize: 10.5,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    onPressed: () {
                      _addSuggestionToField(
                        _fasilitasController,
                        fasilitas,
                        isCommaSeparated: true,
                        scrollController: _fasilitasScrollController,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 8. Keahlian yang Dibutuhkan
          _buildFieldLabel(
            'Keahlian yang Dibutuhkan',
            helper: 'Pisahkan dengan koma',
          ),
          TextFormField(
            controller: _keahlianController,
            scrollController: _keahlianScrollController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF32343E)),
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Python, TensorFlow, PyTorch, REST API...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Keahlian wajib diisi';
              }
              if (value.trim().length < 2) {
                return 'Keahlian wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _keahlianSuggestions.map((skill) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(
                      '+ $skill',
                      style: GoogleFonts.sen(
                        fontSize: 10.5,
                        color: const Color(0xFF2373F4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFF2373F4)
                        .withValues(alpha: 0.08),
                    side: BorderSide(
                      color: const Color(0xFF2373F4).withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    onPressed: () {
                      _addSuggestionToField(
                        _keahlianController,
                        skill,
                        isCommaSeparated: true,
                        scrollController: _keahlianScrollController,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
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
                disabledBackgroundColor: const Color(0xFF2373F4)
                    .withValues(alpha: 0.6),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Publikasikan Lowongan',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sen(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
