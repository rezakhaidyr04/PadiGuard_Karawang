import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../disease_detection/disease_detection_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../market/market_screen.dart';
import '../field_management/sawah_screen.dart';
import '../predictions/harvest_prediction_screen.dart';
import '../../../data/models/sawah_model.dart';
import '../../providers/app_state_providers.dart';

// ─── Bottom Nav items definition ─────────────────────────────────────────────
const _navItems = [
  _NavItem(Icons.home_rounded, Icons.home_outlined, 'Beranda'),
  _NavItem(Icons.spa_rounded, Icons.spa_outlined, 'Sawah'),
  _NavItem(Icons.document_scanner_rounded, Icons.document_scanner_outlined, 'Scan'),
  _NavItem(Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'AI Chat'),
  _NavItem(Icons.storefront_rounded, Icons.storefront_outlined, 'Pasar'),
];

class _NavItem {
  final IconData active;
  final IconData inactive;
  final String label;
  const _NavItem(this.active, this.inactive, this.label);
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _navAnimController;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _pages = [
      const HomeTab(),
      const SawahScreen(),
      const DiseaseDetectionScreen(),
      const ChatbotScreen(),
      const MarketScreen(),
    ];
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
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
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: _pages[selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(selectedIndex),
    );
  }

  Widget _buildBottomNav(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(i, selectedIndex),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, int selectedIndex) {
    final item = _navItems[index];
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.active : item.inactive,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 22,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════════════════════════════

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sawahList = ref.watch(sawahStateProvider);
    final scanHistory = ref.watch(hamaStateProvider);

    final int activeFieldsCount = sawahList.length;

    double avgHealth = 100.0;
    if (sawahList.isNotEmpty) {
      final totalHealth = sawahList.fold<double>(
          0.0, (sum, sawah) => sum + (100.0 - sawah.skorRisiko.toDouble()));
      avgHealth = totalHealth / sawahList.length;
    }

    Color healthColor = AppColors.success;
    String healthLabel = 'Sangat Baik';
    if (avgHealth < 50) {
      healthColor = AppColors.error;
      healthLabel = 'Kritis';
    } else if (avgHealth < 70) {
      healthColor = AppColors.warning;
      healthLabel = 'Waspada';
    } else if (avgHealth < 85) {
      healthColor = const Color(0xFFF9A825);
      healthLabel = 'Sedang';
    }

    final hasHighRiskPest = sawahList.any((s) => s.statusKesehatan == 'Sakit');
    final hasMedRiskPest = sawahList.any((s) => s.statusKesehatan == 'Risiko');
    final String pestRisk =
        hasHighRiskPest ? 'Tinggi' : hasMedRiskPest ? 'Sedang' : 'Rendah';
    final Color pestColor = hasHighRiskPest
        ? AppColors.error
        : hasMedRiskPest
            ? AppColors.warning
            : AppColors.success;

    double totalExpectedYield = 0.0;
    for (final s in sawahList) {
      totalExpectedYield += s.luasHektar * 6.2 * ((100 - s.skorRisiko) / 100);
    }

    final now = DateTime.now();
    final hour = now.hour;
    final String greeting = hour < 11
        ? 'Selamat Pagi ☀️'
        : hour < 15
            ? 'Selamat Siang 🌤️'
            : hour < 18
                ? 'Selamat Sore 🌅'
                : 'Selamat Malam 🌙';

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Hero(
                    tag: 'app-logo',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.lushGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌾', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 13, color: AppColors.primary),
                            SizedBox(width: 3),
                            Text(
                              'Karawang, Jawa Barat',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildIconBtn(
                    Icons.notifications_outlined,
                    badge: true,
                    onTap: () => _showNotificationCenter(context),
                  ),
                  const SizedBox(width: 8),
                  _buildIconBtn(
                    Icons.person_outline_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ─── Weather Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _WeatherBanner(),
            ),
          ),

          // ─── Stat Cards ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Ringkasan Pertanian'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$activeFieldsCount',
                          label: 'Sawah\nAktif',
                          emoji: '🌾',
                          color: AppColors.primary,
                          onTap: () => ref
                              .read(currentTabProvider.notifier)
                              .state = 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '${avgHealth.toStringAsFixed(0)}%',
                          label: healthLabel,
                          emoji: '💚',
                          color: healthColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: pestRisk,
                          label: 'Risiko\nHama',
                          emoji: pestRisk == 'Rendah' ? '🛡️' : '⚠️',
                          color: pestColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '${totalExpectedYield.toStringAsFixed(1)}T',
                          label: 'Est.\nPanen',
                          emoji: '📦',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Quick Actions ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Aksi Cepat'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickAction(
                        emoji: '➕',
                        label: 'Tambah\nSawah',
                        color: AppColors.primary,
                        onTap: () =>
                            SawahScreen.showAddSawahDialog(context, ref),
                      ),
                      _QuickAction(
                        emoji: '🔬',
                        label: 'Scan\nDaun AI',
                        color: Colors.orange.shade700,
                        onTap: () =>
                            ref.read(currentTabProvider.notifier).state = 2,
                      ),
                      _QuickAction(
                        emoji: '🤖',
                        label: 'Tanya\nAI Chat',
                        color: Colors.blue.shade700,
                        onTap: () =>
                            ref.read(currentTabProvider.notifier).state = 3,
                      ),
                      _QuickAction(
                        emoji: '📊',
                        label: 'Analisis\nPanen',
                        color: Colors.purple.shade600,
                        onTap: () =>
                            _showHarvestSheet(context, ref),
                      ),
                      _QuickAction(
                        emoji: '💹',
                        label: 'Harga\nPasar',
                        color: Colors.teal.shade600,
                        onTap: () =>
                            ref.read(currentTabProvider.notifier).state = 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Sawah Overview Cards ─────────────────────────────────────────
          if (sawahList.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('Kondisi Sawah'),
                        TextButton(
                          onPressed: () =>
                              ref.read(currentTabProvider.notifier).state = 1,
                          child: const Text('Lihat Semua',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: sawahList.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) =>
                            _SawahMiniCard(sawah: sawahList[i], ref: ref),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Feature Cards Row ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Fitur Unggulan AI'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          emoji: '🧮',
                          title: 'Kalkulator Panen',
                          subtitle: 'Prediksi hasil gabah dari data sawah Anda',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                          ),
                          onTap: () => _showHarvestSheet(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          emoji: '📈',
                          title: 'Prediksi Harga',
                          subtitle: 'GKP: Rp5.900 · GKG: Rp6.850/kg',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00695C), Color(0xFF004D40)],
                          ),
                          onTap: () =>
                              ref.read(currentTabProvider.notifier).state = 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Recent Activity ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('Aktivitas Terbaru'),
                      TextButton(
                        onPressed: () =>
                            ref.read(currentTabProvider.notifier).state = 2,
                        child: const Text('Semua',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: scanHistory.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('🌿',
                                      style: TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Belum ada aktivitas deteksi.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: scanHistory.take(3).toList().map((scan) {
                              final isLast = scanHistory.indexOf(scan) ==
                                  (scanHistory.length < 3
                                      ? scanHistory.length - 1
                                      : 2);
                              Color riskColor = AppColors.primary;
                              if (scan.tingkatRisiko == 'TINGGI') {
                                riskColor = AppColors.error;
                              } else if (scan.tingkatRisiko == 'SEDANG') {
                                riskColor = AppColors.warning;
                              }
                              final sawah = sawahList.firstWhere(
                                (s) => s.id == scan.sawahId,
                                orElse: () => SawahModel.empty(),
                              );
                              return _activityTile(
                                icon: Icons.bug_report_rounded,
                                title: scan.namaHama,
                                subtitle: sawah.nama.isEmpty
                                    ? 'Sawah Karawang'
                                    : sawah.nama,
                                time: _timeAgo(scan.detectedAt),
                                color: riskColor,
                                isLast: isLast,
                              );
                            }).toList(),
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

  static Widget _buildIconBtn(IconData icon,
      {bool badge = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          if (badge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      ),
    );
  }

  static Widget _activityTile({
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              Text(time,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 72, color: AppColors.divider),
      ],
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  // ─── Notification Center ───────────────────────────────────────────────────
  static void _showNotificationCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notifikasi Cerdas 🔔',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    _NotifCard(
                      title: 'Jadwal Pemupukan Susulan 🧪',
                      desc:
                          'Sawah Utama - Telukjambe (45 HST) memerlukan pemupukan Urea susulan hari ini.',
                      time: 'Baru saja',
                      color: AppColors.primary,
                    ),
                    _NotifCard(
                      title: 'Peringatan Cuaca Buruk ⛈️',
                      desc:
                          'Prediksi hujan lebat + angin kencang di Karawang Barat besok sore. Pastikan drainase sawah lancar.',
                      time: '1 jam lalu',
                      color: AppColors.warning,
                    ),
                    _NotifCard(
                      title: 'Risiko Hama Wereng ⚠️',
                      desc:
                          'Laporan hama Wereng Cokelat meningkat di Kecamatan Tempuran. Pantau berkala!',
                      time: '3 jam lalu',
                      color: AppColors.error,
                    ),
                    _NotifCard(
                      title: 'Panen Mendekati 🌾',
                      desc:
                          'Sawah Blok B - Tempuran mendekati usia panen (75 HST). Persiapkan logistik sekitar 15 hari lagi.',
                      time: '1 hari lalu',
                      color: Colors.blue,
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

  // ─── Harvest Calculator ─────────────────────────────────────────────────────
  static void _showHarvestSheet(BuildContext context, WidgetRef ref) {
    final sawahList = ref.read(sawahStateProvider);
    if (sawahList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Daftarkan sawah terlebih dahulu!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HarvestPredictionScreen()),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final String title;
  final String desc;
  final String time;
  final Color color;

  const _NotifCard({
    required this.title,
    required this.desc,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color,
                        fontFamily: 'Poppins')),
              ),
              const SizedBox(width: 8),
              Text(time,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

// ─── Weather Banner Widget ────────────────────────────────────────────────────
class _WeatherBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUACA KARAWANG HARI INI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '🌤️ Berawan & Hujan Ringan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(Icons.thermostat_rounded, '31°C'),
                    _chip(Icons.water_drop_outlined, '82%'),
                    _chip(Icons.air_rounded, '14 km/j'),
                    _chip(Icons.umbrella_rounded, 'Curah Tinggi'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text('🌧️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 4),
              Text(
                'Cocok Irigasi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
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
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action ─────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sawah Mini Card (horizontal scroll) ────────────────────────────────────
class _SawahMiniCard extends StatelessWidget {
  final SawahModel sawah;
  final WidgetRef ref;

  const _SawahMiniCard({required this.sawah, required this.ref});

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

    final progress = (sawah.umurTanamanHari / 115).clamp(0.0, 1.0);
    final daysLeft =
        sawah.tanggalPanenExpected.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        ref.read(selectedSawahIdProvider.notifier).state = sawah.id;
        ref.read(currentTabProvider.notifier).state = 1;
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: healthColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🌾', style: TextStyle(fontSize: 20)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$healthEmoji ${sawah.statusKesehatan}',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: healthColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sawah.nama,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${sawah.luasHektar} Ha · ${sawah.jenisTanaman}',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter'),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.85 ? AppColors.accent : AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sawah.umurTanamanHari} HST',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter'),
                ),
                Text(
                  daysLeft > 0 ? '$daysLeft hari' : 'Panen!',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: daysLeft <= 14 ? AppColors.accent : AppColors.primary,
                      fontFamily: 'Inter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontFamily: 'Inter',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
