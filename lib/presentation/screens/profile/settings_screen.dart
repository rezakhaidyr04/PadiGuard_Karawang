import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifikasiHama = true;
  bool _notifikasiCuaca = true;
  bool _notifikasiPasar = false;
  bool _notifikasiPupuk = true;
  String _selectedBahasa = 'Indonesia';
  String _selectedSatuan = 'Hektar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings_rounded, color: AppColors.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Notifikasi ─────────────────────────────────────────────
            _buildSectionCard(
              title: 'Notifikasi',
              emoji: '🔔',
              children: [
                _buildSwitchTile(
                  icon: Icons.bug_report_rounded,
                  color: AppColors.error,
                  title: 'Peringatan Hama',
                  subtitle: 'Notifikasi saat terdeteksi risiko hama tinggi',
                  value: _notifikasiHama,
                  onChanged: (v) => setState(() => _notifikasiHama = v),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildSwitchTile(
                  icon: Icons.cloud_rounded,
                  color: AppColors.info,
                  title: 'Info Cuaca',
                  subtitle: 'Notifikasi prediksi cuaca untuk sawah',
                  value: _notifikasiCuaca,
                  onChanged: (v) => setState(() => _notifikasiCuaca = v),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildSwitchTile(
                  icon: Icons.storefront_rounded,
                  color: AppColors.accent,
                  title: 'Update Harga Pasar',
                  subtitle: 'Notifikasi perubahan harga gabah & beras',
                  value: _notifikasiPasar,
                  onChanged: (v) => setState(() => _notifikasiPasar = v),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildSwitchTile(
                  icon: Icons.science_rounded,
                  color: AppColors.primary,
                  title: 'Jadwal Pemupukan',
                  subtitle: 'Pengingat jadwal pemupukan sawah',
                  value: _notifikasiPupuk,
                  onChanged: (v) => setState(() => _notifikasiPupuk = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Preferensi ─────────────────────────────────────────────
            _buildSectionCard(
              title: 'Preferensi',
              emoji: '⚙️',
              children: [
                _buildDropdownTile(
                  icon: Icons.language_rounded,
                  color: AppColors.info,
                  title: 'Bahasa',
                  value: _selectedBahasa,
                  items: const ['Indonesia', 'Sunda', 'Jawa'],
                  onChanged: (v) =>
                      setState(() => _selectedBahasa = v ?? 'Indonesia'),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildDropdownTile(
                  icon: Icons.straighten_rounded,
                  color: AppColors.secondary,
                  title: 'Satuan Luas',
                  value: _selectedSatuan,
                  items: const ['Hektar', 'Bata (Tumbak)', 'Meter Persegi'],
                  onChanged: (v) =>
                      setState(() => _selectedSatuan = v ?? 'Hektar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Data & Penyimpanan ─────────────────────────────────────
            _buildSectionCard(
              title: 'Data & Penyimpanan',
              emoji: '💾',
              children: [
                _buildActionTile(
                  icon: Icons.cached_rounded,
                  color: AppColors.warning,
                  title: 'Bersihkan Cache',
                  subtitle: 'Hapus data sementara untuk menghemat ruang',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🗑️ Cache berhasil dibersihkan!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildActionTile(
                  icon: Icons.download_rounded,
                  color: AppColors.primary,
                  title: 'Ekspor Data Sawah',
                  subtitle: 'Unduh data sawah Anda sebagai file',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📥 Data sawah berhasil diekspor!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Tentang Aplikasi ───────────────────────────────────────
            _buildSectionCard(
              title: 'Tentang Aplikasi',
              emoji: '📱',
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                  title: 'Versi Aplikasi',
                  trailing: 'v1.0.0',
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildInfoTile(
                  icon: Icons.code_rounded,
                  color: AppColors.textSecondary,
                  title: 'Developer',
                  trailing: 'PadiGuard Team',
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                _buildInfoTile(
                  icon: Icons.location_city_rounded,
                  color: AppColors.textSecondary,
                  title: 'Wilayah',
                  trailing: 'Karawang',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String emoji,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              '$emoji $title',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Inter',
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.primary),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Text(
          trailing,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
