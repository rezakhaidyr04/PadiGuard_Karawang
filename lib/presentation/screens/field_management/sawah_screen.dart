// File: lib/presentation/screens/field_management/sawah_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

class SawahScreen extends ConsumerWidget {
  const SawahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);
    final now = DateTime.now();

    // Jika provider kosong (mis. belum ada data), tampilkan demo agar tab Sawah tidak blank.
    final effectiveSawahList = sawahList.isEmpty
        ? [
            SawahModel(
              id: 'sawah-demo-1',
              userId: 'demo-user',
              nama: 'Sawah Demo - Telukjambe',
              latitude: -6.3245,
              longitude: 107.3025,
              luasHektar: 2.5,
              jenisTanaman: 'Ciherang',
              tanggalTanam: now.subtract(const Duration(days: 45)),
              tanggalPanenExpected: now.add(const Duration(days: 75)),
              umurTanamanHari: 45,
              kelembaban: 78.0,
              ph: 6.5,
              temperatureCelsius: 29.5,
              jenisAirTanah: 'Lempung Liat',
              ketersediaanAir: 'Lancar',
              status: 'growing',
              statusKesehatan: 'Sehat',
              skorRisiko: 12,
              idLogHama: const [],
              createdAt: now.subtract(const Duration(days: 45)),
              updatedAt: now,
            ),
            SawahModel(
              id: 'sawah-demo-2',
              userId: 'demo-user',
              nama: 'Sawah Demo - Tempuran',
              latitude: -6.1824,
              longitude: 107.4255,
              luasHektar: 1.8,
              jenisTanaman: 'Inpari 32',
              tanggalTanam: now.subtract(const Duration(days: 75)),
              tanggalPanenExpected: now.add(const Duration(days: 45)),
              umurTanamanHari: 75,
              kelembaban: 65.0,
              ph: 6.1,
              temperatureCelsius: 30.2,
              jenisAirTanah: 'Lempung Berpasir',
              ketersediaanAir: 'Kurang',
              status: 'growing',
              statusKesehatan: 'Risiko',
              skorRisiko: 35,
              idLogHama: const ['hama-1'],
              createdAt: now.subtract(const Duration(days: 75)),
              updatedAt: now,
            ),
          ]
        : sawahList;

    double totalArea = 0.0;
    int healthyCount = 0;
    int riskCount = 0;
    int sickCount = 0;

    for (final s in effectiveSawahList) {
      totalArea += s.luasHektar;
      if (s.statusKesehatan == 'Sehat') {
        healthyCount++;
      } else if (s.statusKesehatan == 'Risiko') {
        riskCount++;
      } else if (s.statusKesehatan == 'Sakit') {
        sickCount++;
      }
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
                            fontFamily: 'InterTight',
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSawahDialog(context, ref),
                      icon:
                          const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
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
                              '${effectiveSawahList.length} Sawah Aktif',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pantau kesehatan tanaman dan kelola lahan pertanian Anda',
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
                      child: _summaryCard(
                        '${effectiveSawahList.length}',
                        'Total Lahan',
                        Icons.agriculture_rounded,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 26,
                      child: _summaryCard(
                        '${totalArea.toStringAsFixed(1)} Ha',
                        'Total Luas',
                        Icons.straighten_rounded,
                        Colors.blue,
                      ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: effectiveSawahList.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum ada lahan terdaftar.',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            const Text(
                              'Tekan tombol di bawah untuk menambah sawah demo atau tekan "Tambah".',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textHint),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Tambah demo sawah ke provider
                                final now = DateTime.now();
                                final demo = SawahModel(
                                  id: 'sawah-demo-${now.millisecondsSinceEpoch}',
                                  userId: 'demo-user',
                                  nama: 'Sawah Demo Tambahan',
                                  latitude: AppConstants.karawangLatitude,
                                  longitude: AppConstants.karawangLongitude,
                                  luasHektar: 1.2,
                                  jenisTanaman: 'Ciherang',
                                  tanggalTanam:
                                      now.subtract(const Duration(days: 30)),
                                  tanggalPanenExpected:
                                      now.add(const Duration(days: 85)),
                                  umurTanamanHari: 30,
                                  kelembaban: 72.0,
                                  ph: 6.4,
                                  temperatureCelsius: 29.0,
                                  jenisAirTanah: 'Lempung',
                                  ketersediaanAir: 'Lancar',
                                  status: 'growing',
                                  statusKesehatan: 'Sehat',
                                  skorRisiko: 8,
                                  idLogHama: const [],
                                  createdAt: now,
                                  updatedAt: now,
                                );

                                ref
                                    .read(sawahStateProvider.notifier)
                                    .addSawah(demo);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Sawah Demo'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                            )
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSawahCard(
                          context,
                          effectiveSawahList[index],
                          ref,
                        ),
                        childCount: effectiveSawahList.length,
                      ),
                    ),
            ),
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
          ),
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

  Color _healthColor(String status) {
    if (status == 'Sakit') return AppColors.error;
    if (status == 'Risiko') return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildSawahCard(
      BuildContext context, SawahModel sawah, WidgetRef ref) {
    final healthColor = _healthColor(sawah.statusKesehatan);

    String phaseLabel = 'Tunas';
    if (sawah.umurTanamanHari >= 90) {
      phaseLabel = 'Siap Panen';
    } else if (sawah.umurTanamanHari >= 61) {
      phaseLabel = 'Generatif';
    } else if (sawah.umurTanamanHari >= 31) {
      phaseLabel = 'Vegetatif';
    }

    final hariTersisa =
        sawah.tanggalPanenExpected.difference(DateTime.now()).inDays;

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
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              fontFamily: 'InterTight',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: healthColor.withValues(alpha: 0.3), width: 1),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _infoChip(Icons.straighten_rounded,
                        '${sawah.luasHektar} Ha', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(
                    child: _infoChip(Icons.grass_rounded, sawah.jenisTanaman,
                        AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(
                    child: _infoChip(Icons.calendar_month_rounded,
                        '${sawah.umurTanamanHari} HST', Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            _progressBar('Fase Pertumbuhan: $phaseLabel', sawah.umurTanamanHari,
                120, AppColors.primary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
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
                        const Text(
                          'Estimasi Panen',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                            fontFamily: 'InterTight',
                          ),
                        ),
                        Text(
                          hariTersisa > 0
                              ? '$hariTersisa hari lagi'
                              : 'Siap panen',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontFamily: 'Poppins',
                          ),
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
                      ref.read(currentTabProvider.notifier).state = 2;
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
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
    final progress = (value / maxVal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamily: 'InterTight'),
            ),
            Text(
              '$value/$maxVal Hari',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'InterTight'),
            ),
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
                          fontFamily: 'Poppins'),
                    ),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
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
                                onChanged: (val) =>
                                    setModalState(() => selectedPadi = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: latController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText:
                                  'Contoh: ${AppConstants.karawangLatitude}',
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
                          const Text('Longitude',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: lonController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              hintText:
                                  'Contoh: ${AppConstants.karawangLongitude}',
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
                      setModalState(() => selectedDate = date);
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                        idLogHama: const [],
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSawahDetail(BuildContext context, SawahModel sawah) {
    final age = sawah.umurTanamanHari;
    final phase = age >= 90
        ? 'Panen'
        : age >= 61
            ? 'Generatif'
            : age >= 31
                ? 'Vegetatif'
                : 'Bibit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sawah.nama,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Varietas: ${sawah.jenisTanaman} • ${sawah.luasHektar} Ha',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'InterTight'),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Sawah: Fase $phase ($age Hari)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelembaban: ${sawah.kelembaban.toStringAsFixed(0)}% • pH: ${sawah.ph.toStringAsFixed(1)} • Suhu: ${sawah.temperatureCelsius.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'InterTight',
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kalender Kegiatan Pertanian',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
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
                color: isCompleted ? AppColors.primary : Colors.white,
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
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
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
                    fontFamily: 'Poppins'),
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
                    fontFamily: 'InterTight'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
