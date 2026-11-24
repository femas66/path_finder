import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/admin_mahasiswa_model.dart';
import '../providers/admin_providers.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddMahasiswaDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    final cvCtrl = TextEditingController();
    final portCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tambah Data Mahasiswa',
          style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Kampus *'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nimCtrl,
                decoration: const InputDecoration(labelText: 'NIM *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cvCtrl,
                decoration: const InputDecoration(labelText: 'URL Link CV (opsional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: portCtrl,
                decoration: const InputDecoration(labelText: 'URL Portofolio (opsional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  emailCtrl.text.trim().isEmpty ||
                  nimCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama, Email, dan NIM wajib diisi')),
                );
                return;
              }

              Navigator.pop(ctx);
              try {
                final source = ref.read(adminRemoteSourceProvider);
                await source.createMahasiswa(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  nim: nimCtrl.text.trim(),
                  cv: cvCtrl.text.trim().isNotEmpty ? cvCtrl.text.trim() : null,
                  portfolioUrl: portCtrl.text.trim().isNotEmpty ? portCtrl.text.trim() : null,
                );

                ref.invalidate(adminMahasiswaListProvider(_searchQuery));
                ref.invalidate(adminDashboardStatsProvider);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mahasiswa berhasil ditambahkan!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menambah mahasiswa: $e'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2373F4)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditMahasiswaDialog(AdminMahasiswaItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final emailCtrl = TextEditingController(text: item.email);
    final nimCtrl = TextEditingController(text: item.nim);
    final pwdCtrl = TextEditingController();
    final cvCtrl = TextEditingController(text: item.cv ?? '');
    final portCtrl = TextEditingController(text: item.portfolioUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Data Mahasiswa',
          style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nimCtrl,
                decoration: const InputDecoration(labelText: 'NIM'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pwdCtrl,
                decoration: const InputDecoration(labelText: 'Reset Password (kosongkan jika tidak diubah)'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cvCtrl,
                decoration: const InputDecoration(labelText: 'URL Link CV'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: portCtrl,
                decoration: const InputDecoration(labelText: 'URL Portofolio'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final source = ref.read(adminRemoteSourceProvider);
                await source.updateMahasiswa(
                  item.id,
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                  nim: nimCtrl.text.trim().isNotEmpty ? nimCtrl.text.trim() : null,
                  password: pwdCtrl.text.isNotEmpty ? pwdCtrl.text : null,
                  cv: cvCtrl.text.trim().isNotEmpty ? cvCtrl.text.trim() : null,
                  portfolioUrl: portCtrl.text.trim().isNotEmpty ? portCtrl.text.trim() : null,
                );

                ref.invalidate(adminMahasiswaListProvider(_searchQuery));

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data mahasiswa berhasil diperbarui!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui: $e'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2373F4)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMahasiswa(AdminMahasiswaItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Mahasiswa?', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${item.name}" (${item.nim})? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.sen(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final source = ref.read(adminRemoteSourceProvider);
                final success = await source.deleteMahasiswa(item.id);

                if (success) {
                  ref.invalidate(adminMahasiswaListProvider(_searchQuery));
                  ref.invalidate(adminDashboardStatsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mahasiswa berhasil dihapus'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final mahasiswaAsync = ref.watch(adminMahasiswaListProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Admin Portal PathFinder',
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authLocalSourceProvider).clearSession();
              if (context.mounted) {
                context.go(AppRoutePaths.login);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminMahasiswaListProvider(_searchQuery));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Metrik Ringkasan Admin
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Role Akses',
                      value: stats.role.toUpperCase(),
                      icon: Icons.shield_rounded,
                      color: const Color(0xFF2373F4),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Admin Email',
                      value: stats.email.split('@').first,
                      icon: Icons.admin_panel_settings_rounded,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Header Bagian Manajemen Mahasiswa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manajemen Mahasiswa',
                  style: GoogleFonts.sen(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddMahasiswaDialog,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'Tambah',
                    style: GoogleFonts.sen(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2373F4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar Mahasiswa
            TextField(
              controller: _searchCtrl,
              onSubmitted: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau NIM...',
                hintStyle: GoogleFonts.sen(fontSize: 13, color: const Color(0xFFA0A5BA)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA0A5BA)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Mahasiswa
            mahasiswaAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada data mahasiswa ditemukan',
                          style: GoogleFonts.sen(fontSize: 14, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: list.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF2373F4).withValues(alpha: 0.1),
                            child: Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : 'M',
                              style: GoogleFonts.sen(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2373F4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.sen(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIM: ${item.nim} • ${item.email}',
                                  style: GoogleFonts.sen(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2373F4)),
                            onPressed: () => _showEditMahasiswaDialog(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                            onPressed: () => _confirmDeleteMahasiswa(item),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Gagal memuat mahasiswa: $err', style: GoogleFonts.sen(color: const Color(0xFFDC2626))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.sen(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.sen(fontSize: 15, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
