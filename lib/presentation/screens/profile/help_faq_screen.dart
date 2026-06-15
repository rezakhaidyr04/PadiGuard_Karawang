import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int _expandedIndex = -1;

  static const _faqItems = [
    _FaqItem(
      question: 'Bagaimana cara menambahkan sawah baru?',
      answer:
          'Untuk menambahkan sawah baru, buka tab "Sawah" di menu bawah, lalu tekan tombol (+) atau pilih "Tambah Sawah" di Aksi Cepat pada beranda. Isi data seperti nama sawah, lokasi, luas, jenis tanaman, dan informasi lainnya.',
      icon: Icons.grass_rounded,
      color: AppColors.primary,
    ),
    _FaqItem(
      question: 'Bagaimana cara scan deteksi hama/penyakit?',
      answer:
          'Buka tab "Scan" di menu bawah. Tekan tombol kamera untuk mengambil foto daun padi yang ingin dianalisis. AI akan mendeteksi jenis hama/penyakit dan memberikan rekomendasi solusi secara otomatis. Pastikan foto diambil dengan pencahayaan yang baik dan fokus pada bagian daun yang bermasalah.',
      icon: Icons.document_scanner_rounded,
      color: Colors.orange,
    ),
    _FaqItem(
      question: 'Apa itu Skor Risiko pada sawah?',
      answer:
          'Skor Risiko (0-100) menunjukkan tingkat risiko serangan hama/penyakit pada sawah Anda. Skor 0-25 berarti risiko rendah (hijau), 26-50 risiko sedang (kuning), dan di atas 50 risiko tinggi (merah). Skor ini dihitung berdasarkan hasil deteksi hama, kondisi cuaca, kelembaban, dan pH tanah.',
      icon: Icons.shield_rounded,
      color: AppColors.warning,
    ),
    _FaqItem(
      question: 'Bagaimana cara menggunakan AI Chat?',
      answer:
          'Buka tab "AI Chat" di menu bawah. Anda bisa mengetik pertanyaan tentang pertanian padi seperti cara mengatasi hama, rekomendasi pupuk, jadwal tanam, dan sebagainya. AI akan memberikan jawaban yang relevan berdasarkan kondisi pertanian di Karawang.',
      icon: Icons.smart_toy_rounded,
      color: Colors.blue,
    ),
    _FaqItem(
      question: 'Bagaimana cara melihat harga pasar?',
      answer:
          'Buka tab "Pasar" di menu bawah untuk melihat daftar posting harga gabah, beras, dan produk pertanian lainnya di wilayah Karawang. Anda juga bisa memposting produk Anda sendiri dengan menekan tombol (+) di halaman Pasar.',
      icon: Icons.storefront_rounded,
      color: AppColors.secondary,
    ),
    _FaqItem(
      question: 'Apa itu Kalkulator Panen?',
      answer:
          'Kalkulator Panen adalah fitur prediksi hasil panen berdasarkan data sawah Anda seperti luas lahan, jenis varietas, usia tanaman, dan skor risiko. Fitur ini membantu memperkirakan jumlah gabah yang akan dihasilkan saat panen tiba. Akses melalui "Analisis Panen" di Aksi Cepat.',
      icon: Icons.calculate_rounded,
      color: Colors.purple,
    ),
    _FaqItem(
      question: 'Bagaimana cara mengubah profil saya?',
      answer:
          'Tekan ikon profil (👤) di pojok kanan atas beranda, lalu pilih "Edit Profil". Anda bisa mengubah nama, email, nomor telepon, dan alamat. Jangan lupa tekan "Simpan Perubahan" setelah selesai.',
      icon: Icons.person_rounded,
      color: AppColors.primary,
    ),
    _FaqItem(
      question: 'Apakah data saya aman?',
      answer:
          'Ya, data Anda disimpan secara lokal di perangkat Anda. Kami tidak membagikan data pribadi atau data sawah Anda kepada pihak ketiga. Anda juga bisa mengekspor data sawah melalui menu Pengaturan > Data & Penyimpanan.',
      icon: Icons.lock_rounded,
      color: AppColors.success,
    ),
  ];

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
            Icon(Icons.help_outline_rounded, color: AppColors.info, size: 20),
            SizedBox(width: 8),
            Text(
              'Bantuan & FAQ',
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
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0277BD), Color(0xFF0288D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.3),
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
                          'Pusat Bantuan 💡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temukan jawaban untuk pertanyaan yang sering diajukan seputar PadiGuard.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.question_answer_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FAQ title
            const Text(
              'Pertanyaan Umum (FAQ)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // FAQ items
            ...List.generate(_faqItems.length, (i) => _buildFaqCard(i)),

            const SizedBox(height: 20),

            // Contact support card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.headset_mic_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Masih Butuh Bantuan?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hubungi tim support kami untuk bantuan lebih lanjut.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('📧 Email: support@padiguard.id'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.email_rounded, size: 18),
                          label: const Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 44),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('📞 WhatsApp: 0812-3456-7890'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 18),
                          label: const Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(0, 44),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(int index) {
    final item = _faqItems[index];
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? item.color.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? item.color.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isExpanded ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              setState(() => _expandedIndex = isExpanded ? -1 : index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.question,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: isExpanded
                              ? item.color
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? item.color : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14, left: 50),
                    child: Text(
                      item.answer,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                        height: 1.6,
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;
  final Color color;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
    required this.color,
  });
}
