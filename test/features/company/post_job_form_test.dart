import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/domain/models/job_posting.dart';
import 'package:path_finder/features/company/presentation/widgets/forms/post_job_form.dart';

void main() {
  group('PostJobForm Widget', () {
    testWidgets('shows validation errors when submitted with empty fields', (tester) async {
      JobPosting? createdJob;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostJobForm(
                onSubmitSuccess: (job) {
                  createdJob = job;
                },
              ),
            ),
          ),
        ),
      );

      // Verify labels exist
      expect(find.text('Judul Posisi'), findsOneWidget);
      expect(find.text('Bidang'), findsOneWidget);
      expect(find.text('Kuota Anak Magang'), findsOneWidget);
      expect(find.text('Tanggal Pelaksanaan'), findsOneWidget);
      expect(find.text('Deskripsi'), findsOneWidget);
      expect(find.text('Fasilitas Apa Saja'), findsOneWidget);
      expect(find.text('Keahlian yang Dibutuhkan'), findsOneWidget);

      // Tap submit button without filling fields
      final submitButton = find.text('Publikasikan Lowongan');
      expect(submitButton, findsOneWidget);

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Expect validation error messages
      expect(find.text('Judul posisi wajib diisi'), findsOneWidget);
      expect(find.text('Bidang pekerjaan wajib diisi'), findsOneWidget);
      expect(find.text('Masukkan kuota magang yang valid'), findsOneWidget);
      expect(find.text('Tanggal pelaksanaan wajib diisi'), findsOneWidget);
      expect(find.text('Deskripsi wajib diisi'), findsOneWidget);
      expect(find.text('Fasilitas wajib diisi'), findsOneWidget);
      expect(find.text('Keahlian wajib diisi'), findsOneWidget);

      expect(createdJob, isNull);
    });

    testWidgets('successfully submits form and returns valid JobPosting', (tester) async {
      JobPosting? createdJob;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostJobForm(
                onSubmitSuccess: (job) {
                  createdJob = job;
                },
              ),
            ),
          ),
        ),
      );

      // Fill in all 7 fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: Mobile Flutter Engineer Intern'),
        'AI Engineer Intern',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: Software Engineering / IT'),
        'Artificial Intelligence',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: 3'),
        '4',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: 1 Januari 2027 s.d. 31 Juli 2027'),
        '1 Januari 2027 s.d. 31 Juli 2027',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jelaskan tanggung jawab dan lingkup pekerjaan magang...'),
        'Mengembangkan pipeline machine learning dan integrasi LLM.',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: Uang saku, laptop kerja, sertifikat magang, mentoring...'),
        'Uang saku bulanan, sertifikat resmi, bimbingan 1-on-1.',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contoh: Python, TensorFlow, PyTorch, REST API...'),
        'Python, PyTorch, HuggingFace, FastAPI',
      );

      final submitButton = find.text('Publikasikan Lowongan');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);

      // Wait for delayed simulated submission (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(createdJob, isNotNull);
      expect(createdJob!.title, 'AI Engineer Intern');
      expect(createdJob!.field, 'Artificial Intelligence');
      expect(createdJob!.quota, 4);
      expect(createdJob!.executionPeriod, '1 Januari 2027 s.d. 31 Juli 2027');
      expect(createdJob!.description, contains('machine learning'));
      expect(createdJob!.facilities, contains('Uang saku bulanan'));
      expect(createdJob!.requiredSkills, contains('Python, PyTorch'));
      expect(createdJob!.isActive, isTrue);
    });
  });
}
