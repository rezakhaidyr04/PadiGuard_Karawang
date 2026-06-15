import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

class HarvestPredictionScreen extends ConsumerWidget {
  const HarvestPredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);
    final selectedId = ref.watch(selectedSawahIdProvider);

    final sawah = sawahList.firstWhere(
      (s) => s.id == (selectedId ?? (sawahList.isNotEmpty ? sawahList.first.id : '')),
      orElse: () => sawahList.isNotEmpty ? sawahList.first : SawahModel.empty(),
    );

    if (sawah.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analisis Panen AI')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌾', style: TextStyle(fontSize: 60)),
              SizedBox(height: 16),
              Text('Daftarkan sawah terlebih dahulu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      );
    }

    final age = sawah.umurTanamanHari;
    final riskPct = sawah.skorRisiko;
    final healthScore = 100 - riskPct;
    final area = sawah.luasHektar;
    final expectedYield = area * 6.2 * ((100 - riskPct) / 100);
    final daysToHarvest = (115 - age).clamp(0, 115);

    Color healthColor = AppColors.success;
    if (healthScore < 50) {
      healthColor = AppColors.error;
    } else if (healthScore < 80) {
      healthColor = AppColors.warning;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Analisis Panen AI 🌾',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sawah dropdown selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sawah.id,
                  isExpanded: true,
                  items: sawahList.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '🌾 ${s.nama}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary,
                            fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      ref.read(selectedSawahIdProvider.notifier).state = v,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Main prediction card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.lushGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sawah.nama.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Padi ${sawah.jenisTanaman}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _predCard(
                          daysToHarvest == 0
                              ? '🎉 Panen!'
                              : '$daysToHarvest Hari',
                          'Waktu Panen',
                          '📅',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _predCard(
                          '${expectedYield.toStringAsFixed(1)} Ton',
                          'Estimasi Hasil',
                          '📦',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _predCard(
                          '${area.toStringAsFixed(1)} Ha',
                          'Luas Lahan',
                          '🗺️',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health & Risk row
            Row(
              children: [
                Expanded(
                  child: _CircularScoreCard(
                    label: 'SKOR KESEHATAN',
                    value: healthScore,
                    color: healthColor,
                    suffix: '%',
                    sublabel: healthScore >= 80 ? 'Sehat' : healthScore >= 50 ? 'Perlu Perhatian' : 'Kritis',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CircularScoreCard(
                    label: 'RISIKO GAGAL',
                    value: riskPct,
                    color: riskPct >= 60 ? AppColors.error : riskPct >= 30 ? AppColors.warning : AppColors.success,
                    suffix: '%',
                    sublabel: riskPct >= 60 ? 'TINGGI' : riskPct >= 30 ? 'SEDANG' : 'RENDAH',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Critical factors
            _sectionTitle('Faktor Kritis Lahan'),
            const SizedBox(height: 10),
            _factorsCard(sawah),
            const SizedBox(height: 20),

            // Recommendations
            _sectionTitle('Rekomendasi Tindakan AI'),
            const SizedBox(height: 10),
            _recommendationsCard(sawah, riskPct),
          ],
        ),
      ),
    );
  }

  static Widget _predCard(String value, String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins'),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 9, fontFamily: 'Inter'),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Poppins'),
    );
  }

  static Widget _factorsCard(SawahModel sawah) {
    final moistureOk = sawah.kelembaban >= 50 && sawah.kelembaban <= 80;
    final phOk = sawah.ph >= 6.0 && sawah.ph <= 7.0;
    final waterOk = sawah.ketersediaanAir == 'Lancar';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _factorRow('💧 Kelembaban Tanah',
              '${sawah.kelembaban.toStringAsFixed(0)}%',
              moistureOk ? 'Optimal' : 'Kurang Ideal', moistureOk),
          _divider(),
          _factorRow('🧪 pH Keasaman Tanah',
              sawah.ph.toStringAsFixed(1),
              phOk ? 'Baik' : 'Butuh Amandemen', phOk),
          _divider(),
          _factorRow('🌊 Ketersediaan Air',
              sawah.ketersediaanAir,
              waterOk ? 'Optimal' : 'Rawan Kekeringan', waterOk),
        ],
      ),
    );
  }

  static Widget _divider() =>
      const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider);

  static Widget _factorRow(
      String name, String value, String status, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isGood ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(status,
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                isGood ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter')),
                  ],
                ),
              ],
            ),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  static Widget _recommendationsCard(SawahModel sawah, int riskPct) {
    final items = <Map<String, dynamic>>[];

    if (sawah.ph < 6.0) {
      items.add({
        'title': '🪨 Taburkan Kapur Dolomit',
        'desc': 'pH ${sawah.ph} terlalu asam. Taburkan dolomit 1.5 ton/Ha.',
        'color': Colors.purple.shade600,
      });
    }
    if (sawah.kelembaban < 50 || sawah.ketersediaanAir == 'Kurang') {
      items.add({
        'title': '💧 Lakukan Irigasi Tambahan',
        'desc': 'Kelembaban ${sawah.kelembaban.toStringAsFixed(0)}% rendah. Suplai air tambahan.',
        'color': Colors.blue.shade600,
      });
    }
    if (riskPct >= 30) {
      items.add({
        'title': '🪲 Intensifkan Pemantauan Hama',
        'desc': 'Risiko gagal panen $riskPct%. Lakukan penyemprotan preventif insektisida.',
        'color': AppColors.error,
      });
    }
    if (riskPct < 30 && sawah.ph >= 6.0 && sawah.kelembaban >= 50) {
      items.add({
        'title': '✅ Pertahankan Pola Perawatan',
        'desc': 'Semua indikator dalam batas aman. Lanjutkan jadwal pemupukan.',
        'color': AppColors.success,
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final color = item['color'] as Color;
          return Padding(
            padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 14 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (item['title'] as String).split(' ').first,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item['title'] as String).split(' ').skip(1).join(' '),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 3),
                      Text(item['desc'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                              fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Circular Score Card ──────────────────────────────────────────────────────
class _CircularScoreCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String suffix;
  final String sublabel;

  const _CircularScoreCard({
    required this.label,
    required this.value,
    required this.color,
    required this.suffix,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 14),
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 7,
                  color: color,
                  backgroundColor: AppColors.border,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$value$suffix',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
