import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/candidate_application.dart';

class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onStatusChanged,
  });

  final CandidateApplication candidate;
  final ValueChanged<String> onStatusChanged;

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Diterima':
        return const Color(0xFF059669);
      case 'Ditolak':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Diterima':
        return const Color(0xFF10B981).withValues(alpha: 0.12);
      case 'Ditolak':
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
      default:
        return const Color(0xFF64748B).withValues(alpha: 0.1);
    }
  }

  void _showStatusBottomSheet(BuildContext context) {
    const statuses = [
      'Diterima',
      'Ditolak',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Perbarui Status Pelamar',
                    style: GoogleFonts.sen(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Pilih tahapan proses rekrutmen untuk ${candidate.candidateName}:',
                    style: GoogleFonts.sen(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ...statuses.map((statusOption) {
                  final isCurrent = candidate.status == statusOption;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isCurrent
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isCurrent
                          ? const Color(0xFF2373F4)
                          : const Color(0xFFA0A5BA),
                      size: 20,
                    ),
                    title: Text(
                      statusOption,
                      style: GoogleFonts.sen(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent
                            ? const Color(0xFF2373F4)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onStatusChanged(statusOption);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Name + AI Match Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      const Color(0xFF2373F4).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2373F4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.candidateName,
                        style: GoogleFonts.sen(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${candidate.university} • ${candidate.major}',
                        style: GoogleFonts.sen(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2373F4).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 11,
                        color: Color(0xFF2373F4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${candidate.matchScore}% Match',
                        style: GoogleFonts.sen(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2373F4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Posisi yang dilamar & Tanggal
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.work_outline_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      candidate.jobTitle,
                      style: GoogleFonts.sen(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                  Text(
                    candidate.appliedDate,
                    style: GoogleFonts.sen(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            if (candidate.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${candidate.notes}',
                style: GoogleFonts.sen(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Bottom Actions: Status Badge & Button "Ubah Status"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(candidate.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    candidate.status,
                    style: GoogleFonts.sen(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusTextColor(candidate.status),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showStatusBottomSheet(context),
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    size: 16,
                    color: Color(0xFF2373F4),
                  ),
                  label: Text(
                    'Ubah Status',
                    style: GoogleFonts.sen(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2373F4),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2373F4)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
