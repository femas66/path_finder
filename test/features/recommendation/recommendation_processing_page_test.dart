import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/recommendation/presentation/pages/recommendation_processing_page.dart';

void main() {
  group('RecommendationProcessingPage', () {
    testWidgets('asks for confirmation before cancelling', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: RecommendationProcessingPage(onCancel: () => cancelled = true),
        ),
      );

      // Batal dari dialog: proses tetap berjalan.
      await tester.ensureVisible(find.text('Batalkan'));
      await tester.tap(find.text('Batalkan'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batalkan analisis?'), findsOneWidget);

      await tester.tap(find.text('Lanjut Menunggu'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batalkan analisis?'), findsNothing);
      expect(cancelled, isFalse);

      // Konfirmasi: onCancel dipanggil.
      await tester.ensureVisible(find.text('Batalkan'));
      await tester.tap(find.text('Batalkan'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(cancelled, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('system back button also asks for confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: RecommendationProcessingPage(onCancel: () {})),
      );

      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Batalkan analisis?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
