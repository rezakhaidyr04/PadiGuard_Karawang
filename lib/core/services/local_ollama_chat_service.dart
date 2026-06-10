import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Local chat client using Ollama-compatible HTTP API.
///
/// Assumptions:
/// - Ollama is running and accessible from the device.
/// - Default baseUrl uses localhost.
class LocalOllamaChatService {
  final Logger _logger;
  final Dio _dio;

  LocalOllamaChatService({
    Logger? logger,
    Dio? dio,
  })  : _logger = logger ?? Logger(),
        _dio = dio ?? Dio();

  /// Generate response using Ollama.
  ///
  /// Uses the /api/generate endpoint.
  /// For chat history, we currently send only the latest [query] + [contextText]
  /// to keep payload simple.
  Future<String> generate({
    required String baseUrl,
    required String model,
    required String query,
    String? contextText,
    int timeoutMs = 30000,
  }) async {
    final trimmedBaseUrl = baseUrl.trim().replaceAll(RegExp(r"/$"), '');

    const systemInstruction =
        'Anda adalah Asisten Tani AI AgroBrain, ahli agronomi khusus untuk petani di Kabupaten Karawang, Jawa Barat. '
        'Berikan jawaban yang taktis, ramah, dan sangat berguna dalam bahasa Indonesia. '
        'Gunakan format Markdown rapi dengan tebal (bold), poin-poin (bullet), dan emoji. '
        'Jika informasi kurang, berikan pertanyaan klarifikasi singkat di akhir.';

    final promptBuffer = StringBuffer();
    promptBuffer.writeln(systemInstruction);
    if (contextText != null && contextText.trim().isNotEmpty) {
      promptBuffer.writeln();
      promptBuffer.writeln('Konteks tambahan dari sistem (opsional):');
      promptBuffer.writeln(contextText.trim());
    }
    promptBuffer.writeln();
    promptBuffer.writeln('Pertanyaan pengguna:');
    promptBuffer.writeln(query.trim());

    final prompt = promptBuffer.toString();

    _logger.i('Ollama request => $trimmedBaseUrl model=$model');

    // Ollama /api/generate response format:
    // {"response":"...","done":true,...}
    final response = await _dio.post(
      '$trimmedBaseUrl/api/generate',
      data: {
        'model': model,
        'prompt': prompt,
        'stream': false,
        // You can tweak these for better Indonesian outputs
        'options': {
          'temperature': 0.4,
          'num_predict': 600,
        },
      },
      options: Options(
        sendTimeout: Duration(milliseconds: timeoutMs),
        receiveTimeout: Duration(milliseconds: timeoutMs),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Ollama HTTP error: ${response.statusCode}');
    }

    final data = response.data;
    final text = (data is Map<String, dynamic>) ? data['response'] : null;

    if (text is String && text.trim().isNotEmpty) {
      return text.trim();
    }

    // Some Ollama setups return as different structures; best effort.
    return text?.toString().trim() ??
        'Maaf, saya belum bisa menghasilkan jawaban saat ini.';
  }
}
