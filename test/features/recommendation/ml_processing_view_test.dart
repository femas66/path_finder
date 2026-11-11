import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/recommendation/presentation/widgets/ml_processing_stage.dart';
import 'package:path_finder/features/recommendation/presentation/widgets/ml_processing_view.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

/// Membongkar widget agar semua Timer dan animasi berulang ikut dibersihkan.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  const interval = Duration(milliseconds: 2500);
  final stages = defaultMlProcessingStages;

  group('MlProcessingView', () {
    testWidgets('renders title, all stages and the first stage as active', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MlProcessingView()));

      expect(find.text('Menganalisis ceritamu'), findsOneWidget);
      for (final stage in stages) {
        expect(find.text(stage.title), findsOneWidget);
      }
      // Hanya tahap aktif yang menampilkan deskripsi.
      expect(find.text(stages[0].description), findsOneWidget);
      expect(find.text(stages[1].description), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.text('Tahukah kamu?'), findsOneWidget);

      await _unmount(tester);
    });

    testWidgets('advances stages over time but never completes the last one', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MlProcessingView()));

      await tester.pump(interval);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(stages[1].description), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Tunggu jauh melebihi jumlah tahap.
      for (var i = 0; i < 6; i++) {
        await tester.pump(interval);
      }
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(stages.last.description), findsOneWidget);
      expect(
        find.byIcon(Icons.check_rounded),
        findsNWidgets(stages.length - 1),
      );

      await _unmount(tester);
    });

    testWidgets('marks every stage done when isCompleted is true', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MlProcessingView()));
      await tester.pumpWidget(
        _wrap(const MlProcessingView(isCompleted: true)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Analisis selesai'), findsOneWidget);
      // Semua indikator tahap + ikon orb.
      expect(
        find.byIcon(Icons.check_rounded),
        findsNWidgets(stages.length + 1),
      );
      expect(find.text('Tahukah kamu?'), findsNothing);

      await _unmount(tester);
    });

    testWidgets('shows slow notice after slowThreshold', (tester) async {
      await tester.pumpWidget(
        _wrap(const MlProcessingView(slowThreshold: Duration(seconds: 3))),
      );

      expect(find.textContaining('lebih lama dari biasanya'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('lebih lama dari biasanya'), findsOneWidget);

      await _unmount(tester);
    });

    testWidgets('rotates tips', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MlProcessingView(
            tips: ['Tip pertama', 'Tip kedua'],
            tipInterval: Duration(seconds: 2),
          ),
        ),
      );

      expect(find.text('Tip pertama'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Tip kedua'), findsOneWidget);
      expect(find.text('Tip pertama'), findsNothing);

      await _unmount(tester);
    });

    testWidgets('cancel button is shown only with onCancel and calls it', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MlProcessingView()));
      expect(find.text('Batalkan'), findsNothing);

      var cancelled = false;
      await tester.pumpWidget(
        _wrap(MlProcessingView(onCancel: () => cancelled = true)),
      );
      await tester.ensureVisible(find.text('Batalkan'));
      await tester.tap(find.text('Batalkan'));
      expect(cancelled, isTrue);

      await _unmount(tester);
    });

    testWidgets('renders with reduced motion enabled', (tester) async {
      await tester.pumpWidget(
        _wrap(const MlProcessingView(), disableAnimations: true),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Menganalisis ceritamu'), findsOneWidget);

      await _unmount(tester);
    });
  });
}
