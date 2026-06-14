import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
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
    extends ConsumerState<DiseaseDetectionScreen> with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _analysisStep = '';
  double _analysisProgress = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _samples = [
    {
      'title': 'Wereng Cokelat',
      'label': 'Wereng Cokelat',
      'risk': 'TINGGI',
      'confidence': 0.94,
      'desc':
          'Serangga wereng cokelat menyerap cairan tanaman padi dari batang, menyebabkan daun mengering (hopperburn).',
      'solusi': [
        'Kurangi kelembaban dengan metode irigasi berselang (intermittent).',
        'Gunakan insektisida Pimetrozin 50% WG (Plenum) dosis 250 g/ha.',
        'Bersihkan gulma di sekeliling tanaman padi.',
      ],
      'pestisida': 'Pimetrozin 50% WG',
      'dosis': '250 g/ha',
      'emoji': '🪲',
      'color': 0xFFC62828,
    },
    {
      'title': 'Blast Fungus',
      'label': 'Blast Fungus (Pyricularia oryzae)',
      'risk': 'TINGGI',
      'confidence': 0.88,
      'desc':
          'Penyakit jamur yang menyerang daun padi menimbulkan bercak belah ketupat dan mematahkan leher malai.',
      'solusi': [
        'Hentikan sementara pemupukan Nitrogen berlebih.',
        'Aplikasikan fungisida Trisiklazol 75% WP dosis 400 g/ha.',
        'Renggangkan jarak tanam dengan sistem Jajar Legowo.',
      ],
      'pestisida': 'Trisiklazol 75% WP',
      'dosis': '400 g/ha',
      'emoji': '🍄',
      'color': 0xFFE65100,
    },
    {
      'title': 'Brown Spot',
      'label': 'Brown Spot (Bercak Cokelat)',
      'risk': 'SEDANG',
      'confidence': 0.76,
      'desc':
          'Bercak bulat cokelat kelabu akibat Helminthosporium oryzae. Sering muncul saat kekurangan kalium.',
      'solusi': [
        'Tingkatkan unsur kalium dengan pupuk KCl.',
        'Semprot fungisida Mankozeb 2 g/liter.',
        'Pastikan tanah mendapat unsur hara mikro berimbang.',
      ],
      'pestisida': 'Mancozeb 80% WP',
      'dosis': '1.5 kg/ha',
      'emoji': '🟤',
      'color': 0xFFF57F17,
    },
    {
      'title': 'Daun Padi Sehat',
      'label': 'Healthy (Padi Sehat)',
      'risk': 'RENDAH',
      'confidence': 0.97,
      'desc':
          'Daun padi hijau segar dan tidak ada gejala bercak jamur maupun gigitan serangga.',
      'solusi': [
        'Pertahankan sistem irigasi berselang.',
        'Pantau secara berkala seminggu 2 kali.',
      ],
      'pestisida': 'N/A',
      'dosis': '0',
      'emoji': '✅',
      'color': 0xFF388E3C,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sawahList = ref.watch(sawahStateProvider);
    final scanHistory = ref.watch(hamaStateProvider);
    final selectedSawahId = ref.watch(selectedSawahIdProvider);

    int totalScans = scanHistory.length;
    int highRisk = scanHistory.where((h) => h.tingkatRisiko == 'TINGGI').length;
    int medRisk = scanHistory.where((h) => h.tingkatRisiko == 'SEDANG').length;
    int healthy = scanHistory.where((h) => h.namaHama.contains('Healthy')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deteksi Hama AI 🔬',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ambil foto daun untuk diagnosa instan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stats badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.document_scanner_rounded,
                              color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text('$totalScans Scan',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Sawah Selector ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _SawahSelector(
                  sawahList: sawahList,
                  selectedId: selectedSawahId,
                  ref: ref,
                ),
              ),
            ),

            // ─── Scanner UI ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _isAnalyzing
                    ? _buildAnalyzingCard()
                    : _buildScannerCard(context, sawahList, selectedSawahId),
              ),
            ),

            // ─── Stats ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistik Diagnosa',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatBadge('$totalScans', 'Total Scan', Colors.blue),
                        const SizedBox(width: 8),
                        _StatBadge(
                            '$highRisk', 'Risiko Tinggi', AppColors.error),
                        const SizedBox(width: 8),
                        _StatBadge('$medRisk', 'Risiko Sedang', AppColors.warning),
                        const SizedBox(width: 8),
                        _StatBadge('$healthy', 'Sehat', AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Scan History ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 6),
                child: const Text('Riwayat Scan Penyakit',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins')),
              ),
            ),

            if (scanHistory.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Text('🌿', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('Belum ada riwayat diagnosa.',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter')),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _HistoryCard(
                      scan: scanHistory[i],
                      sawahList: sawahList,
                      onTap: () => _showDiagnosisResult(scanHistory[i]),
                    ),
                    childCount: scanHistory.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Analyzing Card ────────────────────────────────────────────────────────
  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.lushGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🔬', style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _analysisStep.isEmpty ? 'Memulai analisis...' : _analysisStep,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _analysisProgress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceGreen,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_analysisProgress * 100).toStringAsFixed(0)}% selesai',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  // ─── Scanner Card ──────────────────────────────────────────────────────────
  Widget _buildScannerCard(
    BuildContext context,
    List<SawahModel> sawahList,
    String? selectedSawahId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AI scanner visual
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CustomPaint(
                  size: const Size(80, 80),
                  painter: _ScanFramePainter(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deteksi Penyakit Daun AI',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Foto daun padi untuk mendapatkan\ndiagnosa dan rekomendasi AI secara instan.',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Camera / Gallery buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.camera, sawahList, selectedSawahId),
                  icon: const Text('📷', style: TextStyle(fontSize: 18)),
                  label: const Text('Kamera',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(
                      ImageSource.gallery, sawahList, selectedSawahId),
                  icon: const Text('🖼️', style: TextStyle(fontSize: 18)),
                  label: const Text('Galeri',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Disease chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _samples.map((s) {
              final color = Color(s['color'] as int);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s['emoji'] as String,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(s['title'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter')),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Pick Image & Scan ─────────────────────────────────────────────────────
  Future<void> _pickImage(
    ImageSource source,
    List<SawahModel> sawahList,
    String? selectedSawahId,
  ) async {
    if (sawahList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Daftarkan sawah terlebih dahulu!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final targetId = selectedSawahId ?? sawahList.first.id;
    final picker = ImagePicker();
    try {
      final XFile? img = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (img != null) {
        final copy = List<Map<String, dynamic>>.from(_samples)..shuffle();
        _runScanSimulation(copy.first, targetId);
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

  void _runScanSimulation(Map<String, dynamic> sample, String targetId) async {
    setState(() {
      _isAnalyzing = true;
      _analysisStep = '🔍 Membaca gambar daun padi...';
      _analysisProgress = 0.15;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _analysisStep = '🧪 Ekstraksi fitur warna RGB + tekstur...';
      _analysisProgress = 0.45;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _analysisStep = '🤖 Evaluasi model TFLite + CNN...';
      _analysisProgress = 0.8;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _analysisStep = '✅ Hasil diagnosa tersedia!';
      _analysisProgress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final hamaId = 'hama-${DateTime.now().millisecondsSinceEpoch}';
    final isHealthy = sample['title'].toString().contains('Sehat');

    final newHama = HamaModel(
      id: hamaId,
      sawahId: targetId,
      userId: 'user-001',
      pathFoto: isHealthy ? 'healthy_rice.jpg' : 'diseased_rice.jpg',
      urlFoto: '',
      namaHama: sample['label'] as String,
      confidence: sample['confidence'] as double,
      tingkatRisiko: sample['risk'] as String,
      deskripsi: sample['desc'] as String,
      solusi: List<String>.from(sample['solusi'] as List),
      pestsidaRekomendasi: sample['pestisida'] as String,
      dosasiPestisida: sample['dosis'] as String,
      unitDosis: isHealthy ? 'N/A' : 'g/ha',
      waktuAplikasi: isHealthy ? 'N/A' : 'Pagi/Sore hari',
      detectedAt: DateTime.now(),
      resolved: isHealthy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(hamaStateProvider.notifier).addScan(newHama);
    ref
        .read(sawahStateProvider.notifier)
        .reportPest(targetId, hamaId, sample['risk'] as String);

    _showDiagnosisResult(newHama);
  }

  void _showDiagnosisResult(HamaModel hama) {
    Color riskColor = AppColors.success;
    String riskEmoji = '✅';
    if (hama.tingkatRisiko == 'TINGGI') {
      riskColor = AppColors.error;
      riskEmoji = '🚨';
    } else if (hama.tingkatRisiko == 'SEDANG') {
      riskColor = AppColors.warning;
      riskEmoji = '⚠️';
    }

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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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

              // Result header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: riskColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(riskEmoji, style: const TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    Text(
                      hama.namaHama,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                          fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Risiko: ${hama.tingkatRisiko}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Akurasi AI: ${(hama.confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _sectionCard(
                title: '📋 Deskripsi',
                child: Text(hama.deskripsi,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontFamily: 'Inter')),
              ),
              const SizedBox(height: 14),

              // Solutions
              _sectionCard(
                title: '💊 Langkah Penanganan',
                child: Column(
                  children: hama.solusi
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${e.key + 1}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                            fontFamily: 'Inter'))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              if (hama.pestsidaRekomendasi != 'N/A') ...[
                const SizedBox(height: 14),
                _sectionCard(
                  title: '🧴 Rekomendasi Pestisida',
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hama.pestsidaRekomendasi,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Poppins')),
                            const SizedBox(height: 4),
                            Text('Dosis: ${hama.dosasiPestisida}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('⏰ Pagi/Sore',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Selesai',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionCard(
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Sawah Selector Widget ────────────────────────────────────────────────────
class _SawahSelector extends StatelessWidget {
  final List<SawahModel> sawahList;
  final String? selectedId;
  final WidgetRef ref;

  const _SawahSelector(
      {required this.sawahList, required this.selectedId, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🌾', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sawah Target Diagnosa',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter')),
                if (sawahList.isEmpty)
                  const Text('Belum ada sawah terdaftar',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textHint))
                else
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedId ?? sawahList.first.id,
                      isDense: true,
                      items: sawahList.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.nama.length > 22
                                ? '${s.nama.substring(0, 20)}...'
                                : s.nama,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Poppins'),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          ref.read(selectedSawahIdProvider.notifier).state = v,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => SawahScreen.showAddSawahDialog(context, ref),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Badge ────────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBadge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter'),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── History Card ──────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HamaModel scan;
  final List<SawahModel> sawahList;
  final VoidCallback onTap;

  const _HistoryCard(
      {required this.scan, required this.sawahList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color riskColor = AppColors.success;
    String riskEmoji = '✅';
    if (scan.tingkatRisiko == 'TINGGI') {
      riskColor = AppColors.error;
      riskEmoji = '🚨';
    } else if (scan.tingkatRisiko == 'SEDANG') {
      riskColor = AppColors.warning;
      riskEmoji = '⚠️';
    }

    final sawah = sawahList.firstWhere(
      (s) => s.id == scan.sawahId,
      orElse: () => SawahModel.empty(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: riskColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(riskEmoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.namaHama,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(
                        sawah.nama.isEmpty ? 'Sawah Karawang' : sawah.nama,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${scan.detectedAt.day}/${scan.detectedAt.month}/${scan.detectedAt.year} · Akurasi: ${(scan.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(scan.tingkatRisiko,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: riskColor)),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scan Frame Painter ───────────────────────────────────────────────────────
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final len = size.width * 0.28;
    final r = size.width / 2;

    // Top-left
    canvas.drawLine(Offset(r - r * 0.7, r - r * 0.7),
        Offset(r - r * 0.7 + len, r - r * 0.7), paint);
    canvas.drawLine(Offset(r - r * 0.7, r - r * 0.7),
        Offset(r - r * 0.7, r - r * 0.7 + len), paint);
    // Top-right
    canvas.drawLine(Offset(r + r * 0.7, r - r * 0.7),
        Offset(r + r * 0.7 - len, r - r * 0.7), paint);
    canvas.drawLine(Offset(r + r * 0.7, r - r * 0.7),
        Offset(r + r * 0.7, r - r * 0.7 + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(r - r * 0.7, r + r * 0.7),
        Offset(r - r * 0.7 + len, r + r * 0.7), paint);
    canvas.drawLine(Offset(r - r * 0.7, r + r * 0.7),
        Offset(r - r * 0.7, r + r * 0.7 - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(r + r * 0.7, r + r * 0.7),
        Offset(r + r * 0.7 - len, r + r * 0.7), paint);
    canvas.drawLine(Offset(r + r * 0.7, r + r * 0.7),
        Offset(r + r * 0.7, r + r * 0.7 - len), paint);

    // Center scan line (animated look)
    final scanPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(r - r * 0.65, r), Offset(r + r * 0.65, r), scanPaint);

    // Leaf icon
    final leafPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(r, r), 14, leafPaint);

    final tp = TextPainter(
      text: const TextSpan(text: '🌿', style: TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(r - 10, r - 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
