import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:path_finder/features/company/data/company_mock_data.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/company/data/applicants_repository.dart';
import 'package:path_finder/features/company/presentation/providers/applicants_provider.dart';
import 'package:path_finder/features/company/presentation/widgets/tabs/candidates_tab.dart';
import 'package:path_finder/features/company/presentation/widgets/cards/candidate_card.dart';

class MitraAuth extends AuthController {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    token: 'test',
    user: AuthUser(
      id: '1',
      name: 'Mitra',
      email: 'test@example.com',
      role: 'mitra',
    ),
  );
}

class FakeRepository extends ApplicantsRepository {
  FakeRepository() : super(Dio());
  final calls = <String?>[];
  bool fail = false;
  bool populated = false;
  final decisions = <String>[];
  @override
  Future<void> decide(String id, String status) async {
    decisions.add(status);
    if (fail) {
      throw StateError('offline');
    }
  }

  @override
  Future<Map<String, String>> jobs() async => {'job-1': 'Engineer'};
  @override
  Future<ApplicantsPage> list({
    String? jobId,
    int page = 1,
    int size = 10,
  }) async {
    calls.add(jobId);
    if (fail) throw StateError('offline');
    return ApplicantsPage(
      populated
          ? [
              CompanyMockData.getInitialCandidates().first.copyWith(
                status: 'pending',
              ),
            ]
          : [],
      page,
      page == 1,
    );
  }
}

class NoSession extends AuthController {
  @override
  Future<AuthSession?> build() async => null;
}

void main() {
  testWidgets('applicants reject missing authenticated session', (
    tester,
  ) async {
    final repo = FakeRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(NoSession.new),
          applicantsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: Scaffold(body: CandidatesTab())),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);
    expect(find.text('Belum ada pelamar untuk filter ini.'), findsNothing);
  });

  testWidgets('invalid CV URL shows error without launching viewer', (
    tester,
  ) async {
    final candidate = CompanyMockData.getInitialCandidates().first.copyWith(
      status: 'pending',
      cvUrl: 'javascript:alert(1)',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CandidateCard(candidate: candidate, onStatusChanged: (_) {}),
        ),
      ),
    );
    await tester.tap(find.text('Lihat CV'));
    await tester.pump();
    expect(
      find.text('CV tidak dapat dibuka. Periksa tautan atau coba lagi.'),
      findsOneWidget,
    );
  });
  test(
    'status errors preserve pending; terminal and invalid decisions blocked',
    () async {
      final repo = FakeRepository()..populated = true;
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(MitraAuth.new),
          applicantsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        applicantsProvider(null),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final initial = await container.read(applicantsProvider(null).future);
      final controller = container.read(applicantsProvider(null).notifier);
      final id = initial.items.single.id;
      await controller.decide(id, 'pending');
      expect(repo.decisions, isEmpty);
      repo.fail = true;
      await controller.decide(id, 'accepted');
      expect(
        container
            .read(applicantsProvider(null))
            .requireValue
            .items
            .single
            .status,
        'pending',
      );
      expect(
        container.read(applicantsProvider(null)).requireValue.error,
        isNotNull,
      );
      repo.fail = false;
      await controller.decide(id, 'accepted');
      await controller.decide(id, 'rejected');
      expect(repo.decisions, ['accepted', 'accepted']);
      expect(
        container
            .read(applicantsProvider(null))
            .requireValue
            .items
            .single
            .status,
        'accepted',
      );
    },
  );
  testWidgets('empty, pagination, and server job filter', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(MitraAuth.new),
          applicantsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: Scaffold(body: CandidatesTab())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada pelamar untuk filter ini.'), findsOneWidget);
    await tester.tap(find.text('Muat lebih banyak'));
    await tester.pumpAndSettle();
    expect(find.text('Muat lebih banyak'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Engineer').last);
    await tester.pumpAndSettle();
    expect(repo.calls.last, 'job-1');
  });

  testWidgets('terminal decisions locked, missing CV disabled', (tester) async {
    final candidate = CompanyMockData.getInitialCandidates().first.copyWith(
      status: 'accepted',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CandidateCard(
            candidate: candidate,
            onStatusChanged: (_) => fail('Terminal status changed'),
          ),
        ),
      ),
    );
    expect(find.text('Status final — terkunci'), findsOneWidget);
    expect(find.text('Terima'), findsNothing);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'CV tidak tersedia'),
          )
          .onPressed,
      isNull,
    );
  });
}
