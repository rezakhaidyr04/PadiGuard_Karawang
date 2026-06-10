import 'package:flutter_test/flutter_test.dart';
import 'package:karawang_agrobrain/data/services/harga_service.dart';

void main() {
  group('HargaService', () {
    test('predictHargaMingguDepan returns 7-day forecast and respects trend', () async {
      final svc = HargaService();
      final forecast = await svc.predictHargaMingguDepan(
        komoditas: 'Gabah',
        hargaSekarang: 100.0,
        hargaSebelumnya: [90.0, 95.0, 100.0],
      );

      expect(forecast.length, 7);

      // trend = (100 - 90) / 3 = 3.3333..., so hari_1 ~ 103.3333
      const expectedDay1 = 100.0 + ((100.0 - 90.0) / 3.0) * 1;
      expect(forecast['hari_1']!, closeTo(expectedDay1, 0.01));
    });

    test('predictHargaMingguDepan clamps negative prices to 0', () async {
      final svc = HargaService();
      final forecast = await svc.predictHargaMingguDepan(
        komoditas: 'Beras',
        hargaSekarang: 1.0,
        hargaSebelumnya: [-1000.0, -900.0],
      );

      // All predicted prices should be >= 0
      expect(forecast.values.every((v) => v >= 0), isTrue);
    });
  });
}
