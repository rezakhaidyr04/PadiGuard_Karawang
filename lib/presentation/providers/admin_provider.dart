// File: lib/presentation/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Admin User Model (untuk daftar user terdaftar) ───────────────────────────
class AdminUserData {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String district;
  final String village;
  final int totalSawah;
  final DateTime createdAt;
  final bool isActive;

  AdminUserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.district,
    required this.village,
    required this.totalSawah,
    required this.createdAt,
    required this.isActive,
  });
}

// ─── Admin Harga Komoditas Model ──────────────────────────────────────────────
class AdminHargaData {
  final String id;
  final String namaKomoditas;
  final double hargaSaatIni;
  final double hargaSebelumnya;
  final String tren;
  final String lokasi;
  final DateTime tanggalUpdate;

  AdminHargaData({
    required this.id,
    required this.namaKomoditas,
    required this.hargaSaatIni,
    required this.hargaSebelumnya,
    required this.tren,
    required this.lokasi,
    required this.tanggalUpdate,
  });

  double get perubahanPersen =>
      hargaSebelumnya == 0
          ? 0
          : ((hargaSaatIni - hargaSebelumnya) / hargaSebelumnya) * 100;

  AdminHargaData copyWith({
    String? id,
    String? namaKomoditas,
    double? hargaSaatIni,
    double? hargaSebelumnya,
    String? tren,
    String? lokasi,
    DateTime? tanggalUpdate,
  }) {
    return AdminHargaData(
      id: id ?? this.id,
      namaKomoditas: namaKomoditas ?? this.namaKomoditas,
      hargaSaatIni: hargaSaatIni ?? this.hargaSaatIni,
      hargaSebelumnya: hargaSebelumnya ?? this.hargaSebelumnya,
      tren: tren ?? this.tren,
      lokasi: lokasi ?? this.lokasi,
      tanggalUpdate: tanggalUpdate ?? this.tanggalUpdate,
    );
  }
}

// ─── Admin Users Notifier ─────────────────────────────────────────────────────
class AdminUsersNotifier extends StateNotifier<List<AdminUserData>> {
  AdminUsersNotifier() : super(_mockUsers());

  static List<AdminUserData> _mockUsers() {
    final now = DateTime.now();
    return [
      AdminUserData(
        uid: 'user-001',
        name: 'Bapak Jaka Supriadi',
        email: 'jaka.supriadi@gmail.com',
        role: 'farmer',
        district: 'Karawang',
        village: 'Telukjambe Timur',
        totalSawah: 3,
        createdAt: now.subtract(const Duration(days: 90)),
        isActive: true,
      ),
      AdminUserData(
        uid: 'user-002',
        name: 'Ibu Ningsih Rahayu',
        email: 'ningsih.poktan@gmail.com',
        role: 'farmer',
        district: 'Karawang',
        village: 'Tempuran',
        totalSawah: 2,
        createdAt: now.subtract(const Duration(days: 60)),
        isActive: true,
      ),
      AdminUserData(
        uid: 'user-003',
        name: 'Pak Slamet Riyadi',
        email: 'slamet.cilamaya@yahoo.com',
        role: 'farmer',
        district: 'Karawang',
        village: 'Cilamaya Wetan',
        totalSawah: 1,
        createdAt: now.subtract(const Duration(days: 45)),
        isActive: true,
      ),
      AdminUserData(
        uid: 'user-004',
        name: 'Bapak Dadang Suryadi',
        email: 'dadang.rdk@gmail.com',
        role: 'farmer',
        district: 'Karawang',
        village: 'Rengasdengklok',
        totalSawah: 4,
        createdAt: now.subtract(const Duration(days: 30)),
        isActive: true,
      ),
      AdminUserData(
        uid: 'user-005',
        name: 'Ibu Siti Nurhaliza',
        email: 'siti.purwasari@gmail.com',
        role: 'penyuluh',
        district: 'Karawang',
        village: 'Purwasari',
        totalSawah: 0,
        createdAt: now.subtract(const Duration(days: 20)),
        isActive: true,
      ),
      AdminUserData(
        uid: 'user-006',
        name: 'Pak Ahmad Fauzi',
        email: 'ahmad.klari@gmail.com',
        role: 'farmer',
        district: 'Karawang',
        village: 'Klari',
        totalSawah: 2,
        createdAt: now.subtract(const Duration(days: 15)),
        isActive: false,
      ),
    ];
  }

