import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/story/domain/entities/user_story.dart';
import 'package:path_finder/features/story/domain/story_repository.dart';
import 'package:path_finder/features/story/presentation/pages/story_page.dart';
import 'package:path_finder/features/story/presentation/providers/story_providers.dart';
import 'package:path_finder/features/story/presentation/widgets/story_input_field.dart';

class _FakeStoryRepository implements StoryRepository {
  _FakeStoryRepository({this.shouldFail = false});

  bool shouldFail;
  String? lastContent;
  int submitCount = 0;

  @override
  Future<UserStory> submitStory({required String content}) async {
    submitCount++;
    lastContent = content;

    if (shouldFail) {
      throw const NetworkException(
        message: 'Gagal terhubung ke backend. Pastikan server backend aktif.',
      );
    }

    return UserStory(
      id: 'story_test_1',
      content: content,
      wordCount: content.split(RegExp(r'\s+')).length,
      analysisStatus: 'processing',
      createdAt: DateTime(2026, 11, 18),
    );
  }
}

Widget _buildApp(_FakeStoryRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutePaths.story,
    routes: [
      GoRoute(
        path: AppRoutePaths.story,
        builder: (context, state) => const StoryPage(),
      ),
      GoRoute(
        path: AppRoutePaths.recommendationProcessing,
        builder: (context, state) =>
            const Scaffold(body: Text('Processing Screen')),
      ),
      GoRoute(
        path: AppRoutePaths.dashboard,
        builder: (context, state) =>
            const Scaffold(body: Text('Dashboard Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      storyRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Memakai permukaan uji yang tinggi agar seluruh isi form satu halaman
/// ter-render tanpa perlu scroll manual di setiap test.
Future<void> _pumpStoryPage(
  WidgetTester tester,
  _FakeStoryRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(_buildApp(repository));
  await tester.pumpAndSettle();
}

String _validStory() => 'a' * (StoryInputField.minStoryLength + 10);

void main() {
  group('StoryPage Widget Tests', () {
    testWidgets('renders single page form with textarea and submit button',
        (tester) async {
      await _pumpStoryPage(tester, _FakeStoryRepository());

      expect(find.text('Cerita Diri'), findsOneWidget);
      expect(find.text('Ceritakan dirimu'), findsOneWidget);
      expect(find.text('Agar hasilnya lebih akurat, ceritakan:'), findsOneWidget);
      expect(find.text('Cerita kamu'), findsOneWidget);
      expect(find.byType(StoryInputField), findsOneWidget);
      expect(find.text('Analisis Ceritaku'), findsOneWidget);
      expect(find.text('Nanti saja'), findsOneWidget);
    });

    testWidgets('shows validation error when submitted empty', (tester) async {
      final repository = _FakeStoryRepository();
      await _pumpStoryPage(tester, repository);

      await tester.tap(find.text('Analisis Ceritaku'));
      await tester.pumpAndSettle();

      expect(find.text('Cerita tidak boleh kosong'), findsOneWidget);
      expect(repository.submitCount, equals(0));
    });

    testWidgets('shows validation error when story is too short',
        (tester) async {
      final repository = _FakeStoryRepository();
      await _pumpStoryPage(tester, repository);

      await tester.enterText(find.byType(TextFormField), 'Terlalu pendek');
      await tester.tap(find.text('Analisis Ceritaku'));
      await tester.pumpAndSettle();

      expect(find.textContaining('minimal 50 karakter'), findsWidgets);
      expect(repository.submitCount, equals(0));
    });

    testWidgets('submits story and navigates to ML processing page',
        (tester) async {
      final repository = _FakeStoryRepository();
      await _pumpStoryPage(tester, repository);

      await tester.enterText(find.byType(TextFormField), _validStory());
      await tester.tap(find.text('Analisis Ceritaku'));
      await tester.pumpAndSettle();

      expect(repository.submitCount, equals(1));
      expect(repository.lastContent, equals(_validStory()));
      expect(find.text('Processing Screen'), findsOneWidget);
    });

    testWidgets('shows error SnackBar when backend rejects the story',
        (tester) async {
      final repository = _FakeStoryRepository(shouldFail: true);
      await _pumpStoryPage(tester, repository);

      await tester.enterText(find.byType(TextFormField), _validStory());
      await tester.tap(find.text('Analisis Ceritaku'));
      await tester.pumpAndSettle();

      expect(
        find.text('Gagal terhubung ke backend. Pastikan server backend aktif.'),
        findsOneWidget,
      );
      expect(find.text('Processing Screen'), findsNothing);
    });

    testWidgets('skip button goes to dashboard without submitting',
        (tester) async {
      final repository = _FakeStoryRepository();
      await _pumpStoryPage(tester, repository);

      await tester.tap(find.text('Nanti saja'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Screen'), findsOneWidget);
      expect(repository.submitCount, equals(0));
    });

    testWidgets('character counter updates while typing', (tester) async {
      await _pumpStoryPage(tester, _FakeStoryRepository());

      expect(find.text('0/${StoryInputField.maxStoryLength}'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Halo');
      await tester.pump();

      expect(find.text('4/${StoryInputField.maxStoryLength}'), findsOneWidget);
    });
  });
}
