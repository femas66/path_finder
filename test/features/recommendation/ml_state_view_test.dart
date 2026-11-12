import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/recommendation/presentation/widgets/ml_processing_view.dart';
import 'package:path_finder/features/recommendation/presentation/widgets/ml_state_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MlStateView', () {
    testWidgets('shows MlProcessingView while loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MlStateView<String>(
            state: const AsyncLoading(),
            dataBuilder: (_, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(MlProcessingView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows mapped error message and retries', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          MlStateView<String>(
            state: AsyncError(
              const NetworkException(message: 'Koneksi ke server timeout.'),
              StackTrace.empty,
            ),
            onRetry: () => retried = true,
            dataBuilder: (_, data) => Text(data),
          ),
        ),
      );

      expect(find.text('Koneksi ke server timeout.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('renders data builder when data is available', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MlStateView<String>(
            state: const AsyncData('Backend Developer'),
            dataBuilder: (_, data) => Text(data),
          ),
        ),
      );

      expect(find.text('Backend Developer'), findsOneWidget);
      expect(find.byType(MlProcessingView), findsNothing);
    });
  });
}
