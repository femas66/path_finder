import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/app/app.dart';

void main() {
  testWidgets('App renders placeholder/initial route test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.text('Splash Screen'), findsNWidgets(2));
  });
}
