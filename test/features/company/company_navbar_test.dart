import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/presentation/widgets/company_app_bar.dart';
import 'package:path_finder/features/company/presentation/widgets/company_bottom_navbar.dart';

void main() {
  group('CompanyBottomNavbar', () {
    testWidgets('renders all 4 items and triggers onTap callback', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CompanyBottomNavbar(
              currentIndex: selectedIndex,
              onTap: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      expect(find.text('Ringkasan'), findsOneWidget);
      expect(find.text('Buat Lowongan'), findsOneWidget);
      expect(find.text('Kandidat'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Buat Lowongan'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);

      await tester.tap(find.text('Kandidat'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 2);
    });
  });

  group('CompanyAppBar', () {
    testWidgets('renders company title and role subtitle correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CompanyAppBar(
              companyName: 'PT Inovasi Teknologi Nusantara',
            ),
          ),
        ),
      );

      expect(find.text('PT Inovasi Teknologi Nusantara'), findsOneWidget);
      expect(find.text('Portal Perusahaan • Rekrutmen'), findsOneWidget);
    });
  });
}
