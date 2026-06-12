// File: lib/presentation/screens/market/market_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_state_providers.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(marketSearchQueryProvider);
    final filter = ref.watch(marketCategoryFilterProvider);
    final allPostings = ref.watch(marketPostingsProvider);

    // Filtered marketplace items
    final filteredPostings = allPostings.where((item) {
      final matchesSearch =
          item.namaProduk.toLowerCase().contains(search.toLowerCase()) ||
              item.penjual.toLowerCase().contains(search.toLowerCase());
      final matchesFilter = filter == 'Semua' || item.jenis == filter;
      return matchesSearch && matchesFilter;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          title: const Text(
            'Pasar & Harga Gabah 🌾',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            tabs: [
              Tab(text: 'Harga & Tren'),
              Tab(text: 'Marketplace Petani'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Harga & Tren
            _buildPriceTrendTab(context),
            // TAB 2: Marketplace Petani
            _buildMarketplaceTab(context, ref, filteredPostings),
          ],
        ),
        floatingActionButton: Consumer(builder: (context, ref, _) {
          return Builder(builder: (context) {
            // Only show FAB when in Marketplace tab (which is tab index 1 of TabBarView)
            // To keep it simple, we show it everywhere but direct the action appropriately.
            return FloatingActionButton.extended(
              onPressed: () => _showAddPostingDialog(context, ref),
              backgroundColor: AppColors.primary,
              label: const Text('Jual Hasil Panen',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add, color: Colors.white),
            );
          });
        }),
      ),
    );
  }

  Widget _buildPriceTrendTab(BuildContext context) {
    // 30 days dummy prices data
    final List<double> gkpData = [
      5400,
      5450,
      5420,
      5500,
      5480,
      5520,
      5500,
      5560,
      5540,
      5580,
      5600,
      5590,
      5630,
      5610,
      5650,
      5640,
      5680,
      5700,
      5680,
      5720,
      5750,
      5720,
      5780,
      5800,
      5790,
      5830,
      5810,
      5850,
      5880,
      5900
    ];

    final List<double> gkgData = [
      6300,
      6340,
      6320,
      6380,
      6360,
      6420,
      6400,
      6450,
      6430,
      6480,
      6500,
      6490,
      6540,
      6520,
      6580,
      6560,
      6600,
      6630,
      6610,
      6650,
      6700,
      6680,
      6720,
      6750,
      6740,
      6780,
      6760,
      6800,
      6830,
      6850
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing Cards Row
          Row(
            children: [
              Expanded(
                child: _priceCard(
                  title: 'GKP (Gabah Kering Panen)',
                  price: 'Rp 5.900',
                  unit: '/kg',
                  trend: 'Naik 2.4%',
                  isUp: true,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _priceCard(
                  title: 'GKG (Gabah Kering Giling)',
                  price: 'Rp 6.850',
                  unit: '/kg',
                  trend: 'Naik 3.1%',
                  isUp: true,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Forecast Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            padding: const EdgeInsets.all(14),
            child: const Row(
              children: [
                Icon(Icons.auto_graph_rounded,
                    color: AppColors.primary, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prediksi Harga Minggu Depan 📈',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 2),
                      Text(
                          'Diperkirakan harga beras & gabah naik 4% karena peningkatan permintaan pasar regional.',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.35,
                              fontFamily: 'InterTight')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Painter Line Chart
          const Text(
            'Grafik Harga 30 Hari Terakhir',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Legends row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _legendItem('GKP', Colors.orange),
                    const SizedBox(width: 16),
                    _legendItem('GKG', AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PriceLineChartPainter(
                      gkpData: gkpData,
                      gkgData: gkgData,
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

  Widget _buildMarketplaceTab(
    BuildContext context,
    WidgetRef ref,
    List<MarketItem> postings,
  ) {
    final search = ref.watch(marketSearchQueryProvider);
    final currentFilter = ref.watch(marketCategoryFilterProvider);

    return Column(
      children: [
        // Search & Filter header
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              // Search input
              TextField(
                onChanged: (val) {
                  ref.read(marketSearchQueryProvider.notifier).state = val;
                },
                decoration: InputDecoration(
                  hintText: 'Cari beras, gabah, atau nama petani...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref.read(marketSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Semua', 'Beras', 'Gabah'].map((cat) {
                  final isSelected = cat == currentFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(marketCategoryFilterProvider.notifier)
                              .state = cat;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Marketplace list
        Expanded(
          child: postings.isEmpty
              ? _buildEmptyMarket()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 80), // extra padding for FAB
                  itemCount: postings.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) =>
                      _buildProductCard(context, postings[index]),
                ),
        ),
      ],
    );
  }

  Widget _priceCard({
    required String title,
    required String price,
    required String unit,
    required String trend,
    required bool isUp,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InterTight')),
          const SizedBox(height: 8),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                price,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins'),
              ),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'InterTight')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                color: isUp ? AppColors.success : AppColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUp ? AppColors.success : AppColors.error,
                  fontFamily: 'InterTight',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              fontFamily: 'InterTight'),
        ),
      ],
    );
  }

  Widget _buildEmptyMarket() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 68, color: AppColors.textHint),
          SizedBox(height: 12),
          Text('Produk tidak ditemukan',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins')),
          SizedBox(height: 4),
          Text('Coba ketik kata kunci lain atau ubah filter.',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontFamily: 'InterTight')),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, MarketItem item) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop thumbnail
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: item.jenis == 'Beras'
                  ? Colors.amber.withValues(alpha: 0.08)
                  : Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.jenis == 'Beras'
                  ? Icons.rice_bowl_rounded
                  : Icons.grain_rounded,
              color: item.jenis == 'Beras' ? Colors.amber : Colors.orange,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item.jenis == 'Beras'
                                ? Colors.amber
                                : Colors.orange)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.jenis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: item.jenis == 'Beras'
                              ? Colors.amber.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    Text(item.tanggal,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            fontFamily: 'InterTight')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.namaProduk,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('Stok: ${item.kuantitas}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'InterTight')),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.harga.toStringAsFixed(0)}/kg',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                      fontFamily: 'Poppins'),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.penjual.length > 12
                                  ? '${item.penjual.substring(0, 10)}...'
                                  : item.penjual,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'InterTight'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(width: 4),
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              item.lokasi,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'InterTight'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _showPurchaseDetailsBottomSheet(context, item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                color: AppColors.primary, size: 12),
                            SizedBox(width: 4),
                            Text('Beli',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ─── Add Product Modal Form ───────────────────────────────────────────────
  void _showAddPostingDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final sellerController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    String? selectedType = 'Beras';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                    const Text('Posting Produk Marketplace 🌾',
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

                // Nama Produk
                const Text('Nama Produk',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      hintText: 'Contoh: Beras Ciherang Super Karawang'),
                ),
                const SizedBox(height: 14),

                // Jenis & Jumlah Stok Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jenis Produk',
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
                                value: selectedType,
                                isExpanded: true,
                                items: ['Beras', 'Gabah']
                                    .map((t) => DropdownMenuItem(
                                        value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedType = val;
                                  });
                                },
                              ),
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
                          const Text('Jumlah Stok',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(
                                hintText: 'Contoh: 1.000 kg'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Harga / kg
                const Text('Harga Jual (Rp/kg)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Contoh: 13500'),
                ),
                const SizedBox(height: 14),

                // Penjual & Telepon
                const Text('Nama Penjual',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: sellerController,
                  decoration:
                      const InputDecoration(hintText: 'Contoh: Pak Tarno'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nomor WA / Telepon',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(hintText: 'Contoh: 0812xxxxxxxx'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lokasi Kecamatan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: locationController,
                            decoration: const InputDecoration(hintText: 'Contoh: Tempuran'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        sellerController.text.isEmpty) {
                      return;
                    }

                    final item = MarketItem(
                      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
                      namaProduk: titleController.text,
                      jenis: selectedType!,
                      kuantitas: quantityController.text.isEmpty
                          ? '1.000 kg'
                          : quantityController.text,
                      harga: double.tryParse(priceController.text) ?? 12000.0,
                      penjual: sellerController.text,
                      telepon: phoneController.text.isEmpty
                          ? '08123456789'
                          : phoneController.text,
                      lokasi: locationController.text.isEmpty
                          ? 'Karawang'
                          : locationController.text,
                      tanggal: 'Hari ini',
                    );

                    ref.read(marketPostingsProvider.notifier).addPosting(item);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Penawaran Produk Berhasil Diposting!'),
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
                  child: const Text('Posting Sekarang',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDetailsBottomSheet(BuildContext context, MarketItem item) {
    // Parse quantity number from string like "500 kg" -> 500.0, or default to 100.0
    final stockString = item.kuantitas.replaceAll(RegExp(r'[^0-9.]'), '');
    final double maxStock = double.tryParse(stockString) ?? 100.0;
    
    final quantityController = TextEditingController(text: maxStock > 100 ? '100' : maxStock.toStringAsFixed(0));
    String selectedTransport = 'Ambil Sendiri';
    double transportFee = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final double qty = double.tryParse(quantityController.text) ?? 0.0;
          final double subtotal = qty * item.harga;
          final double total = subtotal + transportFee;

          return Container(
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
                        'Rincian Pembelian Produk 🌾',
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
                  
                  // Product Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.jenis == 'Beras'
                                ? Colors.amber.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.jenis == 'Beras'
                                ? Icons.rice_bowl_rounded
                                : Icons.grain_rounded,
                            color: item.jenis == 'Beras' ? Colors.amber : Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.namaProduk,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Poppins'),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Penjual: ${item.penjual} • 📍 ${item.lokasi}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'InterTight'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah Pembelian (kg)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Maks. Stok: ${item.kuantitas}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            suffixText: ' kg',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (val) {
                            final double parsed = double.tryParse(val) ?? 0.0;
                            if (parsed > maxStock) {
                              quantityController.text = maxStock.toStringAsFixed(0);
                              quantityController.selection = TextSelection.fromPosition(
                                TextPosition(offset: quantityController.text.length),
                              );
                            }
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Transport dropdown
                  const Text('Moda Transportasi',
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
                        value: selectedTransport,
                        isExpanded: true,
                        items: [
                          'Ambil Sendiri',
                          'Kirim via Pick-Up',
                          'Kirim via Truk',
                        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedTransport = val;
                              if (val == 'Ambil Sendiri') {
                                transportFee = 0.0;
                              } else if (val == 'Kirim via Pick-Up') {
                                transportFee = 300000.0;
                              } else {
                                transportFee = 700000.0;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price breakdown
                  const Text('Rincian Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  _priceBreakdownItem('Harga Satuan', 'Rp ${item.harga.toStringAsFixed(0)}/kg'),
                  _priceBreakdownItem('Kuantitas', '${qty.toStringAsFixed(0)} kg'),
                  _priceBreakdownItem('Subtotal Produk', 'Rp ${subtotal.toStringAsFixed(0)}'),
                  _priceBreakdownItem('Biaya Transport ($selectedTransport)', 'Rp ${transportFee.toStringAsFixed(0)}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        'Rp ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buy Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: qty <= 0
                          ? null
                          : () {
                              Navigator.pop(context);
                              _showWhatsAppSimulationDialog(
                                context,
                                item,
                                qty,
                                selectedTransport,
                                total,
                              );
                            },
                      icon: const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Hubungi via WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _priceBreakdownItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'InterTight')),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'InterTight')),
        ],
      ),
    );
  }

  void _showWhatsAppSimulationDialog(
    BuildContext context,
    MarketItem item,
    double quantity,
    String transport,
    double total,
  ) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final String messageText = 
      'Halo ${item.penjual},\n\n'
      'Saya tertarik membeli produk yang Anda tawarkan di PadiGuard Karawang:\n'
      '• Produk: ${item.namaProduk}\n'
      '• Jumlah: ${quantity.toStringAsFixed(0)} kg\n'
      '• Pengiriman: $transport\n'
      '• Total Pembayaran: Rp ${total.toStringAsFixed(0)}\n\n'
      'Apakah stok tersebut masih tersedia dan bisa diproses? Terima kasih!';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFF075E54), // WhatsApp green
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Simulasi Kirim WhatsApp',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins'),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_iphone_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Kirim ke WA Penjual: ${item.telepon}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'InterTight'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Simulated chat bubble
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6), // WhatsApp bubble green
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7E5B4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black87,
                        height: 1.45,
                        fontFamily: 'InterTight'),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeStr,
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade600,
                          fontFamily: 'InterTight'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              // Copy to clipboard simulation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Teks pesanan berhasil disalin!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: const Text('Salin Pesan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Menghubungi WhatsApp ${item.penjual} (${item.telepon})...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WA Bright green
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}


// ─── Custom Canvas Line Chart Painter ────────────────────────────────────────

class PriceLineChartPainter extends CustomPainter {
  final List<double> gkpData;
  final List<double> gkgData;

  PriceLineChartPainter({required this.gkpData, required this.gkgData});

  @override
  void paint(Canvas canvas, Size size) {
    if (gkpData.isEmpty || gkgData.isEmpty) return;

    final paintGkpLine = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGkgLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintGrid = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    // Find min and max value for vertical scaling
    double minVal = 5000;
    double maxVal = 7200;

    // Drawing vertical grid & text labels
    const int verticalDivisions = 4;
    for (int i = 0; i <= verticalDivisions; i++) {
      double y = size.height - (i * size.height / verticalDivisions);
      double val = minVal + (i * (maxVal - minVal) / verticalDivisions);

      // Grid line
      canvas.drawLine(Offset(32, y), Offset(size.width, y), paintGrid);

      // Text label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Rp${val.toStringAsFixed(0)}',
          style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 8,
              fontFamily: 'InterTight'),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Draw lines
    final double stepX = (size.width - 32) / (gkpData.length - 1);

    Path gkpPath = Path();
    Path gkgPath = Path();

    // Helper to map values to Y screen coordinate
    double getY(double val) {
      double pct = (val - minVal) / (maxVal - minVal);
      return size.height - (pct * size.height);
    }

    // Start coordinates
    gkpPath.moveTo(32, getY(gkpData[0]));
    gkgPath.moveTo(32, getY(gkgData[0]));

    for (int i = 1; i < gkpData.length; i++) {
      double x = 32 + (i * stepX);
      gkpPath.lineTo(x, getY(gkpData[i]));
      gkgPath.lineTo(x, getY(gkgData[i]));
    }

    // Draw GKP and GKG line on canvas
    canvas.drawPath(gkpPath, paintGkpLine);
    canvas.drawPath(gkgPath, paintGkgLine);

    // Draw dynamic area fill under GKG line (Greenish area) for aesthetics
    final fillGkg = Path()
      ..moveTo(32, size.height)
      ..lineTo(32, getY(gkgData[0]));
    for (int i = 1; i < gkgData.length; i++) {
      fillGkg.lineTo(32 + (i * stepX), getY(gkgData[i]));
    }
    fillGkg.lineTo(size.width, size.height);
    fillGkg.close();

    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary.withValues(alpha: 0.0)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(32, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillGkg, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
