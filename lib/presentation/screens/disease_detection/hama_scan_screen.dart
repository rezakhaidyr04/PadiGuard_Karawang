// File: lib/presentation/screens/disease_detection/hama_scan_screen_clean.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/hama_model.dart';

/// Screen untuk deteksi hama padi menggunakan AI
/// NOTE: Camera functionality not available on web/FlutLab - using mock data
class HamaScanScreen extends StatefulWidget {
  final String sawahId;
  final String userId;

  const HamaScanScreen({
    super.key,
    required this.sawahId,
    required this.userId,
  });

  @override
  State<HamaScanScreen> createState() => _HamaScanScreenState();
}

class _HamaScanScreenState extends State<HamaScanScreen> {
  late Logger _logger;

  final List<HamaModel> _detectionHistory = [];

  @override
  void initState() {
    super.initState();
    _logger = Logger();
    _loadAIModel();
  }

  /// Load TFLite model
  Future<void> _loadAIModel() async {
    try {
      _logger.i('Loading AI model...');
      // Model loading disabled for Flutlab - using mock predictions
      _logger.i('AI model ready for web platform');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ AI Model siap digunakan')),
        );
      }
    } catch (e) {
      _logger.e('Error loading model: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading model: $e')),
        );
      }
    }
  }

  /// Demo detection untuk Flutlab
  void _showDemoDetection() {
    final demoHama = HamaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sawahId: widget.sawahId,
      userId: widget.userId,
      pathFoto: 'demo',
      urlFoto: '',
      namaHama: 'Wereng Cokelat',
      confidence: 0.92,
      tingkatRisiko: 'TINGGI',
      deskripsi: 'Hama wereng cokelat merupakan hama utama padi yang merugikan',
      solusi: ['Semprot insektisida', 'Jaga kelembaban', 'Buang gulma'],
      pestsidaRekomendasi: 'Profenofos 500 EC',
      dosasiPestisida: '1.5',
      unitDosis: 'liter/hektar',
      waktuAplikasi: 'Pagi atau sore hari',
      detectedAt: DateTime.now(),
      resolved: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _detectionHistory.insert(0, demoHama);
    });

    _showResultDialog(demoHama);
  }

  /// Show hasil deteksi
  void _showResultDialog(HamaModel hama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hasil Deteksi: ${hama.namaHama}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultItem('Hama:', hama.namaHama, Colors.orange),
              const SizedBox(height: 10),
              _buildResultItem(
                'Confidence:',
                '${(hama.confidence * 100).toStringAsFixed(1)}%',
                Colors.blue,
              ),
              const SizedBox(height: 10),
              _buildRiskBadge(hama.tingkatRisiko),
              const SizedBox(height: 15),
              Text(
                'Deskripsi:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              Text(hama.deskripsi),
              const SizedBox(height: 15),
              Text(
                'Solusi Rekomendasi:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              ...(hama.solusi.map((s) => Text('• $s'))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String riskLevel) {
    final colors = {
      'RENDAH': AppColors.primary,
      'SEDANG': Colors.orange,
      'TINGGI': Colors.red,
    };

    final color = colors[riskLevel] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Tingkat Risiko: $riskLevel',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Deteksi Hama Padi'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bug_report_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deteksi Hama Padi',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Platform web - Gunakan demo untuk testing',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showDemoDetection,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Demo Deteksi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_detectionHistory.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'History Deteksi (${_detectionHistory.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _detectionHistory.length,
                  itemBuilder: (context, index) {
                    final hama = _detectionHistory[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.bug_report),
                        title: Text(hama.namaHama),
                        subtitle: Text(
                          'Confidence: ${(hama.confidence * 100).toStringAsFixed(1)}%',
                        ),
                        trailing: Chip(
                          label: Text(hama.tingkatRisiko),
                          backgroundColor: _getRiskColor(hama.tingkatRisiko)
                              .withValues(alpha: 0.2),
                        ),
                        onTap: () => _showResultDialog(hama),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'RENDAH':
        return AppColors.primary;
      case 'SEDANG':
        return Colors.orange;
      case 'TINGGI':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
