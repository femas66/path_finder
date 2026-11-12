import 'package:flutter/material.dart';

/// Satu tahap proses yang ditampilkan ke user selama model ML
/// (NLP + klasifikasi bidang IT di backend Python) memproses narasi.
///
/// Tahap ini murni presentasi: backend tidak mengirim progres per tahap,
/// jadi tahap dimajukan berdasarkan waktu agar user tahu proses sedang berjalan.
@immutable
class MlProcessingStage {
  const MlProcessingStage({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// Urutan tahap default yang mencerminkan pipeline analisis narasi.
const List<MlProcessingStage> defaultMlProcessingStages = [
  MlProcessingStage(
    title: 'Membaca ceritamu',
    description: 'Menyiapkan dan membersihkan teks narasi.',
    icon: Icons.menu_book_rounded,
  ),
  MlProcessingStage(
    title: 'Mengenali minat & keahlian',
    description: 'NLP mengekstrak kata kunci penting dari ceritamu.',
    icon: Icons.psychology_alt_rounded,
  ),
  MlProcessingStage(
    title: 'Mencocokkan bidang IT',
    description: 'Model ML menghitung kecocokanmu dengan tiap bidang.',
    icon: Icons.hub_rounded,
  ),
  MlProcessingStage(
    title: 'Menyusun rekomendasi',
    description: 'Mengurutkan bidang yang paling sesuai untukmu.',
    icon: Icons.auto_awesome_rounded,
  ),
];

/// Tips yang dirotasi selama user menunggu hasil analisis.
const List<String> defaultMlProcessingTips = [
  'Semakin detail ceritamu tentang hobi dan pengalaman, semakin akurat '
      'rekomendasi yang kami berikan.',
  'Bidang IT sangat beragam: dari Frontend, Backend, Data Science, '
      'hingga DevOps dan Cyber Security.',
  'Banyak profesional IT berpindah bidang di tengah karier. Rekomendasi ini '
      'adalah titik awal, bukan batasan.',
  'Proyek kecil yang kamu kerjakan sendiri bisa menjadi portofolio terbaik '
      'untuk melamar magang.',
];
