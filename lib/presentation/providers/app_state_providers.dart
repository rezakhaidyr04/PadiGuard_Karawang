// File: lib/presentation/providers/app_state_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sawah_model.dart';
import '../../data/models/hama_model.dart';
import '../../core/services/local_ollama_chat_service.dart';

// -----------------------------------------------------------------------------
// SAWAH / FIELD STATE
// -----------------------------------------------------------------------------

class SawahNotifier extends StateNotifier<List<SawahModel>> {
  SawahNotifier() : super(_initialSawah());

  static List<SawahModel> _initialSawah() {
    final now = DateTime.now();
    return [
      SawahModel(
        id: 'sawah-1',
        userId: 'user-001',
        nama: 'Sawah Utama - Telukjambe',
        latitude: -6.3245,
        longitude: 107.3025,
        luasHektar: 2.5,
        jenisTanaman: 'Ciherang',
        tanggalTanam: now.subtract(const Duration(days: 45)), // Fase Vegetatif
        tanggalPanenExpected: now.add(const Duration(days: 75)),
        umurTanamanHari: 45,
        kelembaban: 78.0,
        ph: 6.5,
        temperatureCelsius: 29.5,
        jenisAirTanah: 'Lempung Liat',
        ketersediaanAir: 'Lancar',
        status: 'growing', // Fase Vegetatif
        statusKesehatan: 'Sehat',
        skorRisiko: 12,
        idLogHama: [],
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
      ),
      SawahModel(
        id: 'sawah-2',
        userId: 'user-001',
        nama: 'Sawah Blok B - Tempuran',
        latitude: -6.1824,
        longitude: 107.4255,
        luasHektar: 1.8,
        jenisTanaman: 'Inpari 32',
        tanggalTanam: now.subtract(const Duration(days: 75)), // Fase Generatif
        tanggalPanenExpected: now.add(const Duration(days: 45)),
        umurTanamanHari: 75,
        kelembaban: 65.0,
        ph: 6.1,
        temperatureCelsius: 30.2,
        jenisAirTanah: 'Lempung Berpasir',
        ketersediaanAir: 'Kurang',
        status: 'growing', // Fase Generatif
        statusKesehatan: 'Risiko',
        skorRisiko: 35,
        idLogHama: ['hama-1'],
        createdAt: now.subtract(const Duration(days: 75)),
        updatedAt: now,
      ),
      SawahModel(
        id: 'sawah-3',
        userId: 'user-001',
        nama: 'Sawah Rawa - Cilamaya',
        latitude: -6.2155,
        longitude: 107.5142,
        luasHektar: 3.2,
        jenisTanaman: 'IR64',
        tanggalTanam: now.subtract(const Duration(days: 15)), // Fase Bibit
        tanggalPanenExpected: now.add(const Duration(days: 105)),
        umurTanamanHari: 15,
        kelembaban: 88.0,
        ph: 5.8,
        temperatureCelsius: 28.0,
        jenisAirTanah: 'Gambut',
        ketersediaanAir: 'Melimpah',
        status: 'planting', // Fase Bibit
        statusKesehatan: 'Sakit',
        skorRisiko: 62,
        idLogHama: ['hama-2'],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
    ];
  }

  void addSawah(SawahModel sawah) {
    state = [...state, sawah];
  }

  void updateSawah(SawahModel updated) {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s
    ];
  }

  void reportPest(String sawahId, String hamaId, String riskLevel) {
    state = [
      for (final s in state)
        if (s.id == sawahId)
          s.copyWith(
            idLogHama: [...s.idLogHama, hamaId],
            statusKesehatan: riskLevel == 'TINGGI'
                ? 'Sakit'
                : riskLevel == 'SEDANG'
                    ? 'Risiko'
                    : s.statusKesehatan,
            skorRisiko: (riskLevel == 'TINGGI'
                    ? s.skorRisiko + 25
                    : riskLevel == 'SEDANG'
                        ? s.skorRisiko + 12
                        : s.skorRisiko)
                .clamp(0, 100),
          )
        else
          s
    ];
  }
}

