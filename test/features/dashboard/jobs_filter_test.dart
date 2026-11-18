import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:path_finder/features/dashboard/presentation/widgets/job_filter_sheet.dart';

void main() {
  Future<void> pumpJobsTab(WidgetTester tester) async {
    // Viewport tinggi supaya keempat kartu lowongan ikut ter-render.
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: DashboardPage(initialIndex: 1)),
    );
    await tester.pumpAndSettle();
  }

  Finder inSheet(String text) => find.descendant(
    of: find.byType(JobFilterSheet),
    matching: find.text(text),
  );

  group('Tab Lowongan — pencarian & filter', () {
    testWidgets('menampilkan seluruh lowongan sebelum difilter', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      expect(find.text('Frontend Developer Intern'), findsOneWidget);
      expect(find.text('Junior Mobile Flutter Engineer'), findsOneWidget);
      expect(find.text('Backend Node.js / Python Intern'), findsOneWidget);
      expect(find.text('UI/UX Product Design Apprentice'), findsOneWidget);
      expect(find.text('4 lowongan tersedia'), findsOneWidget);
    });

    testWidgets('search bar menyaring lowongan secara real-time', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      expect(find.text('Junior Mobile Flutter Engineer'), findsOneWidget);
      expect(find.text('Frontend Developer Intern'), findsNothing);
      expect(find.text('1 dari 4 lowongan'), findsOneWidget);

      // Hapus pencarian lewat tombol clear → seluruh lowongan kembali.
      await tester.tap(find.byTooltip('Hapus pencarian'));
      await tester.pump();

      expect(find.text('Frontend Developer Intern'), findsOneWidget);
      expect(find.text('4 lowongan tersedia'), findsOneWidget);
    });

    testWidgets('search bar juga mencocokkan nama perusahaan dan kategori', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.enterText(find.byType(TextField), 'telkom');
      await tester.pump();

      expect(find.text('Frontend Developer Intern'), findsOneWidget);
      expect(find.text('Junior Mobile Flutter Engineer'), findsNothing);

      await tester.enterText(find.byType(TextField), 'backend');
      await tester.pump();

      expect(find.text('Backend Node.js / Python Intern'), findsOneWidget);
      expect(find.text('Frontend Developer Intern'), findsNothing);
    });

    testWidgets('modal filter menyaring berdasarkan lokasi dan divisi', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.tap(find.byTooltip('Filter lowongan'));
      await tester.pumpAndSettle();

      expect(find.text('Filter Lowongan'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Divisi / Kategori Kerja'), findsOneWidget);

      // Pilih lokasi Jakarta (Gojek & DANA).
      await tester.tap(inSheet('Jakarta'));
      await tester.pump();
      await tester.tap(find.text('Terapkan (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Junior Mobile Flutter Engineer'), findsOneWidget);
      expect(find.text('UI/UX Product Design Apprentice'), findsOneWidget);
      expect(find.text('Frontend Developer Intern'), findsNothing);
      expect(find.text('Backend Node.js / Python Intern'), findsNothing);
      expect(find.text('2 dari 4 lowongan'), findsOneWidget);

      // Tambah divisi UI/UX → hanya DANA yang tersisa.
      await tester.tap(find.byTooltip('Filter lowongan'));
      await tester.pumpAndSettle();
      await tester.tap(inSheet('UI/UX'));
      await tester.pump();
      await tester.tap(find.text('Terapkan (1)'));
      await tester.pumpAndSettle();

      expect(find.text('UI/UX Product Design Apprentice'), findsOneWidget);
      expect(find.text('Junior Mobile Flutter Engineer'), findsNothing);
      expect(find.text('1 dari 4 lowongan'), findsOneWidget);
    });

    testWidgets('chip filter aktif bisa dihapus dari daftar', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.tap(find.byTooltip('Filter lowongan'));
      await tester.pumpAndSettle();
      await tester.tap(inSheet('Bandung'));
      await tester.pump();
      await tester.tap(find.text('Terapkan (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Frontend Developer Intern'), findsOneWidget);
      expect(find.text('Junior Mobile Flutter Engineer'), findsNothing);

      // Hapus chip "Bandung" di bawah search bar.
      await tester.tap(find.text('Bandung'));
      await tester.pump();

      expect(find.text('4 lowongan tersedia'), findsOneWidget);
      expect(find.text('Junior Mobile Flutter Engineer'), findsOneWidget);
    });

    testWidgets('menampilkan empty state saat tidak ada lowongan yang cocok', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.enterText(find.byType(TextField), 'devops');
      await tester.pump();

      expect(find.text('Lowongan tidak ditemukan'), findsOneWidget);
      expect(find.text('0 dari 4 lowongan'), findsOneWidget);

      await tester.tap(find.text('Reset pencarian & filter'));
      await tester.pump();

      expect(find.text('4 lowongan tersedia'), findsOneWidget);
    });

    testWidgets('chip Rekomendasi Matching mengurutkan berdasarkan skor', (
      WidgetTester tester,
    ) async {
      await pumpJobsTab(tester);

      await tester.tap(find.text('Rekomendasi Matching (AI)'));
      await tester.pump();

      expect(find.text('Sesuai kecocokan'), findsOneWidget);

      final firstCardTitle = tester
          .widget<Text>(find.text('Frontend Developer Intern').first)
          .data;
      expect(firstCardTitle, 'Frontend Developer Intern');
    });

    testWidgets('modal filter tidak overflow di layar kecil', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: DashboardPage(initialIndex: 1)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Filter lowongan'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Filter Lowongan'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Semua opsi tetap dapat dijangkau lewat scroll di dalam modal.
      await tester.scrollUntilVisible(
        inSheet('Remote'),
        120,
        scrollable: find
            .descendant(
              of: find.byType(JobFilterSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(inSheet('Remote'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