  void toggleUserStatus(String uid) {
    state = [
      for (final u in state)
        if (u.uid == uid)
          AdminUserData(
            uid: u.uid,
            name: u.name,
            email: u.email,
            role: u.role,
            district: u.district,
            village: u.village,
            totalSawah: u.totalSawah,
            createdAt: u.createdAt,
            isActive: !u.isActive,
          )
        else
          u
    ];
  }
}

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, List<AdminUserData>>(
  (ref) => AdminUsersNotifier(),
);

// ─── Admin Harga Notifier ─────────────────────────────────────────────────────
class AdminHargaNotifier extends StateNotifier<List<AdminHargaData>> {
  AdminHargaNotifier() : super(_mockHarga());

  static List<AdminHargaData> _mockHarga() {
    final now = DateTime.now();
    return [
      AdminHargaData(
        id: 'harga-1',
        namaKomoditas: 'Gabah Kering Panen (GKP)',
        hargaSaatIni: 5900,
        hargaSebelumnya: 5750,
        tren: 'naik',
        lokasi: 'Karawang',
        tanggalUpdate: now,
      ),
      AdminHargaData(
        id: 'harga-2',
        namaKomoditas: 'Gabah Kering Giling (GKG)',
        hargaSaatIni: 6850,
        hargaSebelumnya: 6900,
        tren: 'turun',
        lokasi: 'Karawang',
        tanggalUpdate: now,
      ),
      AdminHargaData(
        id: 'harga-3',
        namaKomoditas: 'Beras Medium',
        hargaSaatIni: 11500,
        hargaSebelumnya: 11500,
        tren: 'stabil',
        lokasi: 'Karawang',
        tanggalUpdate: now.subtract(const Duration(hours: 2)),
      ),
      AdminHargaData(
        id: 'harga-4',
        namaKomoditas: 'Beras Premium',
        hargaSaatIni: 14000,
        hargaSebelumnya: 13500,
        tren: 'naik',
        lokasi: 'Karawang',
        tanggalUpdate: now.subtract(const Duration(hours: 4)),
      ),
      AdminHargaData(
        id: 'harga-5',
        namaKomoditas: 'Jagung Pipilan Kering',
        hargaSaatIni: 4200,
        hargaSebelumnya: 4350,
        tren: 'turun',
        lokasi: 'Karawang',
        tanggalUpdate: now.subtract(const Duration(hours: 6)),
      ),
      AdminHargaData(
        id: 'harga-6',
        namaKomoditas: 'Kedelai Lokal',
        hargaSaatIni: 9500,
        hargaSebelumnya: 9200,
        tren: 'naik',
        lokasi: 'Karawang',
        tanggalUpdate: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  void addHarga(AdminHargaData harga) {
    state = [harga, ...state];
  }

  void updateHarga(AdminHargaData updated) {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h
    ];
  }

  void deleteHarga(String id) {
    state = state.where((h) => h.id != id).toList();
  }
}

final adminHargaProvider =
    StateNotifierProvider<AdminHargaNotifier, List<AdminHargaData>>(
  (ref) => AdminHargaNotifier(),
);

// ─── Admin Stats Provider ─────────────────────────────────────────────────────
class AdminStats {
  final int totalUsers;
  final int totalSawah;
  final int totalDeteksi;
  final int totalHargaEntri;
  final int userAktifBulanIni;
  final int deteksiHamaTinggi;

  const AdminStats({
    required this.totalUsers,
    required this.totalSawah,
    required this.totalDeteksi,
    required this.totalHargaEntri,
    required this.userAktifBulanIni,
    required this.deteksiHamaTinggi,
  });
}

final adminStatsProvider = Provider<AdminStats>((ref) {
  final users = ref.watch(adminUsersProvider);
  final hargaList = ref.watch(adminHargaProvider);

  final totalSawah = users.fold<int>(0, (sum, u) => sum + u.totalSawah);
  final aktifCount = users.where((u) => u.isActive).length;

  return AdminStats(
    totalUsers: users.length,
    totalSawah: totalSawah,
    totalDeteksi: 3, // mock: 3 deteksi dari app_state_providers
    totalHargaEntri: hargaList.length,
    userAktifBulanIni: aktifCount,
    deteksiHamaTinggi: 2, // mock: 2 deteksi risiko TINGGI
  );
});
