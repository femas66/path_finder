import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/data/company_mock_data.dart';
import 'package:path_finder/features/company/domain/models/company_profile.dart';
import 'package:path_finder/features/company/presentation/widgets/tabs/company_profile_tab.dart';

void main() {
  group('CompanyProfileTab', () {
    testWidgets('displays company profile details and verification badge', (
      tester,
    ) async {
      final profile = CompanyMockData.getInitialCompanyProfile();

      await tester.pumpWidget(
        MaterialApp(home: CompanyProfileTab(profile: profile)),
      );

      expect(find.text('Profil Perusahaan'), findsOneWidget);
      expect(find.text(profile.companyName), findsOneWidget);
      expect(
        find.text('${profile.industrySector} • ${profile.city}'),
        findsOneWidget,
      );
      expect(find.text('Mitra Industri Terverifikasi'), findsOneWidget);
      expect(find.text('Informasi Perusahaan'), findsOneWidget);
      expect(find.text(profile.description), findsOneWidget);
      expect(find.text(profile.officeAddress), findsOneWidget);
      expect(find.text(profile.contactEmail), findsOneWidget);
      expect(find.text(profile.contactPhone), findsOneWidget);
      expect(find.text(profile.website), findsOneWidget);
    });

    testWidgets('validates inputs and updates profile on Edit Profil submit', (
      tester,
    ) async {
      CompanyProfile currentProfile =
          CompanyMockData.getInitialCompanyProfile();

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return CompanyProfileTab(
                profile: currentProfile,
                onProfileUpdated: (updated) {
                  setState(() => currentProfile = updated);
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('edit_company_profile_button')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profil Perusahaan'), findsWidgets);

      // Clear name & enter invalid email to verify validation blocks submit
      await tester.enterText(find.byKey(const Key('company_name_field')), '');
      await tester.enterText(
        find.byKey(const Key('company_email_field')),
        'email-salah',
      );

      final saveBtn = find.byKey(const Key('save_company_profile_button'));
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Nama perusahaan wajib diisi'), findsOneWidget);
      expect(find.text('Format email tidak valid'), findsOneWidget);

      // Fill valid updated values
      final nameField = find.byKey(const Key('company_name_field'));
      await tester.ensureVisible(nameField);
      await tester.pumpAndSettle();
      await tester.enterText(nameField, 'PT Nusantara AI Labs');

      final cityField = find.byKey(const Key('company_city_field'));
      await tester.ensureVisible(cityField);
      await tester.pumpAndSettle();
      await tester.enterText(cityField, 'Malang');

      final emailField = find.byKey(const Key('company_email_field'));
      await tester.ensureVisible(emailField);
      await tester.pumpAndSettle();
      await tester.enterText(emailField, 'hr@nusantara-ai.id');

      final descField = find.byKey(const Key('company_description_field'));
      await tester.ensureVisible(descField);
      await tester.pumpAndSettle();
      await tester.enterText(
        descField,
        'Startup rekayasa perangkat lunak dan kecerdasan buatan untuk industri.',
      );

      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(currentProfile.companyName, 'PT Nusantara AI Labs');
      expect(currentProfile.city, 'Malang');
      expect(currentProfile.contactEmail, 'hr@nusantara-ai.id');
      expect(find.text('PT Nusantara AI Labs'), findsOneWidget);
      expect(find.text('hr@nusantara-ai.id'), findsOneWidget);
    });

    testWidgets('opens legality modal and notification preference toggles', (
      tester,
    ) async {
      CompanyProfile currentProfile =
          CompanyMockData.getInitialCompanyProfile();

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return CompanyProfileTab(
                profile: currentProfile,
                onProfileUpdated: (updated) {
                  setState(() => currentProfile = updated);
                },
              );
            },
          ),
        ),
      );

      // Open legality sheet
      final legalityTile = find.text('Detail Legalitas & Profil Perusahaan');
      await tester.scrollUntilVisible(
        legalityTile,
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(legalityTile);
      await tester.pumpAndSettle();

      expect(find.text('Legalitas & Profil Industri'), findsOneWidget);
      expect(find.text(currentProfile.nib), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      // Open notification preferences sheet and toggle switch
      final notifTile = find.text('Preferensi Notifikasi Pelamar');
      await tester.scrollUntilVisible(
        notifTile,
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(notifTile);
      await tester.pumpAndSettle();

      expect(find.text('Preferensi Notifikasi'), findsOneWidget);
      await tester.tap(find.byKey(const Key('notify_high_match_switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_notification_pref_button')));
      await tester.pumpAndSettle();

      expect(currentProfile.notifyHighMatch, isFalse);
      expect(currentProfile.notifyNewApplication, isTrue);
    });
  });
}
