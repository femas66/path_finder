import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/company/domain/models/company_job.dart';
import 'package:path_finder/features/company/presentation/providers/company_jobs_provider.dart';
import 'package:path_finder/features/company/presentation/widgets/forms/post_job_form.dart';

import 'candidates_tab_test.dart' show MitraAuth, NoSession;
import 'company_jobs_test_support.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeJobsRepository repo, {
    ValueChanged<CompanyJob>? created,
    bool signedIn = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            signedIn ? MitraAuth.new : NoSession.new,
          ),
          companyJobsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostJobForm(onSubmitSuccess: created ?? (_) {}),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fill(WidgetTester tester) async {
    for (final entry in {
      'title': ' Flutter Intern ',
      'location': 'Bandung',
      'description': 'Mengembangkan aplikasi mobile bersama tim.',
      'required_skills': 'Flutter, Dart',
      'optional_skills': 'Git',
      'source_url': 'https://example.com/jobs',
    }.entries) {
      await tester.enterText(find.byKey(Key(entry.key)), entry.value);
    }
    await tester.ensureVisible(find.byKey(const Key('category')));
    await tester.tap(find.byKey(const Key('category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(jobCategories[2]).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('work_type')));
    await tester.tap(find.byKey(const Key('work_type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hybrid').last);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Publikasikan Lowongan'));
    await tester.tap(find.text('Publikasikan Lowongan'));
    await tester.pump();
  }

  testWidgets('empty validation; unsupported fields absent', (tester) async {
    final repo = FakeJobsRepository();
    await mount(tester, repo);
    await submit(tester);
    expect(find.text('Isi 3–150 karakter'), findsOneWidget);
    expect(find.text('Isi 20–10000 karakter'), findsOneWidget);
    expect(find.text('Pilih kategori resmi'), findsOneWidget);
    expect(find.text('Pilih tipe kerja'), findsOneWidget);
    expect(find.textContaining('Kuota'), findsNothing);
    expect(repo.creates, isEmpty);
  });
  testWidgets(
    'pending submit disables duplicates; success uses server result and resets',
    (tester) async {
      final repo = FakeJobsRepository()
        ..pendingCreate = Completer<CompanyJob>();
      CompanyJob? created;
      await mount(tester, repo, created: (job) => created = job);
      await fill(tester);
      await submit(tester);
      await tester.pump();
      expect(find.text('Menyimpan...'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(repo.creates.single.title, 'Flutter Intern');
      expect(repo.creates.single.requiredSkills, ['Flutter', 'Dart']);
      repo.pendingCreate!.complete(jobFixture('server-id'));
      await tester.pumpAndSettle();
      expect(created!.id, 'server-id');
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('title')))
            .controller!
            .text,
        '',
      );
    },
  );
  testWidgets('failure preserves draft and supports retry', (tester) async {
    final repo = FakeJobsRepository()..fail = true;
    await mount(tester, repo);
    await fill(tester);
    await submit(tester);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('title')))
          .controller!
          .text,
      ' Flutter Intern ',
    );
    expect(repo.creates.length, 1);
    repo.fail = false;
    await submit(tester);
    await tester.pumpAndSettle();
    expect(repo.creates.length, 2);
    expect(find.text('Lowongan berhasil disimpan'), findsOneWidget);
  });
  testWidgets('creation rejects missing session', (tester) async {
    final repo = FakeJobsRepository();
    await mount(tester, repo, signedIn: false);
    await fill(tester);
    await submit(tester);
    await tester.pumpAndSettle();
    expect(repo.creates, isEmpty);
  });
  testWidgets('320px layout stays within bounds', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await mount(tester, FakeJobsRepository());
    await fill(tester);
    expect(tester.takeException(), isNull);
  });
}
