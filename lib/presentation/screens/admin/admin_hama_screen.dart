// File: lib/presentation/screens/admin/admin_hama_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state_providers.dart';
import '../../../data/models/hama_model.dart';
import '../../../data/models/sawah_model.dart';

class AdminHamaScreen extends ConsumerStatefulWidget {
  const AdminHamaScreen({super.key});

  @override
  ConsumerState<AdminHamaScreen> createState() => _AdminHamaScreenState();
}

class _AdminHamaScreenState extends ConsumerState<AdminHamaScreen> {
  String _searchQuery = '';
  String _filterRisk = 'Semua';

  @override
  Widget build(BuildContext context) {
    final hamaList = ref.watch(hamaStateProvider);
    final sawahList = ref.watch(sawahStateProvider);

    final filtered = hamaList.where((h) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          h.namaHama.toLowerCase().contains(q) ||
          h.userId.toLowerCase().contains(q) ||
          h.sawahId.toLowerCase().contains(q);
      final matchesRisk = _filterRisk == 'Semua' || h.tingkatRisiko == _filterRisk;
      return matchesSearch && matchesRisk;
    }).toList();

    final high = hamaList.where((h) => h.tingkatRisiko == 'TINGGI').length;
    final medium = hamaList.where((h) => h.tingkatRisiko == 'SEDANG').length;
    final low = hamaList.where((h) => h.tingkatRisiko == 'RENDAH').length;

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
                    label: 'Total',
                    value: '${hamaList.length}',
                    color: AppColors.primary,
                    emoji: '🔬',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Tinggi',
                    value: '$high',
                    color: AppColors.error,
                    emoji: '⚠️',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Sedang',
                    value: '$medium',
                    color: AppColors.warning,
                    emoji: '🟡',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Rendah',
                    value: '$low',
                    color: AppColors.success,
                    emoji: '🟢',
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
                        hintText: 'Cari hama, ID sawah, atau ID user...',
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
                    // Risk filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRiskChip('Semua', AppColors.primary),
                          _buildRiskChip('TINGGI', AppColors.error),
                          _buildRiskChip('SEDANG', AppColors.warning),
                          _buildRiskChip('RENDAH', AppColors.success),
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
                '${filtered.length} laporan ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),

          // ─── Laporan list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: _EmptyState(message: 'Laporan tidak ditemukan'))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _HamaCard(
                        hama: filtered[i],
                        sawahList: sawahList,
                      ),
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskChip(String risk, Color color) {
    final isSelected = _filterRisk == risk;
    final label = risk == 'TINGGI'
        ? '🔴 Tinggi'
        : risk == 'SEDANG'
            ? '🟡 Sedang'
            : risk == 'RENDAH'
                ? '🟢 Rendah'
                : '🔬 Semua';

    return GestureDetector(
      onTap: () => setState(() => _filterRisk = risk),
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
                fontSize: 16,
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

// ─── Hama Card ────────────────────────────────────────────────────────────────
class _HamaCard extends ConsumerWidget {
  final HamaModel hama;
  final List<SawahModel> sawahList;

  const _HamaCard({
    required this.hama,
    required this.sawahList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskColor = hama.tingkatRisiko == 'TINGGI'
        ? AppColors.error
        : hama.tingkatRisiko == 'SEDANG'
            ? AppColors.warning
            : AppColors.success;

    final sawah = sawahList.firstWhere(
      (s) => s.id == hama.sawahId,
      orElse: () => SawahModel.empty(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hama.tingkatRisiko == 'TINGGI' && !hama.resolved
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
          width: hama.tingkatRisiko == 'TINGGI' && !hama.resolved ? 1.5 : 1,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    riskColor.withValues(alpha: 0.2),
                    riskColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: riskColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Icon(
                  hama.tingkatRisiko == 'TINGGI'
                      ? Icons.warning_amber_rounded
                      : Icons.pest_control_rounded,
                  color: riskColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Risk Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hama.tingkatRisiko,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Time Ago
                      Text(
                        _timeAgo(hama.detectedAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hama.namaHama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Confidence: ${(hama.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Sawah info
                  Row(
                    children: [
                      const Icon(Icons.grass_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sawah.nama.isEmpty ? 'Sawah Karawang' : sawah.nama,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        'Petani: ${hama.userId}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Deskripsi
                  Text(
                    hama.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Pesticide recommendation
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services_outlined,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Obat: ${hama.pestsidaRekomendasi} (${hama.dosasiPestisida} ${hama.unitDosis}/ha)',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Toggle Resolve
            Column(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(hamaStateProvider.notifier)
                      .toggleResolveStatus(hama.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 26,
                    decoration: BoxDecoration(
                      color: hama.resolved
                          ? AppColors.success
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 220),
                      alignment: hama.resolved
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hama.resolved ? 'Selesai' : 'Aktif',
                  style: TextStyle(
                    fontSize: 9,
                    color: hama.resolved ? AppColors.success : AppColors.error,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
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
              'Coba ubah kata kunci atau filter',
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
