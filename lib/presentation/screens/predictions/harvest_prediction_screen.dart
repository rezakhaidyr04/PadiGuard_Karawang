// File: lib/presentation/screens/predictions/harvest_prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

class HarvestPredictionScreen extends ConsumerWidget {
  const HarvestPredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);
    final selectedId = ref.watch(selectedSawahIdProvider);

    // Get active sawah or default to first sawah
    final sawah = sawahList.firstWhere(
      (s) =>
          s.id ==
          (selectedId ?? (sawahList.isNotEmpty ? sawahList.first.id : '')),
      orElse: () => sawahList.isNotEmpty
          ? sawahList.first
          : SawahModel(
              id: '',
              userId: '',
              nama: 'Sawah Belum Terdaftar',
              latitude: 0,
              longitude: 0,
              luasHektar: 0,
              jenisTanaman: 'N/A',
              tanggalTanam: DateTime.now(),
              tanggalPanenExpected: DateTime.now(),
              umurTanamanHari: 0,
              kelembaban: 0,
              ph: 0,
              temperatureCelsius: 0,
              jenisAirTanah: '',
              ketersediaanAir: '',
              status: '',
              statusKesehatan: '',
              skorRisiko: 0,
              idLogHama: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );

    if (sawah.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analisis Panen AI')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined,
                  size: 64, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('Mohon daftarkan sawah terlebih dahulu',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    // Dynamic calculations based on Sawah data
    final age = sawah.umurTanamanHari;
    final riskPercent = sawah.skorRisiko;
    final healthScore = 100 - riskPercent;
    final area = sawah.luasHektar;

    // Average yield: ~6.2 tons per hectare, adjusted by risk factor
    final expectedYield = area * 6.2 * ((100 - riskPercent) / 100);
    final daysToHarvest = (115 - age).clamp(0, 115);

    // Color code health
    Color healthColor = AppColors.success;
    if (healthScore < 50) {
      healthColor = AppColors.error;
    } else if (healthScore < 80) {
      healthColor = AppColors.warning;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Analisis Panen AI 🌾',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to switch fields
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sawah.id,
                  isExpanded: true,
                  items: sawahList.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        'Analisis: ${s.nama}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    ref.read(selectedSawahIdProvider.notifier).state = val;
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Main Prediction Card
            _buildMainPredictionCard(
                context, sawah, expectedYield, daysToHarvest),
            const SizedBox(height: 24),

            // Health Score & Failure Risk Row
            Row(
              children: [
                Expanded(
                  child:
                      _buildHealthScoreCard(context, healthScore, healthColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRiskCard(context, riskPercent),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Critical Factors
            _buildCriticalFactors(context, sawah),
            const SizedBox(height: 24),

            // Recommendations
            _buildRecommendations(context, sawah, riskPercent),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPredictionCard(
    BuildContext context,
    SawahModel sawah,
    double expectedYield,
    int daysToHarvest,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sawah.nama.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'InterTight',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Varietas: Padi ${sawah.jenisTanaman}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Estimasi Waktu Panen',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'InterTight'),
                ),
                const SizedBox(height: 2),
                Text(
                  daysToHarvest == 0
                      ? 'Siap Panen Raya!'
                      : '$daysToHarvest Hari Lagi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Estimasi Hasil Produksi',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'InterTight'),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expectedYield.toStringAsFixed(1)} Ton Gabah',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, int score, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('SKOR KESEHATAN',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InterTight')),
          const SizedBox(height: 12),
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: AppColors.border,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sehat',
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InterTight'),
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

  Widget _buildRiskCard(BuildContext context, int risk) {
    Color color = AppColors.success;
    String label = 'RENDAH';
    if (risk >= 60) {
      color = AppColors.error;
      label = 'TINGGI';
    } else if (risk >= 30) {
      color = AppColors.warning;
      label = 'SEDANG';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('RISIKO GAGAL',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InterTight')),
          const SizedBox(height: 12),
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: risk / 100,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: AppColors.border,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$risk%',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'InterTight')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalFactors(BuildContext context, SawahModel sawah) {
    // Dynamic statuses
    final moistureStatus = sawah.kelembaban >= 50 && sawah.kelembaban <= 80
        ? 'Optimal'
        : 'Kurang Ideal';
    final phStatus =
        sawah.ph >= 6.0 && sawah.ph <= 7.0 ? 'Baik' : 'Butuh Amandemen';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faktor Kritis Lahan',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _factorItem(
                  'Kelembaban Tanah',
                  '${sawah.kelembaban.toStringAsFixed(0)}%',
                  moistureStatus,
                  sawah.kelembaban >= 50 && sawah.kelembaban <= 80),
              const Divider(height: 20),
              _factorItem('pH Keasaman Tanah', sawah.ph.toStringAsFixed(1),
                  phStatus, sawah.ph >= 6.0 && sawah.ph <= 7.0),
              const Divider(height: 20),
              _factorItem(
                  'Ketersediaan Air',
                  sawah.ketersediaanAir,
                  sawah.ketersediaanAir == 'Lancar'
                      ? 'Optimal'
                      : 'Rawan Kekeringan',
                  sawah.ketersediaanAir == 'Lancar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _factorItem(String name, String val, String status, bool isGood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(status,
                style: TextStyle(
                    fontSize: 10,
                    color: isGood ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(val,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildRecommendations(
      BuildContext context, SawahModel sawah, int riskPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan Rekomendasi AI',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (sawah.ph < 6.0)
                _recommendationItem(
                  'Taburkan Kapur Dolomit',
                  'Kadar keasaman pH ${sawah.ph} terlalu asam. Taburkan dolomit 1.5 ton/Ha untuk menaikkan pH.',
                  Icons.science_outlined,
                  Colors.purple,
                ),
              if (sawah.kelembaban < 50 || sawah.ketersediaanAir == 'Kurang')
                _recommendationItem(
                  'Lakukan Irigasi Tambahan',
                  'Kelembaban tanah rendah (${sawah.kelembaban}%). Suplai air tambahan agar tanah tetap lembab.',
                  Icons.water_drop_outlined,
                  Colors.blue,
                ),
              if (riskPercent >= 30)
                _recommendationItem(
                  'Intensifkan Pemantauan Hama',
                  'Tingkat risiko gagal panen naik. Lakukan penyemprotan preventif insektisida sistemik Plenum.',
                  Icons.bug_report_outlined,
                  Colors.red,
                ),
              if (riskPercent < 30 && sawah.ph >= 6.0 && sawah.kelembaban >= 50)
                _recommendationItem(
                  'Pertahankan Pola Perawatan',
                  'Seluruh indikator sawah berada pada batas aman. Lanjutkan jadwal pemupukan sesuai kalender.',
                  Icons.check_circle_outline_rounded,
                  AppColors.success,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendationItem(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.35,
                        fontFamily: 'InterTight')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
