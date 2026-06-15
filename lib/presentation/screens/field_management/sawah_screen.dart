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
      } else {
        sickCount++;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manajemen Sawah 🌾',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins',
                            )),
                        SizedBox(height: 2),
                        Text('Kelola semua lahan pertanian Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            )),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showAddSawahDialog(context, ref),
                      icon: const Icon(Icons.add_rounded,
                          size: 18, color: Colors.white),
                      label: const Text('Tambah',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Summary Banner ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.lushGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL LAHAN AKTIF',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 4),
                            Text(
                              '${effectiveSawahList.length} Sawah · ${totalArea.toStringAsFixed(1)} Ha',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _statusPill('✅ $healthyCount Sehat',
                                    AppColors.success),
                                const SizedBox(width: 8),
                                if (riskCount > 0)
                                  _statusPill(
                                      '⚠️ $riskCount Risiko', AppColors.warning),
                                if (sickCount > 0) ...[
                                  const SizedBox(width: 8),
                                  _statusPill(
                                      '🚨 $sickCount Sakit', AppColors.error),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Text('🗺️', style: TextStyle(fontSize: 52)),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Sawah List Title ───────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Daftar Lahan Sawah',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins')),
              ),
            ),

            // ─── Sawah Cards ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) =>
                      _SawahCard(sawah: effectiveSawahList[i], ref: ref),
                  childCount: effectiveSawahList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  // ─── Add Sawah Dialog ───────────────────────────────────────────────────────
  static void showAddSawahDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    String? selectedPadi = 'Ciherang';
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daftarkan Sawah Baru 🌾',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins')),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Nama Lahan Sawah'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Sawah Utama Blok C',
                      prefixIcon:
                          Icon(Icons.agriculture_rounded, color: AppColors.primary),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Luas (Ha)'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: areaController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                hintText: '1.5',
                                prefixIcon: Icon(Icons.straighten_rounded,
                                    color: AppColors.primary),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Wajib isi';
                                final p = double.tryParse(v);
                                if (p == null || p <= 0) return 'Harus > 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Jenis Padi'),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14),
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
                                    'Ketan Hitam'
                                  ]
                                      .map((p) => DropdownMenuItem(
                                          value: p, child: Text(p)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setModal(() => selectedPadi = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Tanggal Tanam'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) setModal(() => selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final diffDays =
                            DateTime.now().difference(selectedDate).inDays;
                        final newSawah = SawahModel(
                          id: 'sawah-${DateTime.now().millisecondsSinceEpoch}',
                          userId: 'user-001',
                          nama: nameController.text.trim(),
                          latitude: AppConstants.karawangLatitude,
                          longitude: AppConstants.karawangLongitude,
                          luasHektar:
                              double.parse(areaController.text),
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
                          status: 'growing',
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
                            content: Text('✅ Sawah baru berhasil didaftarkan!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded,
                          color: Colors.white, size: 18),
                      label: const Text('Simpan Lahan Sawah',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _fieldLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary));
  }
}

// ─── Sawah Card ───────────────────────────────────────────────────────────────
class _SawahCard extends StatelessWidget {
  final SawahModel sawah;
  final WidgetRef ref;

  const _SawahCard({required this.sawah, required this.ref});

  @override
  Widget build(BuildContext context) {
    Color healthColor = AppColors.success;
    String healthEmoji = '✅';
    if (sawah.statusKesehatan == 'Sakit') {
      healthColor = AppColors.error;
      healthEmoji = '🚨';
    } else if (sawah.statusKesehatan == 'Risiko') {
      healthColor = AppColors.warning;
      healthEmoji = '⚠️';
    }

    final phase = _getPhase(sawah.umurTanamanHari);
    final phaseEmoji = _getPhaseEmoji(sawah.umurTanamanHari);
    final daysLeft =
        sawah.tanggalPanenExpected.difference(DateTime.now()).inDays;
    final progress = (sawah.umurTanamanHari / 115).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header with gradient top
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: healthColor.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border:
                  const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sawah.nama,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(phaseEmoji,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Fase $phase · ${sawah.umurTanamanHari} HST',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter'),
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
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: healthColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    '$healthEmoji ${sawah.statusKesehatan}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: healthColor),
                  ),
                ),
              ],
            ),
          ),

          // Info grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoBlock(Icons.straighten_rounded,
                        '${sawah.luasHektar} Ha', 'Luas Lahan', Colors.blue),
                    _infoBlock(Icons.grass_rounded, sawah.jenisTanaman,
                        'Jenis Padi', AppColors.primary),
                    _infoBlock(Icons.water_drop_rounded,
                        '${sawah.kelembaban.toStringAsFixed(0)}%',
                        'Kelembaban', Colors.cyan.shade700),
                    _infoBlock(
                        Icons.science_rounded,
                        sawah.ph.toStringAsFixed(1),
                        'pH Tanah',
                        Colors.purple.shade500),
                  ],
                ),
                const SizedBox(height: 14),

                // Growth progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres Pertumbuhan: Fase $phase',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter'),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.85
                              ? AppColors.accent
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Harvest countdown
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: daysLeft <= 14
                        ? AppColors.accent.withValues(alpha: 0.08)
                        : AppColors.surfaceGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: daysLeft <= 14
                          ? AppColors.accent.withValues(alpha: 0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        daysLeft <= 14 ? '🌾' : '📅',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimasi Panen',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Inter')),
                            Text(
                              daysLeft > 0 ? '$daysLeft hari lagi' : '🎉 Siap Panen!',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: daysLeft <= 14
                                      ? AppColors.accent
                                      : AppColors.primary,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${sawah.tanggalPanenExpected.day}/${sawah.tanggalPanenExpected.month}/${sawah.tanggalPanenExpected.year}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: daysLeft <= 14
                                ? AppColors.accent
                                : AppColors.primary,
                            fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSawahDetail(context, sawah),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Detail',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(selectedSawahIdProvider.notifier).state =
                          sawah.id;
                      ref.read(currentTabProvider.notifier).state = 2;
                    },
                    icon: const Icon(Icons.document_scanner_rounded,
                        size: 16, color: Colors.white),
                    label: const Text('Scan Hama',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoBlock(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Poppins'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textHint,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  String _getPhase(int hst) {
    if (hst >= 90) return 'Panen';
    if (hst >= 61) return 'Generatif';
    if (hst >= 31) return 'Vegetatif';
    return 'Bibit';
  }

  String _getPhaseEmoji(int hst) {
    if (hst >= 90) return '🌾';
    if (hst >= 61) return '🌻';
    if (hst >= 31) return '🌿';
    return '🌱';
  }

  static void _showSawahDetail(BuildContext context, SawahModel sawah) {
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
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(sawah.nama,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              Text('${sawah.jenisTanaman} · ${sawah.luasHektar} Ha',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),

              // Detail rows
              _detailSection('Kondisi Lahan Saat Ini', [
                _DetailRow('Fase', 'Fase $phase ($age Hari Setelah Tanam)'),
                _DetailRow('Status Kesehatan', sawah.statusKesehatan),
                _DetailRow('Skor Risiko', '${sawah.skorRisiko}% risiko gagal panen'),
                _DetailRow('Kelembaban Tanah', '${sawah.kelembaban.toStringAsFixed(0)}%'),
                _DetailRow('pH Keasaman', sawah.ph.toStringAsFixed(1)),
                _DetailRow('Suhu', '${sawah.temperatureCelsius.toStringAsFixed(0)}°C'),
                _DetailRow('Jenis Air Tanah', sawah.jenisAirTanah),
                _DetailRow('Ketersediaan Air', sawah.ketersediaanAir),
              ]),
              const SizedBox(height: 20),

              _detailSection('Jadwal Pertanian', [
                _DetailRow('Tanggal Tanam',
                    '${sawah.tanggalTanam.day}/${sawah.tanggalTanam.month}/${sawah.tanggalTanam.year}'),
                _DetailRow('Estimasi Panen',
                    '${sawah.tanggalPanenExpected.day}/${sawah.tanggalPanenExpected.month}/${sawah.tanggalPanenExpected.year}'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _detailSection(
      String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins')),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
