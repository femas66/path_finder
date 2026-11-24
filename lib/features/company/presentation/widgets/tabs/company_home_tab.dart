import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/errors/error_mapper.dart';
import '../../providers/company_jobs_provider.dart';

class CompanyHomeTab extends ConsumerWidget {
  const CompanyHomeTab({
    super.key,
    required this.onNavigateToPostJob,
    required this.onNavigateToCandidates,
  });
  final VoidCallback onNavigateToPostJob, onNavigateToCandidates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(companyJobsProvider);
    Future<void> refresh() async {
      ref.invalidate(companyJobsProvider);
      try {
        await ref.read(companyJobsProvider.future);
      } catch (_) {
        /* Error rendered below. */
      }
    }

    Widget retry(Object error) => Column(
      children: [
        Text(ErrorMapper.fromObject(error).message),
        OutlinedButton(onPressed: refresh, child: const Text('Coba lagi')),
      ],
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Butuh Talenta Mahasiswa Terbaik?',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buka posisi magang dengan kualifikasi yang dibutuhkan perusahaan Anda.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onNavigateToPostJob,
                    icon: const Icon(Icons.add),
                    label: const Text('Posting Lowongan Baru'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lowongan Magang Anda',
              style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            jobs.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => retry(error),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Lowongan Aktif: ${state.result.total}'),
                  const SizedBox(height: 12),
                  if (state.result.items.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Belum ada lowongan aktif.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onNavigateToPostJob,
                      child: const Text('Posting Sekarang'),
                    ),
                  ],
                  for (final job in state.result.items)
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: GoogleFonts.sen(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(job.category),
                            Text(
                              '${job.company} • ${job.location} • ${job.workType}',
                            ),
                            const SizedBox(height: 8),
                            Text(job.description),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: job.requiredSkills
                                  .map((s) => Chip(label: Text(s)))
                                  .toList(),
                            ),
                            if (job.optionalSkills.isNotEmpty)
                              Text(
                                'Keahlian tambahan: ${job.optionalSkills.join(', ')}',
                              ),
                            if (job.sourceUrl.isNotEmpty)
                              SelectableText(job.sourceUrl),
                          ],
                        ),
                      ),
                    ),
                  if (state.error != null)
                    Text(ErrorMapper.fromObject(state.error!).message),
                  if (state.loadingMore)
                    const Center(child: CircularProgressIndicator())
                  else if (state.result.hasMore)
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(companyJobsProvider.notifier).loadMore(),
                      child: Text(
                        state.error == null
                            ? 'Muat lebih banyak'
                            : 'Coba muat lagi',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onNavigateToCandidates,
              icon: const Icon(Icons.people_outline),
              label: const Text('Lihat Semua Pelamar'),
            ),
          ],
        ),
      ),
    );
  }
}
