import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sawah_model.dart';
import '../../../data/models/panen_catatan_model.dart';
import '../../providers/app_state_providers.dart';

class HarvestPredictionScreen extends ConsumerStatefulWidget {
  const HarvestPredictionScreen({super.key});

  @override
  ConsumerState<HarvestPredictionScreen> createState() =>
      _HarvestPredictionScreenState();
}

class _HarvestPredictionScreenState
    extends ConsumerState<HarvestPredictionScreen> {

  // ── Catat Panen dialog ──────────────────────────────────────────────────
  void _showCatatPanenDialog(SawahModel sawah) {
    final hasilCtrl = TextEditingController();
    final hargaCtrl = TextEditingController(text: '6500');
    final catatanCtrl = TextEditingController();
    String kualitas = 'GKP';
    String metode = 'manual';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('📦 Catat Hasil Panen',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sawah: ${sawah.nama}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter')),
                const SizedBox(height: 16),
                TextField(
                  controller: hasilCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Hasil Panen (kg) *',
                    prefixIcon: const Icon(Icons.scale),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hargaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual/kg (Rp)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: kualitas,
                  decoration: InputDecoration(
                    labelText: 'Kualitas Gabah',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GKP', child: Text('GKP - Kering Panen')),
                    DropdownMenuItem(value: 'GKG', child: Text('GKG - Kering Giling')),
                    DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                  ],
                  onChanged: (v) => setDlg(() => kualitas = v ?? 'GKP'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: metode,
                  decoration: InputDecoration(
                    labelText: 'Metode Panen',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'manual', child: Text('Manual (Sabit)')),
                    DropdownMenuItem(
                        value: 'combine_harvester',
                        child: Text('Combine Harvester')),
                  ],
                  onChanged: (v) => setDlg(() => metode = v ?? 'manual'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catatanCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final kg = double.tryParse(hasilCtrl.text.trim());
                if (kg == null || kg <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hasil panen harus diisi!')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final panen = PanenCatatanModel(
                  id: '',
                  sawahId: sawah.id,
                  userId: '',
                  tanggalPanen: DateTime.now(),
                  hasilPanenKg: kg,
                  hasilPerHektar: sawah.luasHektar > 0
                      ? kg / sawah.luasHektar
                      : kg,
                  luasHektar: sawah.luasHektar,
                  kualitasGabah: kualitas,
                  kadarAir: 25.0,
                  hargaJualPerKg:
                      int.tryParse(hargaCtrl.text.trim()) ?? 6500,
                  totalNilaiPanen: 0,
                  catatan: catatanCtrl.text.trim(),
                  metodePanen: metode,
                  createdAt: DateTime.now(),
                );
                final ok = await ref
                    .read(panenCatatanProvider.notifier)
                    .addPanen(panen);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? '✅ Data panen berhasil disimpan!'
                        : '❌ Gagal menyimpan. Coba lagi.'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ));
                }
              },
              child: const Text('Simpan Panen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final sawahList = ref.watch(sawahStateProvider);
    final selectedId = ref.watch(selectedSawahIdProvider);

    final sawah = sawahList.firstWhere(
      (s) =>
          s.id ==
          (selectedId ?? (sawahList.isNotEmpty ? sawahList.first.id : '')),
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
    final healthScore = (100 - riskPct).clamp(0, 100);
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
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
            // Sawah dropdown selector
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
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
                    sublabel: healthScore >= 80
                        ? 'Sehat'
                        : healthScore >= 50
                            ? 'Perlu Perhatian'
                            : 'Kritis',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CircularScoreCard(
                    label: 'RISIKO GAGAL',
                    value: riskPct,
                    color: riskPct >= 60
                        ? AppColors.error
                        : riskPct >= 30
                            ? AppColors.warning
                            : AppColors.success,
                    suffix: '%',
                    sublabel: riskPct >= 60
                        ? 'TINGGI'
                        : riskPct >= 30
                            ? 'SEDANG'
                            : 'RENDAH',
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
            const SizedBox(height: 24),

            // ── Catat Panen Section ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('📦 Riwayat Panen'),
                ElevatedButton.icon(
                  onPressed: () => _showCatatPanenDialog(sawah),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Catat Panen',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                  sublabel: healthScore >= 80
                      ? 'Sehat'
                      : healthScore >= 50
                          ? 'Perlu Perhatian'
                          : 'Kritis',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _CircularScoreCard(
                  label: 'RISIKO GAGAL',
                  value: riskPct,
                  color: riskPct >= 60
                      ? AppColors.error
                      : riskPct >= 30
                          ? AppColors.warning
                          : AppColors.success,
                  suffix: '%',
                  sublabel: riskPct >= 60
                      ? 'TINGGI'
                      : riskPct >= 30
                          ? 'SEDANG'
                          : 'RENDAH',
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
          const SizedBox(height: 24),

          // ── Catat Panen Section ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('📦 Riwayat Panen'),
              ElevatedButton.icon(
                onPressed: () => _showCatatPanenDialog(sawah),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Catat Panen',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PanenHistoryList(sawahId: sawah.id),
          const SizedBox(height: 30),
        ],
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
          _factorRow(
              '💧 Kelembaban Tanah',
              '${sawah.kelembaban.toStringAsFixed(0)}%',
              moistureOk ? 'Optimal' : 'Kurang Ideal',
              moistureOk),
          _divider(),
          _factorRow('🧪 pH Keasaman Tanah', sawah.ph.toStringAsFixed(1),
              phOk ? 'Baik' : 'Butuh Amandemen', phOk),
          _divider(),
          _factorRow('🌊 Ketersediaan Air', sawah.ketersediaanAir,
              waterOk ? 'Optimal' : 'Rawan Kekeringan', waterOk),
        ],
      ),
    );
  }

  static Widget _divider() => const Divider(
      height: 1, indent: 16, endIndent: 16, color: AppColors.divider);

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
                            color: isGood ? AppColors.success : AppColors.error,
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
        'desc':
            'Kelembaban ${sawah.kelembaban.toStringAsFixed(0)}% rendah. Suplai air tambahan.',
        'color': Colors.blue.shade600,
      });
    }
    if (riskPct >= 30) {
      items.add({
        'title': '🪲 Intensifkan Pemantauan Hama',
        'desc':
            'Risiko gagal panen $riskPct%. Lakukan penyemprotan preventif insektisida.',
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

// ─── Panen History List ──────────────────────────────────────────────────────
class _PanenHistoryList extends ConsumerWidget {
  final String sawahId;
  const _PanenHistoryList({required this.sawahId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPanen = ref.watch(panenCatatanProvider);
    final filtered =
        allPanen.where((p) => p.sawahId == sawahId).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Text('📭', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text(
              'Belum ada catatan panen',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              'Klik tombol "Catat Panen" untuk memulai',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.map((p) {
        final date =
            '${p.tanggalPanen.day}/${p.tanggalPanen.month}/${p.tanggalPanen.year}';
        final hasilPerHa = p.hasilPerHektar > 0
            ? '${p.hasilPerHektar.toStringAsFixed(1)} kg/ha'
            : '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌾', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${p.hasilPanenKg.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Poppins'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.kualitasGabah,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date  •  $hasilPerHa  •  ${p.totalNilaiFormatted}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter'),
                    ),
                    if (p.catatan.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        p.catatan,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                            fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Hapus catatan panen?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Batal')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(panenCatatanProvider.notifier)
                        .deletePanen(p.id);
                  }
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
