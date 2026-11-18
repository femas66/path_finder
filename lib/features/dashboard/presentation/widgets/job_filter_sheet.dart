import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pilihan filter aktif pada tab Lowongan (lokasi & divisi/kategori kerja).
///
/// Immutable supaya perubahan filter selalu lewat `setState` di halaman.
class JobFilterSelection {
  const JobFilterSelection({
    this.locations = const <String>{},
    this.categories = const <String>{},
  });

  static const JobFilterSelection empty = JobFilterSelection();

  final Set<String> locations;
  final Set<String> categories;

  bool get isEmpty => locations.isEmpty && categories.isEmpty;

  int get activeCount => locations.length + categories.length;

  bool matchesLocation(String city) =>
      locations.isEmpty || locations.contains(city);

  bool matchesCategory(String category) =>
      categories.isEmpty || categories.contains(category);

  JobFilterSelection withoutLocation(String city) => JobFilterSelection(
    locations: locations.where((item) => item != city).toSet(),
    categories: categories,
  );

  JobFilterSelection withoutCategory(String category) => JobFilterSelection(
    locations: locations,
    categories: categories.where((item) => item != category).toSet(),
  );
}

/// Modal filter lowongan: memilih lokasi dan divisi/kategori kerja.
///
/// Mengembalikan [JobFilterSelection] baru lewat `Navigator.pop`, atau `null`
/// bila modal ditutup tanpa menekan "Terapkan".
class JobFilterSheet extends StatefulWidget {
  const JobFilterSheet({
    super.key,
    required this.locationOptions,
    required this.categoryOptions,
    this.initialSelection = JobFilterSelection.empty,
    this.resultCountBuilder,
  });

  final List<String> locationOptions;
  final List<String> categoryOptions;
  final JobFilterSelection initialSelection;

  /// Opsional: menghitung jumlah lowongan yang cocok agar tombol "Terapkan"
  /// menampilkan hasil sebelum filter dipasang.
  final int Function(JobFilterSelection selection)? resultCountBuilder;

  static Future<JobFilterSelection?> show(
    BuildContext context, {
    required List<String> locationOptions,
    required List<String> categoryOptions,
    JobFilterSelection initialSelection = JobFilterSelection.empty,
    int Function(JobFilterSelection selection)? resultCountBuilder,
  }) {
    return showModalBottomSheet<JobFilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x660F172A),
      builder: (_) => JobFilterSheet(
        locationOptions: locationOptions,
        categoryOptions: categoryOptions,
        initialSelection: initialSelection,
        resultCountBuilder: resultCountBuilder,
      ),
    );
  }

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  late Set<String> _locations;
  late Set<String> _categories;

  @override
  void initState() {
    super.initState();
    _locations = {...widget.initialSelection.locations};
    _categories = {...widget.initialSelection.categories};
  }

  JobFilterSelection get _selection =>
      JobFilterSelection(locations: _locations, categories: _categories);

  void _toggle(Set<String> target, String value) {
    setState(() {
      if (!target.remove(value)) {
        target.add(value);
      }
    });
  }

  void _reset() {
    setState(() {
      _locations.clear();
      _categories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    final resultCount = widget.resultCountBuilder?.call(selection);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(),
              _buildHeader(selection),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Lokasi',
                        options: widget.locationOptions,
                        selected: _locations,
                        icon: Icons.location_on_outlined,
                        emptyLabel: 'Belum ada data lokasi.',
                        onToggle: (value) => _toggle(_locations, value),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Divisi / Kategori Kerja',
                        options: widget.categoryOptions,
                        selected: _categories,
                        icon: Icons.workspaces_outline,
                        emptyLabel: 'Belum ada data kategori.',
                        onToggle: (value) => _toggle(_categories, value),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context, selection, resultCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(JobFilterSelection selection) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter Lowongan',
                  style: GoogleFonts.sen(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selection.isEmpty
                      ? 'Pilih lokasi atau divisi kerja'
                      : '${selection.activeCount} filter dipilih',
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: const Color(0xFF64748B),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required IconData icon,
    required String emptyLabel,
    required ValueChanged<String> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.sen(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (options.isEmpty)
          Text(
            emptyLabel,
            style: GoogleFonts.sen(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => _OptionChip(
                    label: option,
                    isSelected: selected.contains(option),
                    onTap: () => onToggle(option),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    JobFilterSelection selection,
    int? resultCount,
  ) {
    final applyLabel = resultCount == null
        ? 'Terapkan Filter'
        : 'Terapkan${selection.isEmpty ? '' : ' ($resultCount)'}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: selection.isEmpty ? null : _reset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.sen(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(selection),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: const Color(0xFF2373F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.sen(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(applyLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2373F4) : Colors.white,
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
              if (isSelected) ...[
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.sen(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
