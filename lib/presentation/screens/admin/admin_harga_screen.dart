// File: lib/presentation/screens/admin/admin_harga_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';

class AdminHargaScreen extends ConsumerStatefulWidget {
  const AdminHargaScreen({super.key});

  @override
  ConsumerState<AdminHargaScreen> createState() => _AdminHargaScreenState();
}

class _AdminHargaScreenState extends ConsumerState<AdminHargaScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final hargaList = ref.watch(adminHargaProvider);

    final filtered = hargaList.where((h) {
      final q = _searchQuery.toLowerCase();
      return q.isEmpty || h.namaKomoditas.toLowerCase().contains(q);
    }).toList();

    final naik = hargaList.where((h) => h.tren == 'naik').length;
    final turun = hargaList.where((h) => h.tren == 'turun').length;
    final stabil = hargaList.where((h) => h.tren == 'stabil').length;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Summary Cards ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _SummaryChip(
                    label: 'Total',
                    value: '${hargaList.length}',
                    color: AppColors.primary,
                    emoji: '💹',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Naik',
                    value: '$naik',
                    color: AppColors.success,
                    emoji: '📈',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Turun',
                    value: '$turun',
                    color: AppColors.error,
                    emoji: '📉',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Stabil',
                    value: '$stabil',
                    color: AppColors.textHint,
                    emoji: '📊',
                  ),
                ],
              ),
            ),
          ),

          // ─── Search + Add Action ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Cari komoditas...',
                          hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                              fontFamily: 'Inter'),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textSecondary, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18, color: AppColors.textHint),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add Button
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context, ref, null),
                      icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Result count ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                '${filtered.length} komoditas terdaftar',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),

          // ─── Harga list ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: _EmptyState(message: 'Komoditas tidak ditemukan'))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _HargaCard(harga: filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static void _showAddEditDialog(
      BuildContext context, WidgetRef ref, AdminHargaData? existing) {
    final isEdit = existing != null;
    final namaCtrl =
        TextEditingController(text: existing?.namaKomoditas ?? '');
    final hargaCtrl = TextEditingController(
        text: existing != null
            ? existing.hargaSaatIni.toStringAsFixed(0)
            : '');
    final hargaSebelumCtrl = TextEditingController(
        text: existing != null
            ? existing.hargaSebelumnya.toStringAsFixed(0)
            : '');
    String tren = existing?.tren ?? 'stabil';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEdit ? 'Edit Harga' : 'Tambah Harga',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(
                  controller: namaCtrl,
                  label: 'Nama Komoditas',
                  hint: 'contoh: Gabah Kering Panen (GKP)',
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: hargaCtrl,
                  label: 'Harga Saat Ini (Rp/kg)',
                  hint: 'contoh: 5900',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _DialogField(
                  controller: hargaSebelumCtrl,
                  label: 'Harga Sebelumnya (Rp/kg)',
                  hint: 'contoh: 5750',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                // Tren picker
                DropdownButtonFormField<String>(
                  initialValue: tren,
                  onChanged: (v) => setS(() => tren = v ?? tren),
                  decoration: InputDecoration(
                    labelText: 'Tren Harga',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'naik',
                        child: Row(children: [
                          Icon(Icons.trending_up_rounded,
                              color: AppColors.success, size: 16),
                          SizedBox(width: 6),
                          Text('Naik'),
                        ])),
                    DropdownMenuItem(
                        value: 'turun',
                        child: Row(children: [
                          Icon(Icons.trending_down_rounded,
                              color: AppColors.error, size: 16),
                          SizedBox(width: 6),
                          Text('Turun'),
                        ])),
                    DropdownMenuItem(
                        value: 'stabil',
                        child: Row(children: [
                          Icon(Icons.trending_flat_rounded,
                              color: AppColors.textHint, size: 16),
                          SizedBox(width: 6),
                          Text('Stabil'),
                        ])),
                  ],
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
              onPressed: () {
                final nama = namaCtrl.text.trim();
                final harga = double.tryParse(hargaCtrl.text.trim()) ?? 0;
                final hargaSblm =
                    double.tryParse(hargaSebelumCtrl.text.trim()) ?? 0;
                if (nama.isEmpty || harga == 0) return;

                final now = DateTime.now();
                if (isEdit) {
                  ref.read(adminHargaProvider.notifier).updateHarga(
                        existing.copyWith(
                          namaKomoditas: nama,
                          hargaSaatIni: harga,
                          hargaSebelumnya: hargaSblm,
                          tren: tren,
                          tanggalUpdate: now,
                        ),
                      );
                } else {
                  ref.read(adminHargaProvider.notifier).addHarga(
                        AdminHargaData(
                          id: 'harga-${now.millisecondsSinceEpoch}',
                          namaKomoditas: nama,
                          hargaSaatIni: harga,
                          hargaSebelumnya: hargaSblm,
                          tren: tren,
                          lokasi: 'Karawang',
                          tanggalUpdate: now,
                        ),
                      );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isEdit ? 'Simpan' : 'Tambah',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String emoji;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textHint,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Harga Card ───────────────────────────────────────────────────────────────
class _HargaCard extends ConsumerWidget {
  final AdminHargaData harga;
  const _HargaCard({required this.harga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trenColor = harga.tren == 'naik'
        ? AppColors.success
        : harga.tren == 'turun'
            ? AppColors.error
            : AppColors.textHint;

    final trenIcon = harga.tren == 'naik'
        ? Icons.trending_up_rounded
        : harga.tren == 'turun'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    final persen = harga.perubahanPersen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Left: komoditas name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: trenColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(trenIcon, size: 12, color: trenColor),
                            const SizedBox(width: 3),
                            Text(
                              '${persen.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: trenColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    harga.namaKomoditas,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatHarga(harga.hargaSaatIni)}/kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Sebelumnya: Rp ${_formatHarga(harga.hargaSebelumnya)}/kg',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📍 ${harga.lokasi} • ${_formatDate(harga.tanggalUpdate)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Right: actions
            Column(
              children: [
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  color: AppColors.primary,
                  onTap: () => _AdminHargaScreenState._showAddEditDialog(
                      context, ref, harga),
                ),
                const SizedBox(height: 10),
                _ActionBtn(
                  icon: Icons.delete_rounded,
                  color: AppColors.error,
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Harga?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus data harga "${harga.namaKomoditas}"?',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(adminHargaProvider.notifier).deleteHarga(harga.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(70, 38),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatHarga(double h) {
    return h.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─── Dialog Field ─────────────────────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.search_off_rounded,
                    size: 36, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba ubah kata kunci pencarian',
              style: TextStyle(
                color: AppColors.textHint,
                fontFamily: 'Inter',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
