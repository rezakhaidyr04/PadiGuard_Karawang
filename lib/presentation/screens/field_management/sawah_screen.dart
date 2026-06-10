// File: lib/presentation/screens/field_management/sawah_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

class SawahScreen extends ConsumerWidget {
  const SawahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);

    // Calculate Summary Stats
    final totalFields = sawahList.length;
    double totalArea = 0.0;
    double avgHealth = 0.0;
    int healthyCount = 0;
    int riskCount = 0;
    int sickCount = 0;

    for (final s in sawahList) {
      totalArea += s.luasHektar;
      avgHealth += (100 - s.skorRisiko);
      
      // Count health status
      if (s.statusKesehatan == 'Sehat') {
        healthyCount++;
      } else if (s.statusKesehatan == 'Risiko') {
        riskCount++;
      } else if (s.statusKesehatan == 'Sakit') {
        sickCount++;
      }
    }
    if (sawahList.isNotEmpty) {
      avgHealth = avgHealth / sawahList.length;
    } else {
      avgHealth = 0.0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manajemen Sawah',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kelola semua lahan pertanian Anda',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'InterTight'),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSawahDialog(context, ref),
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalFields Sawah Aktif',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pantau kesehatan tanaman dan kelola semua lahan pertanian Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'InterTight',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 26,
                      child: _summaryCard('$totalFields', 'Total Lahan',
                          Icons.agriculture_rounded, AppColors.primary),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 26,
                      child: _summaryCard('${totalArea.toStringAsFixed(1)} Ha',
                          'Total Luas', Icons.straighten_rounded, Colors.blue),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 - 20,
                      child: _summaryCard(
                        '$healthyCount',
                        'Sehat',
                        Icons.favorite_rounded,
                        AppColors.success,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 - 20,
                      child: _summaryCard(
                        '$riskCount',
                        'Risiko',
                        Icons.warning_rounded,
                        AppColors.warning,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 - 20,
                      child: _summaryCard(
                        '$sickCount',
                        'Sakit',
                        Icons.local_hospital_rounded,
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Daftar Lahan Sawah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            if (sawahList.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.agriculture_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Belum Ada Data Sawah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mulai dengan mendaftarkan lahan pertanian Anda untuk memantau kesehatan tanaman dan memprediksi hasil panen.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'InterTight',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          '💡 Tekan tombol "Tambah" di atas untuk registrasi sawah pertama Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'InterTight',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSawahCard(
                      context,
                      sawahList[index],
                      ref,
                    ),
                    childCount: sawahList.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'InterTight',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSawahCard(
      BuildContext context, SawahModel sawah, WidgetRef ref) {
    // Determine Health status badge
    Color healthColor = AppColors.success;
    if (sawah.statusKesehatan == 'Sakit') {
      healthColor = AppColors.error;
    } else if (sawah.statusKesehatan == 'Risiko') {
      healthColor = AppColors.warning;
    }

    // Determine growth phase text
    String phaseLabel = 'Tunas';
    if (sawah.umurTanamanHari >= 90) {
      phaseLabel = 'Siap Panen';
    } else if (sawah.umurTanamanHari >= 61) {
      phaseLabel = 'Generatif';
    } else if (sawah.umurTanamanHari >= 31) {
      phaseLabel = 'Vegetatif';
    } else {
      phaseLabel = 'Bibit';
    }

    // Panen estimate
    int hariTersisa = sawah.tanggalPanenExpected.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sawah.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${sawah.latitude.toStringAsFixed(3)}, ${sawah.longitude.toStringAsFixed(3)}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontFamily: 'InterTight'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: healthColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        sawah.statusKesehatan,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: healthColor,
                          fontFamily: 'InterTight',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info Chips Row
            Row(
              children: [
                Expanded(
                  child: _infoChip(Icons.straighten_rounded, '${sawah.luasHektar} Ha',
                      Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoChip(
                      Icons.grass_rounded, sawah.jenisTanaman, AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoChip(Icons.calendar_month_rounded,
                      '${sawah.umurTanamanHari} HST', Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Growth Phase Progress Bar
            _progressBar('Fase Pertumbuhan: $phaseLabel',
                sawah.umurTanamanHari, 120, AppColors.primary),
            const SizedBox(height: 12),

            // Environmental Conditions
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop_outlined,
                          color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      const Text('Kelembaban: ',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                      Flexible(
                        child: Text('${sawah.kelembaban.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.science_outlined,
                          color: Colors.purple, size: 14),
                      const SizedBox(width: 4),
                      const Text('pH: ',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                      Flexible(
                        child: Text(sawah.ph.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.thermostat_outlined,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      const Text('Suhu: ',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                      Flexible(
                        child: Text('${sawah.temperatureCelsius.toStringAsFixed(0)}°',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Harvest Info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: Colors.orange, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimasi Panen',
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                                fontFamily: 'InterTight')),
                        Text(
                          hariTersisa > 0
                              ? '$hariTersisa hari lagi'
                              : 'Siap panen',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${sawah.tanggalPanenExpected.day}/${sawah.tanggalPanenExpected.month}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontFamily: 'InterTight',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSawahDetail(context, sawah),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Detail',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(selectedSawahIdProvider.notifier).state =
                          sawah.id;
                      ref.read(currentTabProvider.notifier).state =
                          2; // Redirect to Hama Scan
                    },
                    icon: const Icon(Icons.bug_report_rounded,
                        size: 16, color: Colors.white),
                    label: const Text('Scan',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: 'InterTight',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String label, int value, int maxVal, Color color) {
    double progress = (value / maxVal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'InterTight')),
            Text('$value/$maxVal Hari',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'InterTight')),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ─── Add Sawah Bottom Sheet Form ──────────────────────────────────────────
  void _showAddSawahDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    String? selectedPadi = 'Ciherang';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftarkan Sawah Baru 🌾',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Nama Sawah
                const Text('Nama Sawah',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Sawah Utama Blok C',
                    prefixIcon: Icon(Icons.agriculture_rounded,
                        color: AppColors.primary),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Luas & Jenis Padi Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Luas Sawah (Ha)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: areaController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Contoh: 1.5',
                              prefixIcon: Icon(Icons.straighten_rounded,
                                  color: AppColors.primary),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Varietas Padi',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedPadi,
                                isExpanded: true,
                                items: [
                                  'Ciherang',
                                  'Inpari 32',
                                  'IR64',
                                  'Pandan Wangi',
                                  'Ketam Hitam'
                                ]
                                    .map((p) => DropdownMenuItem(
                                        value: p, child: Text(p)))
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedPadi = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GPS Coordinates Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Garis Lintang (Latitude)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: latController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText: '${AppConstants.karawangLatitude}',
                              prefixIcon: Icon(Icons.map_outlined,
                                  color: AppColors.primary),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Garis Bujur (Longitude)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: lonController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText: '${AppConstants.karawangLongitude}',
                              prefixIcon: Icon(Icons.map_outlined,
                                  color: AppColors.primary),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tanggal Tanam
                const Text('Tanggal Tanam',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setModalState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) return;

                    final name = nameController.text;
                    final area = double.tryParse(areaController.text) ?? 1.0;
                    final lat = double.tryParse(latController.text) ??
                        AppConstants.karawangLatitude;
                    final lon = double.tryParse(lonController.text) ??
                        AppConstants.karawangLongitude;

                    final diffDays =
                        DateTime.now().difference(selectedDate).inDays;

                    final newSawah = SawahModel(
                      id: 'sawah-${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'user-001',
                      nama: name,
                      latitude: lat,
                      longitude: lon,
                      luasHektar: area,
                      jenisTanaman: selectedPadi!,
                      tanggalTanam: selectedDate,
                      tanggalPanenExpected:
                          selectedDate.add(const Duration(days: 115)),
                      umurTanamanHari: diffDays,
                      kelembaban: 70.0,
                      ph: 6.5,
                      temperatureCelsius: 29.0,
                      jenisAirTanah: 'Lempung Liat',
                      ketersediaanAir: 'Lancar',
                      status: diffDays >= 90
                          ? 'matang'
                          : diffDays >= 61
                              ? 'generatif'
                              : 'growing',
                      statusKesehatan: 'Sehat',
                      skorRisiko: 5,
                      idLogHama: [],
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    ref.read(sawahStateProvider.notifier).addSawah(newSawah);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Sawah Baru Berhasil Didaftarkan!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Simpan Lahan Sawah',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sawah Detail & Agricultural Calendar Sheet ───────────────────────────
  void _showSawahDetail(BuildContext context, SawahModel sawah) {
    // Stage logic
    int age = sawah.umurTanamanHari;
    String phase = 'Bibit';
    if (age >= 90) {
      phase = 'Panen';
    } else if (age >= 61) {
      phase = 'Generatif';
    } else if (age >= 31) {
      phase = 'Vegetatif';
    } else {
      phase = 'Bibit';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sawah.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Varietas: ${sawah.jenisTanaman} • ${sawah.luasHektar} Ha',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'InterTight'),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(height: 24),

              // Progress Timeline Visual
              const Text(
                'Progress Pertumbuhan Tanaman',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _timelineNode('Bibit', '0-30 Hari',
                      active: age >= 0, isCurrent: age < 31),
                  _timelineConnector(age >= 31),
                  _timelineNode('Vegetatif', '31-60 Hari',
                      active: age >= 31, isCurrent: age >= 31 && age < 61),
                  _timelineConnector(age >= 61),
                  _timelineNode('Generatif', '61-90 Hari',
                      active: age >= 61, isCurrent: age >= 61 && age < 90),
                  _timelineConnector(age >= 90),
                  _timelineNode('Panen', '90+ Hari',
                      active: age >= 90, isCurrent: age >= 90),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.spa_rounded,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Sawah: Fase $phase ($age Hari)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phase == 'Bibit'
                                ? 'Padi baru ditanam. Pastikan debit air macak-macak dan kendalikan hama keong mas.'
                                : phase == 'Vegetatif'
                                    ? 'Batang padi mulai anakan. Berikan pupuk Urea susulan ke-2 untuk stimulasi cabang.'
                                    : phase == 'Generatif'
                                        ? 'Padi mulai bunting dan mengeluarkan malai. Kurangi air, berikan pupuk KCl.'
                                        : 'Bulir padi menguning 90%. Air sawah dikeringkan total untuk mempercepat matang.',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontFamily: 'InterTight'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kalender Pertanian Section
              const Text(
                'Kalender Kegiatan Pertanian',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              _calendarTimelineItem(
                title: 'Jadwal Pemupukan Awal (Pupuk Dasar)',
                desc: 'Aplikasi campuran Urea 50kg & NPK 100kg pada sawah.',
                date: 'Selesai ✓ (Hari Ke-10)',
                color: Colors.green,
                isCompleted: true,
              ),
              _calendarTimelineItem(
                title: 'Jadwal Pemupukan Susulan Ke-2',
                desc:
                    'Pemberian pupuk Urea 75kg untuk pertumbuhan anakan vegetatif maksimal.',
                date: age >= 45
                    ? 'Selesai ✓ (Hari Ke-45)'
                    : 'Direkomendasikan (Hari Ke-45)',
                color: age >= 45 ? Colors.green : Colors.orange,
                isCompleted: age >= 45,
              ),
              _calendarTimelineItem(
                title: 'Jadwal Pemupukan Kalium (KCl)',
                desc:
                    'Aplikasi Kalium Klorida (KCl) 50kg untuk pengisian bulir beras yang padat.',
                date: age >= 75
                    ? 'Selesai ✓ (Hari Ke-75)'
                    : 'Mendatang (Hari Ke-75)',
                color: age >= 75 ? Colors.green : Colors.blue,
                isCompleted: age >= 75,
              ),
              _calendarTimelineItem(
                title: 'Penyemprotan Pestisida Preventif',
                desc:
                    'Penyemprotan fungisida leher malai (anti-blast) & ulat penggerek batang.',
                date: age >= 80
                    ? 'Selesai ✓ (Hari Ke-80)'
                    : 'Mendatang (Hari Ke-80)',
                color: age >= 80 ? Colors.green : Colors.blue,
                isCompleted: age >= 80,
              ),
              _calendarTimelineItem(
                title: 'Estimasi Waktu Panen Raya 🌾',
                desc: 'Prediksi panen berdasarkan varietas padi.',
                date:
                    'Perkiraan Tanggal: ${sawah.tanggalPanenExpected.day}/${sawah.tanggalPanenExpected.month}/${sawah.tanggalPanenExpected.year}',
                color: Colors.purple,
                isCompleted: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineNode(String title, String sub,
      {required bool active, required bool isCurrent}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.orange
                : active
                    ? AppColors.primary
                    : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? Colors.orange.shade100 : Colors.transparent,
              width: 4,
            ),
          ),
          child: Icon(
            active ? Icons.check : Icons.circle_outlined,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight:
                isCurrent || active ? FontWeight.bold : FontWeight.normal,
            color: isCurrent
                ? Colors.orange
                : active
                    ? AppColors.primary
                    : AppColors.textSecondary,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
              fontSize: 8, color: AppColors.textHint, fontFamily: 'InterTight'),
        ),
      ],
    );
  }

  Widget _timelineConnector(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        color: active ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  Widget _calendarTimelineItem({
    required String title,
    required String desc,
    required String date,
    required Color color,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.5), radius: 4),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                    fontFamily: 'InterTight'),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'InterTight',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
