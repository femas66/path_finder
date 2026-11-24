import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/errors/error_mapper.dart';
import '../../../domain/models/company_job.dart';
import '../../providers/company_jobs_provider.dart';

class PostJobForm extends ConsumerStatefulWidget {
  const PostJobForm({super.key, required this.onSubmitSuccess});
  final ValueChanged<CompanyJob> onSubmitSuccess;
  @override
  ConsumerState<PostJobForm> createState() => _PostJobFormState();
}

class _PostJobFormState extends ConsumerState<PostJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _fields = {
    for (final name in [
      'title',
      'description',
      'location',
      'required_skills',
      'optional_skills',
      'source_url',
    ])
      name: TextEditingController(),
  };
  String? _category;
  String? _workType;
  List<String> _skills(String name) => _fields[name]!.text.trim().isEmpty
      ? []
      : _fields[name]!.text.split(',').map((s) => s.trim()).toList();

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final job = await ref
        .read(createJobProvider.notifier)
        .submit(
          CreateCompanyJob(
            title: _fields['title']!.text,
            category: _category!,
            description: _fields['description']!.text,
            location: _fields['location']!.text,
            workType: _workType!,
            requiredSkills: _skills('required_skills'),
            optionalSkills: _skills('optional_skills'),
            sourceUrl: _fields['source_url']!.text,
          ),
        );
    if (!mounted || job == null) return;
    for (final field in _fields.values) {
      field.clear();
    }
    _formKey.currentState!.reset();
    setState(() {
      _category = null;
      _workType = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lowongan berhasil disimpan')));
    widget.onSubmitSuccess(job);
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(createJobProvider);
    final busy = submission.isLoading;
    Widget field(
      String name,
      String label,
      String? Function(String?) validator, {
      int lines = 1,
      String? helper,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        key: Key(name),
        controller: _fields[name],
        enabled: !busy,
        minLines: lines,
        maxLines: lines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field(
            'title',
            'Judul Posisi',
            (v) => CreateCompanyJob.textError(v ?? '', 3, 150),
          ),
          DropdownButtonFormField<String>(
            key: const Key('category'),
            initialValue: _category,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: jobCategories
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: busy ? null : (v) => setState(() => _category = v),
            validator: (v) => v == null ? 'Pilih kategori resmi' : null,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            key: const Key('work_type'),
            initialValue: _workType,
            decoration: const InputDecoration(
              labelText: 'Tipe Kerja',
              border: OutlineInputBorder(),
            ),
            items: [
              'Remote',
              'Onsite',
              'Hybrid',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: busy ? null : (v) => setState(() => _workType = v),
            validator: (v) => v == null ? 'Pilih tipe kerja' : null,
          ),
          const SizedBox(height: 18),
          field(
            'location',
            'Lokasi',
            (v) => CreateCompanyJob.textError(v ?? '', 1, 255),
          ),
          field(
            'description',
            'Deskripsi',
            (v) => CreateCompanyJob.textError(v ?? '', 20, 10000),
            lines: 5,
          ),
          field(
            'required_skills',
            'Keahlian yang Dibutuhkan',
            (_) => CreateCompanyJob.skillsError(
              _skills('required_skills'),
              required: true,
            ),
            helper: 'Pisahkan dengan koma. Contoh: Flutter, Dart, REST API',
          ),
          field(
            'optional_skills',
            'Keahlian Tambahan (opsional)',
            (_) => CreateCompanyJob.skillsError(
              _skills('optional_skills'),
              required: false,
            ),
            helper: 'Pisahkan dengan koma.',
          ),
          field(
            'source_url',
            'URL Lowongan (opsional)',
            (v) => CreateCompanyJob.urlError(v ?? ''),
          ),
          if (submission.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                ErrorMapper.fromObject(submission.error!).message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(busy ? 'Menyimpan...' : 'Publikasikan Lowongan'),
          ),
        ],
      ),
    );
  }
}
