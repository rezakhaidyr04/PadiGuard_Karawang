// File: lib/presentation/screens/chatbot/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state_providers.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage([String? text]) {
    final query = text ?? _messageController.text;
    if (query.trim().isEmpty) return;

    if (text == null) {
      _messageController.clear();
    }

    // Add user message
    ref.read(chatbotStateProvider.notifier).addMessage(query, true);
    _scrollToBottom();

    setState(() {
      _isTyping = true;
    });

    final apiKey = ref.read(ollamaHostProvider);

    // Simulate bot thinking delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      ref
          .read(chatbotStateProvider.notifier)
          .generateBotResponse(query, apiKey);
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatbotStateProvider);

    // Initial scroll when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asisten Tani AI AgroBrain',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 3.5, backgroundColor: AppColors.success),
                    SizedBox(width: 4),
                    Text('Aktif Melayani',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontFamily: 'InterTight')),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => _confirmResetChat(context),
            tooltip: 'Mulai ulang percakapan',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            onPressed: () => _showApiKeyDialog(context),
            tooltip: 'Konfigurasi Gemini AI',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat history List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final message = messages[index];
                return _buildMessageBubble(context, message);
              },
            ),
          ),

          // Bottom Bar Input & Quick Suggestions
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: SafeArea(
              child: Column(
                children: [
                  // Quick Suggestions row
                  if (messages.length == 1 && !_isTyping) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Paling Sering Ditanyakan:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          fontFamily: 'InterTight',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _suggestionChip('🍂 Daun menguning',
                              'Daun padi saya menguning, pupuk apa yang harus diberikan?'),
                          const SizedBox(width: 8),
                          _suggestionChip('🐛 Hama wereng',
                              'Bagaimana cara mengatasi hama wereng cokelat?'),
                          const SizedBox(width: 8),
                          _suggestionChip('🧪 Rekomendasi pupuk',
                              'Apa saja pupuk padi terbaik untuk Karawang?'),
                          const SizedBox(width: 8),
                          _suggestionChip('🍄 Penyakit blast',
                              'Bagaimana cara mengatasi penyakit blast leher pada padi?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Text Box & Send Button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 1,
                          style: const TextStyle(
                              fontSize: 14, fontFamily: 'InterTight'),
                          decoration: InputDecoration(
                            hintText:
                                'Ketik pertanyaan Anda tentang pertanian...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor:
                                AppColors.surfaceVariant.withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _sendMessage(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label, String query) {
    return ActionChip(
      label: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary)),
      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _sendMessage(query),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final bool isUser = msg['isUser'] as bool;
    final DateTime dt = msg['timestamp'] as DateTime;
    final String timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] as String,
              style: TextStyle(
                fontSize: 13.5,
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.45,
                fontFamily: 'InterTight',
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 9,
                  color: isUser ? Colors.white70 : AppColors.textHint,
                  fontFamily: 'InterTight',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AgroBrain sedang mengetik',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamily: 'InterTight'),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Reset Percakapan',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Poppins'),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua chat dan memulai ulang percakapan?',
          style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'InterTight'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(chatbotStateProvider.notifier).resetConversation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final currentKey = ref.read(ollamaHostProvider);

    final keyController = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Konfigurasi Gemini AI',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key Anda untuk mengaktifkan kecerdasan buatan asli (Gemini 1.5 Flash).',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                  fontFamily: 'InterTight'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Masukkan kunci API Gemini...',
                prefixIcon: Icon(Icons.key_rounded, color: AppColors.primary),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dapatkan API Key gratis di Google AI Studio:',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontFamily: 'InterTight'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const SelectableText(
              'https://aistudio.google.com/',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  fontFamily: 'InterTight'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ollamaHostProvider.notifier).state =
                  keyController.text.trim();

              Navigator.pop(context);

              final isKeyEmpty = keyController.text.trim().isEmpty;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isKeyEmpty
                      ? '✓ Menggunakan AI Simulator Offline'
                      : '✓ Gemini AI Aktif Terhubung!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
