// File: lib/presentation/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
// constants not required here
import '../field_management/sawah_screen.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../market/market_screen.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeTab(),
      const SawahScreen(),
      const DiseaseDetectionScreen(),
      const ChatbotScreen(),
      const MarketScreen(),
    ];
  }

  void navigateToTab(int index) {
    ref.read(currentTabProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(currentTabProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded,
                    Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.agriculture_rounded,
                    Icons.agriculture_outlined, 'Sawah'),
                _buildNavItem(2, Icons.bug_report_rounded,
                    Icons.bug_report_outlined, 'Hama'),
                _buildNavItem(3, Icons.chat_bubble_rounded,
                    Icons.chat_bubble_outlined, 'Chatbot'),
                _buildNavItem(
                    4, Icons.store_rounded, Icons.store_outlined, 'Pasar'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData active, IconData inactive, String label) {
    final selectedIndex = ref.watch(currentTabProvider);
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? active : inactive,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontFamily: 'InterTight',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);
    final scanHistory = ref.watch(hamaStateProvider);

    // Dynamic Calculations
    final int activeFieldsCount = sawahList.length;

    double avgHealth = 0.0;
    if (sawahList.isNotEmpty) {
      final totalHealth = sawahList.fold<double>(
          0.0, (sum, sawah) => sum + (100.0 - sawah.skorRisiko.toDouble()));
      avgHealth = totalHealth / sawahList.length;
    }

    // Colors according to average health
    Color healthColor = AppColors.success;
    String healthLabel = 'Sehat';
    if (avgHealth < 50) {
      healthColor = AppColors.error;
      healthLabel = 'Bahaya';
    } else if (avgHealth < 80) {
      healthColor = AppColors.warning;
      healthLabel = 'Waspada';
    }

    // Dynamic Pest Risk
    final hasHighRiskPest = sawahList.any((s) => s.statusKesehatan == 'Sakit');
    final String pestRisk = hasHighRiskPest ? 'Tinggi' : 'Rendah';
    final Color pestColor =
        hasHighRiskPest ? AppColors.error : AppColors.success;

    // Harvest estimation calculation: ~6.2 tons per hectare on average
    double totalExpectedYield = 0.0;
    for (final s in sawahList) {
      totalExpectedYield += s.luasHektar * 6.2;
    }

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Hero(
                    tag: 'app-logo',
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success,
                            AppColors.successLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.agriculture_rounded,
                          color: AppColors.textOnPrimary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Petani Karawang! 👋',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Karawang, Jawa Barat',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontFamily: 'InterTight',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            size: 26),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(width: 4, height: 4),
                          ),
                        )
                      ],
                    ),
                    onPressed: () => _showNotificationCenter(context),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Live Weather Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                          const Text(
                            'CUACA HARI INI',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              fontFamily: 'InterTight',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '🌤️ Hujan Ringan Sore Hari',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _weatherChip(Icons.thermostat, '31°C'),
                              _weatherChip(Icons.water_drop_outlined, '82%'),
                              _weatherChip(Icons.air, '14 km/jam'),
                              _weatherChip(
                                  Icons.cloudy_snowing, 'Curah Tinggi'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.wb_cloudy_rounded,
                        color: Colors.white70, size: 68),
                  ],
                ),
              ),
            ),
          ),

          // Statistics Dashboard Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kondisi Pertanian Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _statCard(
                          '$activeFieldsCount',
                          'Sawah Aktif',
                          Icons.agriculture_rounded,
                          AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _statCard(
                          '${avgHealth.toStringAsFixed(0)}%',
                          healthLabel,
                          Icons.favorite_rounded,
                          healthColor,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _statCard(
                          pestRisk,
                          'Risiko Hama',
                          Icons.shield_rounded,
                          pestColor,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _statCard(
                          '${totalExpectedYield.toStringAsFixed(1)} T',
                          'Est. Panen',
                          Icons.calendar_month_rounded,
                          AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 4,
                        child: _quickActionItem(
                          context,
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Tambah\nSawah',
                          color: Colors.green,
                          onTap: () {
                            final dashboard = context
                                .findAncestorStateOfType<_DashboardScreenState>();
                            dashboard?.navigateToTab(1);
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 4,
                        child: _quickActionItem(
                          context,
                          icon: Icons.camera_alt_outlined,
                          label: 'Pindai\nDaun',
                          color: Colors.orange,
                          onTap: () {
                            final dashboard = context
                                .findAncestorStateOfType<_DashboardScreenState>();
                            dashboard?.navigateToTab(2);
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 4,
                        child: _quickActionItem(
                          context,
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Tanya\nAI',
                          color: Colors.blue,
                          onTap: () {
                            final dashboard = context
                                .findAncestorStateOfType<_DashboardScreenState>();
                            dashboard?.navigateToTab(3);
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 4,
                        child: _quickActionItem(
                          context,
                          icon: Icons.store_mall_directory_outlined,
                          label: 'Harga\nPasar',
                          color: Colors.purple,
                          onTap: () {
                            final dashboard = context
                                .findAncestorStateOfType<_DashboardScreenState>();
                            dashboard?.navigateToTab(4);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Features List & Analytics Widgets
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analisis & Rekomendasi AgroBrain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _featureCard(
                          context,
                          icon: Icons.analytics_rounded,
                          title: 'Kalkulator Panen',
                          subtitle: 'Simulasikan hasil panen padi Anda',
                          color: Colors.blue,
                          onTap: () =>
                              _showHarvestPredictionCalculator(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureCard(
                          context,
                          icon: Icons.trending_up_rounded,
                          title: 'Harga Gabah',
                          subtitle: 'Prediksi GKP Rp5.700, GKG Rp6.800',
                          color: Colors.teal,
                          onTap: () {
                            final dashboard = context.findAncestorStateOfType<
                                _DashboardScreenState>();
                            dashboard?.navigateToTab(4); // Go to Pasar
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recent Activity Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final dashboard = context
                              .findAncestorStateOfType<_DashboardScreenState>();
                          dashboard
                              ?.navigateToTab(2); // Go to pest scan history
                        },
                        child: const Text('Semua Riwayat',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (scanHistory.isNotEmpty)
                          ...scanHistory.take(3).map((scan) {
                            final isLast = scanHistory.indexOf(scan) ==
                                (scanHistory.length < 3
                                    ? scanHistory.length - 1
                                    : 2);
                            Color riskColor = Colors.green;
                            if (scan.tingkatRisiko == 'TINGGI') {
                              riskColor = Colors.red;
                            } else if (scan.tingkatRisiko == 'SEDANG') {
                              riskColor = Colors.orange;
                            }

                            final sawah = sawahList.firstWhere(
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

                            return _activityItem(
                              icon: Icons.bug_report_rounded,
                              title: '${scan.namaHama} Terdeteksi',
                              subtitle:
                                  '${sawah.nama} — ${scan.confidence * 100}% Akurasi',
                              time: _formatDateTime(scan.detectedAt),
                              color: riskColor,
                              isLast: isLast,
                            );
                          })
                        else
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Belum ada aktivitas deteksi hama.',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _weatherChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'InterTight',
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'InterTight',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _quickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'InterTight',
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
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
                      subtitle,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        fontFamily: 'InterTight',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'InterTight',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                  fontFamily: 'InterTight',
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 58, color: AppColors.divider),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays} hari lalu';
  }

  // ─── Notification Center ───────────────────────────────────────────────────
  void _showNotificationCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pusat Notifikasi Cerdas 🔔',
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
            const Divider(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _notifItem(
                    context,
                    title: 'Jadwal Pemupukan Susulan 🧪',
                    desc:
                        'Jadwal pemupukan Urea susulan untuk Sawah Utama - Telukjambe (HST 45) direkomendasikan hari ini.',
                    time: 'Baru saja',
                    color: Colors.green,
                  ),
                  _notifItem(
                    context,
                    title: 'Peringatan Cuaca Buruk ⛈️',
                    desc:
                        'Diprediksi terjadi hujan lebat disertai angin kencang di Karawang Barat besok sore. Pastikan saluran drainase sawah lancar!',
                    time: '1 jam lalu',
                    color: Colors.amber,
                  ),
                  _notifItem(
                    context,
                    title: 'Peringatan Risiko Hama Wereng ⚠️',
                    desc:
                        'Laporan hama Wereng Cokelat meningkat di Tempuran. Pantau berkala sawah Anda!',
                    time: '3 jam lalu',
                    color: Colors.red,
                  ),
                  _notifItem(
                    context,
                    title: 'Jadwal Panen Dekat 🌾',
                    desc:
                        'Sawah Blok B di Tempuran mendekati usia panen (75 HST). Persiapkan logistik panen sekitar 15 hari lagi.',
                    time: '1 hari lalu',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(
    BuildContext context, {
    required String title,
    required String desc,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                    fontFamily: 'InterTight'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
              fontFamily: 'InterTight',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Harvest Prediction Calculator ─────────────────────────────────────────
  void _showHarvestPredictionCalculator(BuildContext context, WidgetRef ref) {
    // sawah list not needed here; use providers in UI when required
    final areaController = TextEditingController();
    String? selectedPadi = 'Ciherang';
    int? ageDays = 45;

    // Choose active sawah if any (use sawahList directly when needed)

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prediksi Hasil Panen AI 🌾',
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
              const Text(
                'Estimasi hasil panen gabah berdasarkan parameter luas sawah, jenis padi, dan umur tanam.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'InterTight'),
              ),
              const SizedBox(height: 20),

              // Input Luas Sawah
              const Text('Luas Sawah (Hektar)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: areaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Contoh: 2.5',
                  prefixIcon:
                      const Icon(Icons.straighten, color: AppColors.primary),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Jenis Padi
              const Text('Jenis Padi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedPadi = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Umur Tanaman
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Umur Tanam: $ageDays HST (Hari Setelah Tanam)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Slider(
                value: ageDays!.toDouble(),
                min: 0,
                max: 120,
                divisions: 120,
                label: '$ageDays HST',
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (double val) {
                  setModalState(() {
                    ageDays = val.toInt();
                  });
                },
              ),
              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton(
                onPressed: () {
                  final area = double.tryParse(areaController.text) ?? 1.0;
                  // Yield estimation: ~6.2 Tons per Hectare for Ciherang, with risk adjustments.
                  double baseYield = 6.2;
                  if (selectedPadi == 'Pandan Wangi') baseYield = 5.8;
                  if (selectedPadi == 'IR64') baseYield = 6.0;

                  double totalYield = area * baseYield;
                  int daysLeft = (115 - ageDays!).clamp(0, 115);

                  Navigator.pop(context); // Close inputs sheet

                  // Show output dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.analytics_rounded,
                              color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Hasil Analitik AI',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('ESTIMASI HASIL PANEN',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${totalYield.toStringAsFixed(1)} Ton',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontFamily: 'Poppins')),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.grain,
                                      color: Colors.orange, size: 28),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sisa Waktu Panen:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text(
                                  daysLeft == 0
                                      ? 'Sudah Waktunya Panen!'
                                      : '$daysLeft Hari Lagi',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Varietas Padi:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text(selectedPadi!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Rata-rata Produktivitas:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text('$baseYield Ton/Ha',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            '💡 Tips Pertanian:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            daysLeft > 30
                                ? 'Fase pertumbuhan tanaman Anda sedang aktif. Optimalkan pemupukan nitrogen dan fosfat.'
                                : 'Mendekati masa panen. Kurangi suplai irigasi untuk mencegah rebah tanaman dan jamur leher.',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                      ],
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
                  'Hitung Perkiraan Panen',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
