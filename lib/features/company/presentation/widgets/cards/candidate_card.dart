import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/candidate_application.dart';

String statusLabel(String status) => switch (status) {
  'pending' => 'Menunggu',
  'accepted' => 'Diterima',
  'rejected' => 'Ditolak',
  _ => status,
};

class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onStatusChanged,
    this.busy = false,
  });
  final CandidateApplication candidate;
  final ValueChanged<String> onStatusChanged;
  final bool busy;

  Future<void> _openCv(BuildContext context) async {
    final uri = Uri.tryParse(candidate.cvUrl?.trim() ?? '');
    try {
      if (uri == null ||
          !['https', 'http'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        throw const FormatException('Invalid CV URL');
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Cannot open CV');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'CV tidak dapat dibuka. Periksa tautan atau coba lagi.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.candidateName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (candidate.email.isNotEmpty) Text(candidate.email),
          Text(candidate.jobTitle),
          Text(candidate.appliedDate),
          Text(statusLabel(candidate.status)),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: candidate.cvUrl?.trim().isNotEmpty == true
                    ? () => _openCv(context)
                    : null,
                icon: const Icon(Icons.description_outlined),
                label: Text(
                  candidate.cvUrl?.trim().isNotEmpty == true
                      ? 'Lihat CV'
                      : 'CV tidak tersedia',
                ),
              ),
              if (candidate.canDecide) ...[
                TextButton(
                  onPressed: busy ? null : () => _confirm(context, 'accepted'),
                  child: const Text('Terima'),
                ),
                TextButton(
                  onPressed: busy ? null : () => _confirm(context, 'rejected'),
                  child: const Text('Tolak'),
                ),
              ] else
                const Text('Status final — terkunci'),
            ],
          ),
          if (busy) const LinearProgressIndicator(),
        ],
      ),
    ),
  );

  Future<void> _confirm(BuildContext context, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${statusLabel(status)}: ${candidate.candidateName}?'),
        content: const Text('Keputusan ini final dan tidak dapat diubah.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) onStatusChanged(status);
  }
}
