import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../providers/applicants_provider.dart';
import '../cards/candidate_card.dart';

class CandidatesTab extends ConsumerStatefulWidget {
  const CandidatesTab({super.key});
  @override
  ConsumerState<CandidatesTab> createState() => _CandidatesTabState();
}

class _CandidatesTabState extends ConsumerState<CandidatesTab> {
  String? _jobId;
  String? _status;
  String message(Object error) =>
      error is AppException ? error.message : 'Gagal memuat data. Coba lagi.';

  @override
  Widget build(BuildContext context) {
    final provider = applicantsProvider(_jobId);
    final applicants = ref.watch(provider);
    final jobs = ref.watch(applicantJobsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              jobs.when(
                data: (jobs) => DropdownButtonFormField<String>(
                  initialValue: _jobId,
                  decoration: const InputDecoration(labelText: 'Lowongan'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Semua Lowongan'),
                    ),
                    ...jobs.entries.map(
                      (job) => DropdownMenuItem(
                        value: job.key,
                        child: Text(job.value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  isExpanded: true,
                  onChanged: (value) =>
                      setState(() => _jobId = value == '' ? null : value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => TextButton(
                  onPressed: () => ref.invalidate(applicantJobsProvider),
                  child: Text('${message(error)} Muat ulang lowongan'),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final status in [
                    null,
                    'pending',
                    'accepted',
                    'rejected',
                  ])
                    ChoiceChip(
                      label: Text(
                        status == null ? 'Semua' : statusLabel(status),
                      ),
                      selected: _status == status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                ],
              ),
              const Text(
                'Filter status berlaku pada pelamar yang sudah dimuat.',
              ),
            ],
          ),
        ),
        Expanded(
          child: applicants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message(error)),
                  TextButton(
                    onPressed: () => ref.invalidate(provider),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
            data: (data) {
              final items = data.items
                  .where((item) => _status == null || item.status == _status)
                  .toList();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(provider);
                  await ref.read(provider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (data.error != null) ...[
                      Text(message(data.error!)),
                      const Text(
                        'Perubahan belum disimpan atau halaman berikutnya gagal dimuat. Coba lagi.',
                      ),
                    ],
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada pelamar untuk filter ini.'),
                      ),
                    for (final item in items)
                      CandidateCard(
                        candidate: item,
                        busy: data.busy.isNotEmpty,
                        onStatusChanged: (status) =>
                            ref.read(provider.notifier).decide(item.id, status),
                      ),
                    if (data.hasMore)
                      TextButton(
                        onPressed: data.loadingMore || data.busy.isNotEmpty
                            ? null
                            : () => ref.read(provider.notifier).loadMore(),
                        child: Text(
                          data.loadingMore ? 'Memuat...' : 'Muat lebih banyak',
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
