// Test file untuk memverifikasi panen_service bekerja di FlutLab
// Buka file ini dan run untuk test

import 'package:karawang_agrobrain/data/services/panen_service.dart';

void main() async {
  print('=== TESTING PANEN SERVICE ===\n');

  // Initialize service
  final panenService = PanenService();
  print('✅ PanenService initialized\n');

  // Test 1: Normal conditions
  print('📊 TEST 1: Normal Conditions');
  print('Input: kelembaban=65%, pH=6.8, umur=75 hari');
  final result1 = await panenService.predictHarvestFailure(
    sawahId: 'test-001',
    userId: 'user-001',
    kelembaban: 65.0,
    ph: 6.8,
    umurTanamanHari: 75,
    cuacaSaat: 'Cerah',
    estimasiTanggalPanen: DateTime.now().add(const Duration(days: 30)),
    estimasiHasilTon: 5.5,
  );

  if (result1 != null) {
    print('✅ Result 1 Success!');
    print('   - Risiko: ${result1.persentaseRisikoGagal}%');
    print('   - Score: ${result1.scoreKesehatan}');
    print('   - Penyebab: ${result1.penyebabRisiko}');
    print('   - Rekomendasi: ${result1.rekomendasi}\n');
  } else {
    print('❌ Result 1 Failed!\n');
  }

  // Test 2: Dry conditions
  print('📊 TEST 2: Dry Conditions');
  print('Input: kelembaban=25%, pH=6.5, umur=60 hari');
  final result2 = await panenService.predictHarvestFailure(
    sawahId: 'test-002',
    userId: 'user-001',
    kelembaban: 25.0,
    ph: 6.5,
    umurTanamanHari: 60,
    cuacaSaat: 'Panas',
    estimasiTanggalPanen: DateTime.now().add(const Duration(days: 30)),
    estimasiHasilTon: 4.0,
  );

  if (result2 != null) {
    print('✅ Result 2 Success!');
    print('   - Risiko: ${result2.persentaseRisikoGagal}%');
    print('   - Score: ${result2.scoreKesehatan}');
    print('   - Penyebab: ${result2.penyebabRisiko}');
    print('   - Rekomendasi: ${result2.rekomendasi}\n');
  } else {
    print('❌ Result 2 Failed!\n');
  }

  // Test 3: Wet conditions
  print('📊 TEST 3: Wet Conditions');
  print('Input: kelembaban=92%, pH=5.2, umur=80 hari');
  final result3 = await panenService.predictHarvestFailure(
    sawahId: 'test-003',
    userId: 'user-001',
    kelembaban: 92.0,
    ph: 5.2,
    umurTanamanHari: 80,
    cuacaSaat: 'Hujan',
    estimasiTanggalPanen: DateTime.now().add(const Duration(days: 30)),
    estimasiHasilTon: 4.5,
  );

  if (result3 != null) {
    print('✅ Result 3 Success!');
    print('   - Risiko: ${result3.persentaseRisikoGagal}%');
    print('   - Score: ${result3.scoreKesehatan}');
    print('   - Penyebab: ${result3.penyebabRisiko}');
    print('   - Rekomendasi: ${result3.rekomendasi}\n');
  } else {
    print('❌ Result 3 Failed!\n');
  }

  // Test 4: Ideal conditions
  print('📊 TEST 4: Ideal Conditions');
  print('Input: kelembaban=70%, pH=6.5, umur=50 hari');
  final result4 = await panenService.predictHarvestFailure(
    sawahId: 'test-004',
    userId: 'user-001',
    kelembaban: 70.0,
    ph: 6.5,
    umurTanamanHari: 50,
    cuacaSaat: 'Cerah',
    estimasiTanggalPanen: DateTime.now().add(const Duration(days: 50)),
    estimasiHasilTon: 6.0,
  );

  if (result4 != null) {
    print('✅ Result 4 Success!');
    print('   - Risiko: ${result4.persentaseRisikoGagal}%');
    print('   - Score: ${result4.scoreKesehatan}');
    print('   - Penyebab: ${result4.penyebabRisiko}');
    print('   - Rekomendasi: ${result4.rekomendasi}\n');
  } else {
    print('❌ Result 4 Failed!\n');
  }

  // Final summary
  print('=== TEST SUMMARY ===');
  int successCount = 0;
  if (result1 != null) successCount++;
  if (result2 != null) successCount++;
  if (result3 != null) successCount++;
  if (result4 != null) successCount++;

  print('✅ $successCount / 4 tests passed');

  if (successCount == 4) {
    print('🎉 ALL TESTS PASSED! Service is 100% ready for FlutLab!');
  } else {
    print('⚠️  Some tests failed. Check the output above.');
  }
}
