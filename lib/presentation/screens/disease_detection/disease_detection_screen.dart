// File: lib/presentation/screens/disease_detection/disease_detection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/hama_model.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';
import '../field_management/sawah_screen.dart';

class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  ConsumerState<DiseaseDetectionScreen> createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState
    extends ConsumerState<DiseaseDetectionScreen> {
  bool _isAnalyzing = false;
  String _analysisStep = '';
  double _analysisProgress = 0.0;

  // Mock list of disease sample cards for simulation
  final List<Map<String, dynamic>> _samples = [
    {
      'title': 'Wereng Cokelat',
      'label': 'Wereng Cokelat',
      'risk': 'TINGGI',
      'confidence': 0.94,
      'desc': 'Batang padi kering akibat serangan hama wereng cokelat.',
      'solusi': [
        'Semprot insektisida Plenum (Pimetrozin) 2g/liter.',
        'Kurangi pemakaian air (sawah intermittent).',
        'Kendalikan populasi gulma di parit sawah.',
      ],
      'pestisida': 'Pimetrozin 50% WG',
      'dosis': '250 g/ha',
    },
    {
      'title': 'Blast Fungus',
      'label': 'Blast Fungus (Jamur)',
      'risk': 'TINGGI',
      'confidence': 0.88,
      'desc':
          'Bercak daun berbentuk belah ketupat khas serangan jamur Pyricularia oryzae.',
      'solusi': [
        'Gunakan fungisida Trisiklazol 1g/liter air.',
        'Hentikan sementara pemupukan Nitrogen (Urea).',
        'Gunakan jarak tanam legowo agar udara lancar.',
      ],
      'pestisida': 'Trisiklazol 75% WP',
      'dosis': '400 g/ha',
    },
    {
      'title': 'Brown Spot',
      'label': 'Brown Spot (Bercak Cokelat)',
      'risk': 'SEDANG',
      'confidence': 0.76,
      'desc':
          'Bercak bulat cokelat kelabu pada permukaan daun padi akibat Helminthosporium oryzae.',
      'solusi': [
        'Tingkatkan ketersediaan unsur kalium (pupuk KCl).',
        'Semprot fungisida Mankozeb 2g/liter air.',
        'Pastikan tanah mendapat unsur hara mikro berimbang.',
      ],
      'pestisida': 'Mancozeb 80% WP',
      'dosis': '1.5 kg/ha',
    },
    {
      'title': 'Daun Padi Sehat',
      'label': 'Healthy (Padi Sehat)',
      'risk': 'RENDAH',
      'confidence': 0.97,
      'desc':
          'Daun padi hijau segar dan tidak ada gejala bercak jamur maupun gigitan serangga.',
      'solusi': [
        'Pertahankan kondisi irigasi berselang.',
        'Pantau secara berkala seminggu 2 kali.',
      ],
      'pestisida': 'N/A',
      'dosis': '0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sawahList = ref.watch(sawahStateProvider);
    final scanHistory = ref.watch(hamaStateProvider);
    final selectedSawahId = ref.watch(selectedSawahIdProvider);

    // Calculate statistics
    int totalScans = scanHistory.length;
    int highRiskCount =
        scanHistory.where((h) => h.tingkatRisiko == 'TINGGI').length;
    int mediumRiskCount =
        scanHistory.where((h) => h.tingkatRisiko == 'SEDANG').length;
    int healthyCount =
        scanHistory.where((h) => h.namaHama.contains('Healthy')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Deteksi Hama AI 🤖',
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
            // Target Sawah selector
            Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.agriculture_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sawah Target Diagnosa',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                        Text('Pilih sawah sebelum melakukan scan daun.',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSawahId ??
                            (sawahList.isNotEmpty ? sawahList.first.id : null),
                        items: sawahList.map((sawah) {
                          return DropdownMenuItem(
                            value: sawah.id,
                            child: Text(
                              sawah.nama.length > 18
                                  ? '${sawah.nama.substring(0, 16)}...'
                                  : sawah.nama,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          ref.read(selectedSawahIdProvider.notifier).state =
                              val;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => SawahScreen.showAddSawahDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // AI Scanner Simulator Section
            if (_isAnalyzing)
              _buildAIAnalyzingCard()
            else
              _buildImagePickerOptions(context, sawahList, selectedSawahId),

            const SizedBox(height: 24),

            // AI Diagnostics Stats
            const Text(
              'Statistik Diagnosa Penyakit',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statsBadge('Total Scan', '$totalScans', Colors.blue),
                const SizedBox(width: 8),
                _statsBadge('Risiko Tinggi', '$highRiskCount', Colors.red),
                const SizedBox(width: 8),
                _statsBadge('Risiko Sedang', '$mediumRiskCount', Colors.orange),
                const SizedBox(width: 8),
                _statsBadge(
                    'Tanaman Sehat', '$healthyCount', AppColors.primary),
              ],
            ),
            const SizedBox(height: 24),

            // Scan History List
            const Text(
              'Riwayat Scan Penyakit',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            _buildDetectionHistory(context, scanHistory, sawahList),
          ],
        ),
      ),
    );
  }

  Widget _statsBadge(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterTight'),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalyzingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child:
                  Icon(Icons.sync_rounded, color: AppColors.primary, size: 34),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _analysisStep.isEmpty ? 'Menyiapkan analisis AI...' : _analysisStep,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: _analysisProgress,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_analysisProgress * 100).toStringAsFixed(0)}% Selesai',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'InterTight'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerOptions(
    BuildContext context,
    List<dynamic> sawahList,
    String? selectedSawahId,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1), width: 1),
            ),
            child: const Column(
              children: [
                Icon(Icons.center_focus_strong_rounded,
                    color: AppColors.primary, size: 56),
                SizedBox(height: 12),
                Text(
                  'Deteksi Penyakit Daun Padi AI',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih dari galeri contoh daun padi di bawah untuk mensimulasikan pemindaian AI.',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontFamily: 'InterTight'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Camer / Gallery buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(
                      ImageSource.camera, sawahList, selectedSawahId),
                  icon: const Icon(Icons.camera_alt_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('Buka Kamera',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(
                      ImageSource.gallery, sawahList, selectedSawahId),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Buka Galeri',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    List<dynamic> sawahList,
    String? selectedSawahId,
  ) async {
    if (sawahList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Mohon daftarkan sawah terlebih dahulu sebelum melakukan diagnosa!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final targetSawahId = selectedSawahId ?? sawahList.first.id;
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Randomly pick a disease from _samples to simulate AI diagnostic result
        final samplesCopy = List<Map<String, dynamic>>.from(_samples);
        samplesCopy.shuffle();
        final randomSample = samplesCopy.first;
        _startAIScanSimulation(randomSample, targetSawahId);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka kamera/galeri: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // _simulateScanPicker removed (unused)

  void _startAIScanSimulation(
      Map<String, dynamic> sample, String targetSawahId) async {
    setState(() {
      _isAnalyzing = true;
      _analysisStep = 'Membaca gambar daun padi...';
      _analysisProgress = 0.1;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _analysisStep = 'Ekstraksi fitur pola warna daun (RGB)...';
      _analysisProgress = 0.45;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _analysisStep = 'Mengevaluasi dengan model TFLite...';
      _analysisProgress = 0.8;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _analysisStep = 'Selesai! Menghasilkan rekomendasi...';
      _analysisProgress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
    });

    // Save scan to state
    final String hamaId = 'hama-${DateTime.now().millisecondsSinceEpoch}';
    final isHealthy = sample['title'].toString().contains('Sehat');

    final newHama = HamaModel(
      id: hamaId,
      sawahId: targetSawahId,
      userId: 'user-001',
      pathFoto: isHealthy ? 'healthy_rice.jpg' : 'diseased_rice.jpg',
      urlFoto: '',
      namaHama: sample['label'],
      confidence: sample['confidence'],
      tingkatRisiko: sample['risk'],
      deskripsi: sample['desc'],
      solusi: List<String>.from(sample['solusi']),
      pestsidaRekomendasi: sample['pestisida'],
      dosasiPestisida: sample['dosis'],
      unitDosis: isHealthy ? 'N/A' : 'g/ha',
      waktuAplikasi: isHealthy ? 'N/A' : 'Pagi/Sore hari',
      detectedAt: DateTime.now(),
      resolved: isHealthy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save scan logs
    ref.read(hamaStateProvider.notifier).addScan(newHama);

    // Report pest/disease to target Sawah
    ref
        .read(sawahStateProvider.notifier)
        .reportPest(targetSawahId, hamaId, sample['risk']);

    // Show Diagnosis Result Dialog
    _showDiagnosisResultDialog(newHama);
  }

  void _showDiagnosisResultDialog(HamaModel hama) {
    Color riskColor = AppColors.primary;
    if (hama.tingkatRisiko == 'TINGGI') {
      riskColor = Colors.red;
    } else if (hama.tingkatRisiko == 'SEDANG') {
      riskColor = Colors.orange;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              hama.namaHama.contains('Healthy')
                  ? 'Tanaman Sehat!'
                  : 'Hama Terdeteksi!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: riskColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hama.namaHama,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: riskColor,
                            fontFamily: 'Poppins'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          hama.tingkatRisiko,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tingkat Keyakinan AI:',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text('${(hama.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(hama.deskripsi,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
            if (hama.pestsidaRekomendasi != 'N/A') ...[
              const SizedBox(height: 12),
              const Text('Rekomendasi Pestisida:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(hama.pestsidaRekomendasi,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text('Dosis: ${hama.dosasiPestisida}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text('Langkah Solusi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ...hama.solusi.map((sol) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text(sol,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.3))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  Widget _buildDetectionHistory(
    BuildContext context,
    List<HamaModel> scans,
    List<SawahModel> sawahs,
  ) {
    if (scans.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text('Belum ada riwayat diagnosa AI.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scan = scans[index];
        Color riskColor = AppColors.primary;
        if (scan.tingkatRisiko == 'TINGGI') {
          riskColor = Colors.red;
        } else if (scan.tingkatRisiko == 'SEDANG') {
          riskColor = Colors.orange;
        }

        final targetSawah = sawahs.firstWhere(
          (s) => s.id == scan.sawahId,
          orElse: () => SawahModel(
            id: '',
            userId: '',
            nama: 'Sawah Karawang',
            latitude: 0,
            longitude: 0,
            luasHektar: 0,
            jenisTanaman: '',
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

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => _showDiagnosisResultDialog(scan),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bug_report_rounded,
                        color: riskColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.namaHama,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Lahan: ${targetSawah.nama}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontFamily: 'InterTight'),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${scan.detectedAt.day}/${scan.detectedAt.month}/${scan.detectedAt.year} • Akurasi: ${(scan.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                              fontFamily: 'InterTight'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scan.tingkatRisiko,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InterTight',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
