import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/domain/models/job_posting.dart';
import 'package:path_finder/features/company/presentation/widgets/forms/post_job_form.dart';

void main() {
  group('PostJobForm Widget', () {
    testWidgets('shows validation errors when submitted with empty fields', (
      tester,
    ) async {
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

    testWidgets('successfully submits form and returns valid JobPosting', (
      tester,
    ) async {
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
        find.widgetWithText(
          TextFormField,
          'Contoh: Mobile Flutter Engineer Intern',
        ),
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
        find.widgetWithText(
          TextFormField,
          'Contoh: 1 Januari 2027 s.d. 31 Juli 2027',
        ),
        '1 Januari 2027 s.d. 31 Juli 2027',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Jelaskan tanggung jawab dan lingkup pekerjaan magang...',
        ),
        'Mengembangkan pipeline machine learning dan integrasi LLM.',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Contoh: Uang saku, laptop kerja, sertifikat magang, mentoring...',
        ),
        'Uang saku bulanan, sertifikat resmi, bimbingan 1-on-1.',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Contoh: Python, TensorFlow, PyTorch, REST API...',
        ),
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

    testWidgets(
      'shows specific validation errors for invalid input lengths and ranges',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostJobForm(onSubmitSuccess: (job) {}),
              ),
            ),
          ),
        );

        // Enter too short title
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'Contoh: Mobile Flutter Engineer Intern',
          ),
          'AB',
        );
        // Enter quota > 100
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Contoh: 3'),
          '150',
        );
        // Enter too short description
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'Jelaskan tanggung jawab dan lingkup pekerjaan magang...',
          ),
          'Terlalu pendek',
        );

        final submitButton = find.text('Publikasikan Lowongan');
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.text('Judul posisi minimal 3 karakter'), findsOneWidget);
        expect(find.text('Kuota magang maksimal 100 orang'), findsOneWidget);
        expect(
          find.text(
            'Deskripsi minimal 15 karakter agar informatif bagi pelamar',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping Gunakan Template Contoh autofills all form fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostJobForm(onSubmitSuccess: (job) {}),
            ),
          ),
        ),
      );

      final templateBtn = find.text('Gunakan Template Contoh');
      expect(templateBtn, findsOneWidget);
      await tester.tap(templateBtn);
      await tester.pumpAndSettle();

      expect(find.text('Mobile Flutter Engineer Intern'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Software Engineering'),
        findsOneWidget,
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1 Januari 2027 s.d. 31 Juli 2027'), findsOneWidget);
    });

    testWidgets(
      'kuota field enforces digitsOnly and calendar picker button is present',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostJobForm(onSubmitSuccess: (job) {}),
              ),
            ),
          ),
        );

        // Verify kuota input only accepts numbers (digitsOnly formatter)
        final kuotaField = find.widgetWithText(TextFormField, 'Contoh: 3');
        expect(kuotaField, findsOneWidget);
        await tester.enterText(kuotaField, 'abc12xyz');
        expect(find.text('12'), findsOneWidget);

        // Verify calendar button is present with correct icon
        final calendarIconBtn = find.byIcon(Icons.calendar_month_rounded);
        expect(calendarIconBtn, findsOneWidget);
        await tester.tap(calendarIconBtn);
        await tester.pumpAndSettle();

        // Verify date range picker dialog opened
        expect(find.byType(DateRangePickerDialog), findsOneWidget);
      },
    );

    testWidgets(
      'renders cleanly on narrow 320px width screens without any RenderFlex overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostJobForm(onSubmitSuccess: (job) {}),
              ),
            ),
          ),
        );

        // Expect no overflow exception was caught
        expect(tester.takeException(), isNull);
        expect(find.text('Judul Posisi'), findsOneWidget);
        expect(find.text('Tanggal Pelaksanaan'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping fasilitas suggestion chip appends text and updates selection to end',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostJobForm(onSubmitSuccess: (job) {}),
              ),
            ),
          ),
        );

        final chipFinder = find.text('+ Uang saku bulanan kompetitif');
        await tester.scrollUntilVisible(
          chipFinder,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(chipFinder, findsOneWidget);
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();

        expect(find.text('Uang saku bulanan kompetitif'), findsWidgets);

        final secondChip = find.text('+ Laptop kerja MacBook');
        await tester.tap(secondChip);
        await tester.pumpAndSettle();

        expect(
          find.text('Uang saku bulanan kompetitif, Laptop kerja MacBook'),
          findsOneWidget,
        );
      },
    );

    testWidgets('durasi seleksi field validates and chip updates value', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostJobForm(onSubmitSuccess: (job) {}),
            ),
          ),
        ),
      );

      expect(find.text('Durasi Seleksi'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, '7 Hari Kerja'),
        findsOneWidget,
      );

      // Scroll and tap 14 Hari Kerja chip
      final durasiChip = find.widgetWithText(ActionChip, '14 Hari Kerja');
      await tester.scrollUntilVisible(
        durasiChip,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(durasiChip, findsOneWidget);
      await tester.tap(durasiChip);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextFormField, '14 Hari Kerja'),
        findsOneWidget,
      );

      // Test empty validation
      final durasiField = find.widgetWithText(TextFormField, '14 Hari Kerja');
      await tester.enterText(durasiField, '');

      final submitBtn = find.text('Publikasikan Lowongan');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Durasi seleksi wajib diisi'), findsOneWidget);
    });
  });
}
