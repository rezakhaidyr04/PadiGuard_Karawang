// File: lib/presentation/screens/admin/admin_sawah_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state_providers.dart';
import '../../../data/models/sawah_model.dart';

class AdminSawahScreen extends ConsumerStatefulWidget {
  const AdminSawahScreen({super.key});

  @override
  ConsumerState<AdminSawahScreen> createState() => _AdminSawahScreenState();
}

class _AdminSawahScreenState extends ConsumerState<AdminSawahScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  @override
  Widget build(BuildContext context) {
    final allSawah = ref.watch(sawahStateProvider);

    final filtered = allSawah.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.nama.toLowerCase().contains(q) ||
          s.jenisTanaman.toLowerCase().contains(q);
      final matchesStatus =
          _filterStatus == 'Semua' || s.statusKesehatan == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    final sehat = allSawah.where((s) => s.statusKesehatan == 'Sehat').length;
    final risiko = allSawah.where((s) => s.statusKesehatan == 'Risiko').length;
    final sakit = allSawah.where((s) => s.statusKesehatan == 'Sakit').length;
    final totalHektar =
        allSawah.fold<double>(0, (sum, s) => sum + s.luasHektar);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Summary Cards ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _SummaryChip(
                    label: 'Total Sawah',
                    value: '${allSawah.length}',
                    color: AppColors.primary,
                    emoji: '🌾',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Luas Total',
                    value: '${totalHektar.toStringAsFixed(1)} ha',
                    color: Colors.blueGrey,
                    emoji: '📐',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Sehat',
                    value: '$sehat',
                    color: AppColors.success,
                    emoji: '🟢',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Perlu Pantau',
                    value: '${risiko + sakit}',
                    color: AppColors.error,
                    emoji: '🔴',
                  ),
                ],
              ),
            ),
          ),

          // ─── Search + Filter ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari nama sawah atau varietas padi...',
                        hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                            fontFamily: 'Inter'),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 18, color: AppColors.textHint),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', AppColors.primary),
                          _buildFilterChip('Sehat', AppColors.success),
                          _buildFilterChip('Risiko', AppColors.warning),
                          _buildFilterChip('Sakit', AppColors.error),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Result count ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                '${filtered.length} sawah ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),

          // ─── Sawah list ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: _EmptyState(message: 'Sawah tidak ditemukan'))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SawahAdminCard(sawah: filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, Color color) {
    final isSelected = _filterStatus == status;
    final label = status == 'Sehat'
        ? '🟢 Sehat'
        : status == 'Risiko'
            ? '🟡 Risiko'
            : status == 'Sakit'
                ? '🔴 Sakit'
                : '🌾 Semua';

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String emoji;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textHint,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sawah Admin Card ─────────────────────────────────────────────────────────
class _SawahAdminCard extends StatelessWidget {
  final SawahModel sawah;
  const _SawahAdminCard({required this.sawah});

  @override
  Widget build(BuildContext context) {
    final healthColor = sawah.statusKesehatan == 'Sehat'
        ? AppColors.success
        : sawah.statusKesehatan == 'Risiko'
            ? AppColors.warning
            : AppColors.error;

    final healthEmoji = sawah.statusKesehatan == 'Sehat'
        ? '💚'
        : sawah.statusKesehatan == 'Risiko'
            ? '⚠️'
            : '🔴';

    final phaseLabel = sawah.umurTanamanHari < 20
        ? 'Fase Tunas/Bibit'
        : sawah.umurTanamanHari < 45
            ? 'Fase Vegetatif'
            : sawah.umurTanamanHari < 80
                ? 'Fase Generatif'
                : 'Siap Panen';

    final daysLeft = sawah.tanggalPanenExpected.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: sawah.statusKesehatan == 'Sakit'
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
          width: sawah.statusKesehatan == 'Sakit' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                // Health status icon avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        healthColor.withValues(alpha: 0.15),
                        healthColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: healthColor.withValues(alpha: 0.25)),
                  ),
                  child: Center(
                    child: Text(
                      healthEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sawah.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${sawah.jenisTanaman} • ${sawah.luasHektar} ha',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sawah.statusKesehatan,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: healthColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Risiko: ${sawah.skorRisiko}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: sawah.skorRisiko > 50
                            ? AppColors.error
                            : sawah.skorRisiko > 25
                                ? AppColors.warning
                                : AppColors.success,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Sawah details grid or wrapped rows
            Row(
              children: [
                Expanded(
                  child: _SawahBit(
                    icon: Icons.schedule_rounded,
                    label: '$phaseLabel (${sawah.umurTanamanHari} HST)',
                  ),
                ),
                Expanded(
                  child: _SawahBit(
                    icon: Icons.event_rounded,
                    label: daysLeft > 0
                        ? 'Panen ~$daysLeft hari lagi'
                        : 'Siap panen',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SawahBit(
                    icon: Icons.water_drop_rounded,
                    label: 'pH ${sawah.ph} • Kelembaban ${sawah.kelembaban.toStringAsFixed(0)}%',
                  ),
                ),
                Expanded(
                  child: _SawahBit(
                    icon: Icons.thermostat_rounded,
                    label: 'Suhu ${sawah.temperatureCelsius}°C',
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

// ─── Sawah Detail Bit ─────────────────────────────────────────────────────────
class _SawahBit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SawahBit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.search_off_rounded,
                    size: 36, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba ubah kata kunci atau filter status',
              style: TextStyle(
                color: AppColors.textHint,
                fontFamily: 'Inter',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
