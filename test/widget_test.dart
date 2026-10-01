import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/app/app.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.text('PathFinder'), findsOneWidget);
    expect(find.text('Discover Your IT Career Path'), findsOneWidget);
  });
}
