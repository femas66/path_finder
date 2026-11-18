import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/company_profile.dart';

class EditCompanyProfileSheet extends StatefulWidget {
  const EditCompanyProfileSheet({super.key, required this.initialProfile});

  final CompanyProfile initialProfile;

  @override
  State<EditCompanyProfileSheet> createState() =>
      _EditCompanyProfileSheetState();
}

class _EditCompanyProfileSheetState extends State<EditCompanyProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sectorController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _hasSubmitted = false;

  static const List<String> _sectorSuggestions = [
    'Software House & Digital Solution',
    'Fintech & Digital Banking',
    'E-Commerce & Retail Tech',
    'Data & Cloud Services',
    'EdTech & Digital Learning',
  ];

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^[+\d\s()-]{8,20}$');

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(text: p.companyName);
    _sectorController = TextEditingController(text: p.industrySector);
    _cityController = TextEditingController(text: p.city);
    _addressController = TextEditingController(text: p.officeAddress);
    _descriptionController = TextEditingController(text: p.description);
    _websiteController = TextEditingController(text: p.website);
    _emailController = TextEditingController(text: p.contactEmail);
    _phoneController = TextEditingController(text: p.contactPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectorController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _hasSubmitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = widget.initialProfile.copyWith(
      companyName: _nameController.text.trim(),
      industrySector: _sectorController.text.trim(),
      city: _cityController.text.trim(),
      officeAddress: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      website: _websiteController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
    );

    Navigator.of(context).pop(updated);
  }

  InputDecoration _inputDecoration({required String hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA0A5BA)),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: const Color(0xFF64748B))
          : null,
      filled: true,
      fillColor: const Color(0xFFF0F5FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0F5FA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0F5FA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2373F4), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.sen(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFDC2626)),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxHeight = mediaQuery.size.height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasSubmitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Edit Profil Perusahaan',
                        style: GoogleFonts.sen(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perbarui informasi perusahaan yang tampil pada portal mitra dan halaman lowongan.',
                        style: GoogleFonts.sen(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('Nama Perusahaan'),
                        TextFormField(
                          key: const Key('company_name_field'),
                          controller: _nameController,
                          decoration: _inputDecoration(
                            hintText: 'Contoh: PT Inovasi Teknologi Nusantara',
                            icon: Icons.business_rounded,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Nama perusahaan wajib diisi';
                            }
                            if (text.length < 3) {
                              return 'Nama minimal 3 karakter';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Bidang / Sektor Industri'),
                        TextFormField(
                          key: const Key('company_sector_field'),
                          controller: _sectorController,
                          decoration: _inputDecoration(
                            hintText:
                                'Contoh: Software House & Digital Solution',
                            icon: Icons.category_outlined,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Bidang industri wajib diisi';
                            }
                            if (text.length < 3) {
                              return 'Bidang minimal 3 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _sectorSuggestions.map((item) {
                            return ActionChip(
                              label: Text(
                                item,
                                style: GoogleFonts.sen(fontSize: 11),
                              ),
                              backgroundColor: const Color(0xFFF8FAFC),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              onPressed: () {
                                setState(() => _sectorController.text = item);
                              },
                            );
                          }).toList(),
                        ),

                        _buildLabel('Kota'),
                        TextFormField(
                          key: const Key('company_city_field'),
                          controller: _cityController,
                          decoration: _inputDecoration(
                            hintText: 'Contoh: Bandung',
                            icon: Icons.location_city_rounded,
                          ),
                          validator: (val) {
                            if ((val?.trim() ?? '').isEmpty) {
                              return 'Kota wajib diisi';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Alamat Kantor'),
                        TextFormField(
                          key: const Key('company_address_field'),
                          controller: _addressController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            hintText: 'Alamat lengkap kantor perusahaan',
                            icon: Icons.place_outlined,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Alamat kantor wajib diisi';
                            }
                            if (text.length < 10) {
                              return 'Alamat minimal 10 karakter';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Deskripsi Perusahaan'),
                        TextFormField(
                          key: const Key('company_description_field'),
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            hintText: 'Jelaskan fokus bisnis dan budaya kerja perusahaan',
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Deskripsi perusahaan wajib diisi';
                            }
                            if (text.length < 15) {
                              return 'Deskripsi minimal 15 karakter';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Email Rekrutmen'),
                        TextFormField(
                          key: const Key('company_email_field'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hintText: 'rekrutmen@perusahaan.co.id',
                            icon: Icons.email_outlined,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Email rekrutmen wajib diisi';
                            }
                            if (!_emailRegex.hasMatch(text)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Nomor Telepon'),
                        TextFormField(
                          key: const Key('company_phone_field'),
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hintText: '+62 22 4201234',
                            icon: Icons.phone_outlined,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Nomor telepon wajib diisi';
                            }
                            if (!_phoneRegex.hasMatch(text)) {
                              return 'Nomor telepon minimal 8 digit';
                            }
                            return null;
                          },
                        ),

                        _buildLabel('Situs Web', required: false),
                        TextFormField(
                          key: const Key('company_website_field'),
                          controller: _websiteController,
                          keyboardType: TextInputType.url,
                          decoration: _inputDecoration(
                            hintText: 'https://perusahaan.co.id',
                            icon: Icons.language_rounded,
                          ),
                          validator: (val) {
                            final text = val?.trim() ?? '';
                            if (text.isEmpty) return null;
                            final uri = Uri.tryParse(text);
                            if (uri == null ||
                                !(uri.isScheme('http') ||
                                    uri.isScheme('https')) ||
                                uri.host.isEmpty) {
                              return 'URL harus diawali http:// atau https://';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('cancel_edit_profile_button'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.sen(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          key: const Key('save_company_profile_button'),
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2373F4),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.sen(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