final sawahStateProvider =
    StateNotifierProvider<SawahNotifier, List<SawahModel>>((ref) {
  return SawahNotifier();
});

// Selected Sawah for Detail viewing
final selectedSawahIdProvider = StateProvider<String?>((ref) => null);

// -----------------------------------------------------------------------------
// PEST / HAMA SCAN STATE
// -----------------------------------------------------------------------------

class HamaNotifier extends StateNotifier<List<HamaModel>> {
  HamaNotifier() : super(_initialHama());

  static List<HamaModel> _initialHama() {
    final now = DateTime.now();
    return [
      HamaModel(
        id: 'hama-1',
        sawahId: 'sawah-2',
        userId: 'user-001',
        pathFoto: 'demo_wereng.jpg',
        urlFoto: '',
        namaHama: 'Wereng Cokelat',
        confidence: 0.92,
        tingkatRisiko: 'TINGGI',
        deskripsi:
            'Serangga wereng cokelat menyerap cairan tanaman padi dari batang, menyebabkan daun mengering (hopperburn).',
        solusi: [
          'Kurangi kelembaban dengan metode irigasi berselang (intermittent).',
          'Gunakan insektisida sistemik berbahan aktif Pimetrozin atau Imidakloprid.',
          'Bersihkan gulma di sekeliling tanaman padi.',
        ],
        pestsidaRekomendasi: 'Pimetrozin 50% WG',
        dosasiPestisida: '250 g/ha',
        unitDosis: 'gram',
        waktuAplikasi: 'Pagi hari sebelum jam 09.00',
        detectedAt: now.subtract(const Duration(hours: 3)),
        resolved: false,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      HamaModel(
        id: 'hama-2',
        sawahId: 'sawah-3',
        userId: 'user-001',
        pathFoto: 'demo_blast.jpg',
        urlFoto: '',
        namaHama: 'Blast Fungus (Pyricularia oryzae)',
        confidence: 0.87,
        tingkatRisiko: 'TINGGI',
        deskripsi:
            'Penyakit jamur yang menyerang daun padi menimbulkan bercak belah ketupat, dan mematahkan leher malai padi (patah leher).',
        solusi: [
          'Kurangi pemakaian pupuk Nitrogen (Urea) berlebih.',
          'Aplikasikan fungisida sistemik berbahan aktif Trisiklazol atau Difenokonazol.',
          'Renggangkan jarak tanam (sistem Jajar Legowo).',
        ],
        pestsidaRekomendasi: 'Trisiklazol 75% WP',
        dosasiPestisida: '400 g/ha',
        unitDosis: 'gram',
        waktuAplikasi: 'Sore hari setelah jam 15.00',
        detectedAt: now.subtract(const Duration(days: 1)),
        resolved: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      HamaModel(
        id: 'hama-3',
        sawahId: 'sawah-1',
        userId: 'user-001',
        pathFoto: 'demo_healthy.jpg',
        urlFoto: '',
        namaHama: 'Healthy (Sehat)',
        confidence: 0.96,
        tingkatRisiko: 'RENDAH',
        deskripsi:
            'Daun padi tampak hijau segar bebas bercak. Tidak terdeteksi adanya gejala serangan hama maupun penyakit jamur.',
        solusi: [
          'Pertahankan sistem irigasi berselang.',
          'Pantau berkala seminggu dua kali.',
        ],
        pestsidaRekomendasi: 'N/A',
        dosasiPestisida: '0',
        unitDosis: 'N/A',
        waktuAplikasi: 'N/A',
        detectedAt: now.subtract(const Duration(days: 3)),
        resolved: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  void addScan(HamaModel scan) {
    state = [scan, ...state];
  }
}

final hamaStateProvider =
    StateNotifierProvider<HamaNotifier, List<HamaModel>>((ref) {
  return HamaNotifier();
});

// -----------------------------------------------------------------------------
// CHATBOT MESSAGES STATE
// -----------------------------------------------------------------------------

class ChatbotNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ChatbotNotifier() : super(_initialMessages());

  static List<Map<String, dynamic>> _initialMessages() {
    return [
      {
        'text':
            'Halo Petani Karawang! 👋 Saya AgroBrain Assistant. Saya siap membantu Anda menganalisis kondisi tanaman padi, merekomendasikan pupuk, atau cara mengatasi hama. Apa yang ingin Anda tanyakan?',
        'isUser': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      }
    ];
  }

  void addMessage(String text, bool isUser) {
    state = [
      ...state,
      {
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      }
    ];
  }

  void resetConversation() {
    state = _initialMessages();
  }

  Future<void> generateBotResponse(String query, String apiKey) async {
    final normalized = query.toLowerCase();

    // 1) Preferred: Local generative LLM via Ollama (offline)
    try {
      final ollama = LocalOllamaChatService();
      // baseUrl & model are configurable via providers (but generateBotResponse
      // currently receives only query+apiKey). We therefore keep default
      // values here; UI can be extended later to pass them.
      const ollamaBaseUrl = 'http://127.0.0.1:11434';
      const ollamaModel = 'llama3';

      final responseText = await ollama.generate(
        baseUrl: ollamaBaseUrl,
        model: ollamaModel,
        query: query,
        contextText: null,
      );

      if (responseText.trim().isNotEmpty) {
        addMessage(responseText.trim(), false);
        return;
      }
    } catch (e) {
      // If Ollama fails/unavailable, continue to rule-based fallback
    }

    // 2) Offline rule-based fallback (kept if Ollama fails)
    {
      // no-op block; fallthrough to rule-based code below
    }

    // Gemini path removed (disabled)

    // 3) Rule-based fallback (only when both Ollama and Gemini fail)
    String reply = '';

    if (normalized.contains('berlubang') ||
        normalized.contains('lubang') ||
        normalized.contains('bolong') ||
        normalized.contains('ulat')) {
      reply =
          'Halo! Daun padi yang berlubang biasanya menunjukkan adanya serangan hama pemakan daun, seperti **Ulat Grayak (Spodoptera litura)**, **Hama Putih Palsu**, atau ulat penggerek batang.\n\nBerikut analisis dan rekomendasi penanganan ala AI:\n\n1. **Penyebab Utama:** Hama ulat ini memotong daun padi dan memakannya pada malam hari, menyisakan lubang atau garis putih memendek/memanjang.\n2. **Tindakan Organik:** Semprotkan ekstrak daun nimba, gadung, atau pestisida nabati lainnya pada sore hari.\n3. **Tindakan Kimiawi:** Jika serangan sudah parah (kerusakan daun > 15%), semprotkan insektisida berbahan aktif *Klorantraniliprol* (contoh: Prevathon) atau *Deltametrin* dengan dosis 1.5 ml/liter air.\n\nSemoga sawah Anda lekas pulih! Jika ada gejala lain seperti perubahan warna daun, silakan kabari saya.';
    } else if (normalized.contains('kuning') ||
        normalized.contains('menguning')) {
      reply =
          'Halo! Gejala daun padi menguning bisa disebabkan oleh beberapa faktor berikut:\n\n1. **Kekurangan Unsur Nitrogen (N):** Ini penyebab paling umum. Daun bawah menguning merata lalu merambat ke atas. \n   *Solusi:* Segera aplikasikan pupuk Urea susulan sebanyak 100-150 kg/Ha.\n2. **Tanah Asam (pH Rendah):** pH tanah < 6.0 menghambat tanaman menyerap nitrogen.\n   *Solusi:* Taburkan kapur pertanian (Dolomit) sekitar 500 kg/Ha untuk menetralkan pH.\n3. **Penyakit Kerdil Kuning (Virus):** Ditularkan oleh wereng.\n   *Solusi:* Kendalikan populasi wereng penularnya.\n\nSebaiknya Anda memeriksa pH tanah sawah Anda di menu **Sawah** untuk memastikan penyebabnya!';
    } else if (normalized.contains('wereng') ||
        normalized.contains('cokelat')) {
      reply =
          'Halo! Serangan **Wereng Cokelat (Nilaparvata lugens)** sangat berbahaya dan harus ditangani dengan cepat agar tidak terjadi puso (gagal panen).\n\nLangkah-langkah penanganan taktis:\n\n1. **Keringkan Sawah:** Keringkan air sawah segera (metode irigasi intermittent) untuk mengurangi kelembaban di sekitar pangkal batang padi.\n2. **Aplikasi Insektisida:** Semprotkan insektisida sistemik berbahan aktif *Pimetrozin* (contoh merk: Plenum 50 WG) atau *Imidakloprid* dengan dosis 2 gram per liter air.\n3. **Teknik Penyemprotan:** Arahkan nozzle semprot ke pangkal batang padi, karena wereng bersembunyi dan menghisap cairan di area bawah batang.\n4. **Waspada Cuaca:** Selalu pantau sawah Anda, wereng dapat berkembang biak sangat cepat dalam cuaca lembab.';
    } else if (normalized.contains('pupuk') ||
        normalized.contains('pemupukan') ||
        normalized.contains('dosis')) {
      reply =
          'Halo! Pemupukan yang berimbang adalah kunci produktivitas padi di Karawang. Berikut rekomendasi jadwal pemupukan yang ideal:\n\n1. **Fase Awal/Tunas (7 - 14 HST):** \n   - Urea: 50-75 kg/ha\n   - NPK Ponska: 100-150 kg/ha\n   - *Tujuan:* Merangsang pertumbuhan akar dan anakan padi.\n2. **Fase Anakan Maksimum (25 - 30 HST):** \n   - Urea: 100 kg/ha\n   - *Tujuan:* Memperbanyak jumlah anakan produktif.\n3. **Fase Primordia/Bunting (40 - 45 HST):** \n   - Urea: 50 kg/ha\n   - NPK Ponska / KCl: 50 kg/ha\n   - *Tujuan:* Pengisian malai padi agar gabah berisi penuh dan tidak hampa.\n\nSesuaikan pemupukan dengan kondisi kelembaban tanah yang terpantau pada dashboard sawah Anda.';
    } else if (normalized.contains('blast') ||
        normalized.contains('jamur') ||
        normalized.contains('bercak')) {
      reply =
          'Halo! Bercak berbentuk belah ketupat pada daun padi atau patah leher pada malai mengindikasikan serangan **Penyakit Blast (Pyricularia oryzae)** yang disebabkan oleh jamur.\n\nCara mengatasi penyakit Blast:\n\n1. **Kurangi Nitrogen (Urea):** Hentikan sementara pemberian pupuk Nitrogen karena kadar N yang terlalu tinggi akan melunakkan jaringan tanaman dan mempermudah penetrasi spora jamur.\n2. **Semprot Fungisida:** Gunakan fungisida berbahan aktif *Trisiklazol* (contoh: Blast-off 75 WP) atau *Difenokonazol* dengan dosis 1 gr/liter air.\n3. **Sanitasi Lingkungan:** Bersihkan gulma di pematang sawah dan atur jarak tanam menggunakan metode Jajar Legowo untuk memperbaiki sirkulasi udara.\n\nSemoga penanganan ini membantu melindungi tanaman padi Anda!';
    } else if (normalized.contains('tikus')) {
      reply =
          'Halo! Hama tikus sawah (*Rattus argentiventer*) adalah salah satu tantangan terbesar petani Karawang. Penanganannya harus dilakukan secara bersama-sama (berkelompok).\n\nStrategi Pengendalian Tikus:\n1. **Gropyokan / Massal:** Lakukan perburuan tikus secara massal sebelum musim tanam dimulai.\n2. **TBS (Trap Barrier System):** Pasang petak perangkap tanaman penarik tikus yang dikelilingi pagar plastik dengan bubu perangkap di parit.\n3. **Umpan Beracun:** Gunakan rodentiisida jika populasi tikus sudah sangat tinggi di malam hari.\n4. **Predator Alami:** Pasang pagupon (rumah burung hantu *Tyto alba*) di sawah untuk membantu memangsa tikus secara alami.\n\nSemoga populasi tikus di sawah Anda segera terkendali!';
    } else if (normalized.contains('walang') || normalized.contains('sangit')) {
      reply =
          'Halo! Hama **Walang Sangit (Leptocorisa oratorius)** menyerang bulir padi muda pada fase masak susu, mengakibatkan bulir padi menjadi hampa atau berkualitas buruk.\n\n**Rekomendasi Penanganan:**\n1. **Pembersihan Gulma:** Bersihkan rumput liar di pematang sawah karena gulma menjadi inang alternatif walang sangit.\n2. **Pemasangan Umpan:** Pasang umpan berbau menyengat (seperti bangkai kepiting, keong mas, atau terasi) di tiang bambu sawah untuk menarik walang sangit berkumpul, kemudian musnahkan.\n3. **Semprot Insektisida:** Jika populasi tinggi, semprot dengan insektisida berbahan aktif *Fipronil* atau *Imidakloprid* pada pagi hari sebelum jam 09.00.';
    } else if (normalized.contains('keong') || normalized.contains('siput')) {
      reply =
          'Halo! Hama **Keong Mas (Pomacea canaliculata)** sangat merusak padi muda (usia 1-15 hari setelah tanam) dengan memotong batang tanaman padi.\n\n**Rekomendasi Penanganan:**\n1. **Metode Macak-Macak:** Keringkan air sawah sampai kondisi macak-macak (sedikit lembab) agar keong mas tidak aktif bergerak.\n2. **Pengambilan Manual:** Lakukan pemungutan keong mas dan telurnya yang berwarna merah muda di pematang sawah.\n3. **Pembuatan Parit Cacing:** Buat parit kecil di dalam petakan sawah agar keong berkumpul di parit tersebut saat sawah dikeringkan, memudahkan pemungutan.\n4. **Moluskisida:** Taburkan moluskisida berbahan aktif *Fentin Asetat* sebelum tanam.';
    } else if (normalized.contains('ph') ||
        normalized.contains('asam') ||
        normalized.contains('tanah')) {
      reply =
          'Halo! Tingkat keasaman (pH) tanah yang ideal untuk pertumbuhan optimal tanaman padi adalah **6.0 hingga 7.0**.\n\n**Gejala Tanah Terlalu Asam (pH < 5.5):**\n- Penyerapan unsur hara utama (N, P, K) terhambat.\n- Daun padi menguning kusam dan pertumbuhan tanaman menjadi kerdil.\n- Akumulasi racun zat besi (Fe) ditandai dengan bercak merah karat pada daun.\n\n**Solusi:** Taburkan **Kapur Pertanian (Dolomit)** secara merata sebanyak 500 - 1.000 kg per hektar saat proses pembajakan/pengolahan tanah awal.';
    } else if (normalized.contains('kresek') ||
        normalized.contains('hawar') ||
        normalized.contains('bakteri')) {
      reply =
          'Halo! Penyakit **Hawar Daun Bakteri (Kresek)** disebabkan oleh bakteri *Xanthomonas oryzae*, ditandai dengan daun mengering abu-abu dari ujung atau pinggir daun.\n\n**Rekomendasi Penanganan:**\n1. **Tunda Pupuk Urea:** Hentikan pemupukan Nitrogen (Urea) sementara karena Nitrogen tinggi melunakkan dinding sel tanaman, memudahkan bakteri masuk.\n2. **Irigasi Berselang (Intermittent):** Hindari menggenangi sawah terus-menerus. Keringkan sawah secara berkala untuk memutus siklus kelembaban bakteri.\n3. **Aplikasi Bakterisida:** Semprotkan bakterisida berbahan aktif *Tembaga Hidroksida* (contoh: Funguran/Kuproksat) sesuai dosis.';
    } else {
      reply =
          'Halo! Terkait pertanyaan Anda mengenai **"$query"**, berikut adalah analisis pertanian cerdas yang dapat membantu Anda:\n\n'
          '1. **Analisis Fisik:** Periksa bagian tanaman padi Anda. Apakah ada perubahan warna (daun menguning, bercak merah), kerusakan batang (membusuk/layu), atau bulir padi kosong.\n'
          '2. **Faktor Lingkungan:** Buka menu **Sawah** Anda untuk memantau pH dan tingkat kelembaban tanah saat ini. Kelembaban tinggi di cuaca mendung sangat mempercepat berkembangnya jamur/blast.\n'
          '3. **Manajemen Pemupukan & Air:** Lakukan pemupukan berimbang sesuai usia tanaman (HST) dan terapkan irigasi berselang (intermittent) untuk memperkokoh akar padi.\n\n'
          '💡 **Rekomendasi Taktis:**\n'
          '- Gunakan menu **Hama** untuk mengambil foto daun padi yang rusak secara langsung agar AI kami dapat menganalisis penyakit secara instan.\n'
          '- Berikan informasi tambahan seperti usia tanaman atau bagian gejala fisik spesifik (misalnya: bercak cokelat, daun menggulung, walang sangit) agar saya dapat memberikan solusi yang lebih presisi!';
    }

    addMessage(reply, false);
  }
}

// Ollama Host/Model Provider (replaces Gemini API key)
final ollamaHostProvider =
    StateProvider<String>((ref) => 'http://127.0.0.1:11434');
final ollamaModelProvider = StateProvider<String>((ref) => 'llama3');

final chatbotStateProvider =
    StateNotifierProvider<ChatbotNotifier, List<Map<String, dynamic>>>((ref) {
  return ChatbotNotifier();
});

// -----------------------------------------------------------------------------
// MARKET / PRICING STATE
// -----------------------------------------------------------------------------

class MarketItem {
  final String id;
  final String namaProduk;
  final String jenis; // Beras, Gabah, Pupuk
  final String kuantitas;
  final double harga;
  final String penjual;
  final String telepon;
  final String tanggal;

  MarketItem({
    required this.id,
    required this.namaProduk,
    required this.jenis,
    required this.kuantitas,
    required this.harga,
    required this.penjual,
    required this.telepon,
    required this.tanggal,
  });
}

class MarketNotifier extends StateNotifier<List<MarketItem>> {
  MarketNotifier() : super(_initialPostings());

  static List<MarketItem> _initialPostings() {
    return [
      MarketItem(
        id: 'post-1',
        namaProduk: 'Beras Pandan Wangi Super Karawang',
        jenis: 'Beras',
        kuantitas: '500 kg',
        harga: 14000.0,
        penjual: 'Bapak Jaka Supriadi',
        telepon: '08123456789',
        tanggal: 'Hari ini',
      ),
      MarketItem(
        id: 'post-2',
        namaProduk: 'Gabah Kering Giling (GKG) Inpari 32',
        jenis: 'Gabah',
        kuantitas: '3.500 kg',
        harga: 6800.0,
        penjual: 'Ibu Ningsih (Poktan Telukjambe)',
        telepon: '08579998881',
        tanggal: 'Kemarin',
      ),
      MarketItem(
        id: 'post-3',
        namaProduk: 'Beras Merah Organik Cilamaya',
        jenis: 'Beras',
        kuantitas: '200 kg',
        harga: 16500.0,
        penjual: 'Pak Slamet',
        telepon: '08988877712',
        tanggal: '2 hari lalu',
      ),
      MarketItem(
        id: 'post-4',
        namaProduk: 'Gabah Kering Panen (GKP) Ciherang Basah',
        jenis: 'Gabah',
        kuantitas: '5.000 kg',
        harga: 5700.0,
        penjual: 'Bapak Dadang',
        telepon: '08132223334',
        tanggal: '3 hari lalu',
      ),
    ];
  }

  void addPosting(MarketItem item) {
    state = [item, ...state];
  }
}

final marketPostingsProvider =
    StateNotifierProvider<MarketNotifier, List<MarketItem>>((ref) {
  return MarketNotifier();
});

final marketSearchQueryProvider = StateProvider<String>((ref) => '');
final marketCategoryFilterProvider = StateProvider<String>((ref) => 'Semua');
final currentTabProvider = StateProvider<int>((ref) => 0);
