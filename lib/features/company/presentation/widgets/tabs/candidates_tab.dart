import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/candidate_application.dart';
import '../cards/candidate_card.dart';

class CandidatesTab extends StatefulWidget {
  const CandidatesTab({
    super.key,
    required this.candidates,
    required this.onUpdateStatus,
  });

  final List<CandidateApplication> candidates;
  final void Function(String candidateId, String newStatus) onUpdateStatus;

  @override
  State<CandidatesTab> createState() => _CandidatesTabState();
}

class _CandidatesTabState extends State<CandidatesTab> {
  String _selectedFilter = 'Semua';

  static const List<String> _filters = [
    'Semua',
    'Menunggu Review',
    'Seleksi Berkas',
    'Wawancara',
    'Diterima',
    'Ditolak',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCandidates = _selectedFilter == 'Semua'
        ? widget.candidates
        : widget.candidates
            .where((cand) => cand.status == _selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Filter Chips Horizontal Scroll
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  final count = filter == 'Semua'
                      ? widget.candidates.length
                      : widget.candidates
                          .where((c) => c.status == filter)
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2373F4)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2373F4)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: GoogleFonts.sen(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.sen(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Candidate List or Empty State
          Expanded(
            child: filteredCandidates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off_outlined,
                            size: 48,
                            color: Color(0xFFA0A5BA),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada pelamar dengan status "$_selectedFilter"',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sen(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gunakan filter lain untuk melihat daftar kandidat yang ada.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sen(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: filteredCandidates.length,
                    itemBuilder: (context, index) {
                      final candidate = filteredCandidates[index];
                      return CandidateCard(
                        candidate: candidate,
                        onStatusChanged: (newStatus) {
                          widget.onUpdateStatus(candidate.id, newStatus);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
