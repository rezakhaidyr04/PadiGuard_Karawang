import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state_providers.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  late AnimationController _typingController;
  late Animation<double> _dot1, _dot2, _dot3;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dot1 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _typingController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeInOut)));
    _dot2 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _typingController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeInOut)));
    _dot3 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _typingController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage([String? preset]) {
    final text = preset ?? _controller.text.trim();
    if (text.isEmpty) return;
    if (preset == null) _controller.clear();

    ref.read(chatbotStateProvider.notifier).addMessage(text, true);
    setState(() => _isTyping = true);
    _scrollToBottom();

    final host = ref.read(ollamaHostProvider);
    final model = ref.read(ollamaModelProvider);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      ref.read(chatbotStateProvider.notifier).generateBotResponse(
            text,
            ollamaHost: host,
            ollamaModel: model,
          );
      setState(() => _isTyping = false);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatbotStateProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _MessageBubble(
                  msg: messages[i],
                  key: ValueKey(i),
                );
              },
            ),
          ),
          _buildInputArea(messages),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.lushGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AgroBrain AI',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Aktif Melayani Petani',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          tooltip: 'Reset Percakapan',
          onPressed: () => _showResetDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
          tooltip: 'Konfigurasi AI',
          onPressed: () => _showSettingsDialog(),
        ),
      ],
    );
  }

  Widget _buildInputArea(List<Map<String, dynamic>> messages) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick suggestion chips (only first load)
            if (messages.length == 1 && !_isTyping) ...[
              const Text(
                'Topik Populer:',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _chip('🌾 Daun kuning',
                        'Daun padi saya menguning, apa penyebabnya?'),
                    _chip('🪲 Hama wereng',
                        'Cara mengatasi serangan wereng cokelat?'),
                    _chip('🧪 Pupuk padi',
                        'Jadwal dan dosis pemupukan padi yang benar?'),
                    _chip('🍄 Penyakit blast',
                        'Bagaimana cara mengatasi blast leher padi?'),
                    _chip('🐀 Hama tikus', 'Cara efektif mengusir tikus sawah?'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(
                          fontSize: 14, fontFamily: 'Inter', color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Tanya tentang padi, hama, pupuk...',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontFamily: 'Inter'),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.lushGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
    );
  }

  Widget _chip(String label, String query) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontFamily: 'Inter'),
        backgroundColor: AppColors.surfaceGreen,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _sendMessage(query),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _typingController,
              builder: (_, __) => Row(
                children: [
                  _dot(_dot1.value),
                  const SizedBox(width: 4),
                  _dot(_dot2.value),
                  const SizedBox(width: 4),
                  _dot(_dot3.value),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('mengetik...',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  Widget _dot(double val) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.3 + val * 0.7),
        shape: BoxShape.circle,
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Reset Percakapan?',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        content: const Text(
          'Semua pesan akan dihapus dan percakapan dimulai ulang.',
          style: TextStyle(fontFamily: 'Inter'),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final hostCtrl =
        TextEditingController(text: ref.read(ollamaHostProvider));
    final modelCtrl =
        TextEditingController(text: ref.read(ollamaModelProvider));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Text('⚙️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Konfigurasi Local AI',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Konfigurasikan server Ollama lokal Anda untuk mengaktifkan chatbot AI offline.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hostCtrl,
              decoration: const InputDecoration(
                labelText: 'Ollama Host URL',
                hintText: 'http://127.0.0.1:11434',
                prefixIcon: Icon(Icons.dns_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: 'llama3, gemma, mistral',
                prefixIcon:
                    Icon(Icons.model_training_rounded, color: AppColors.primary),
              ),
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
                  hostCtrl.text.trim();
              ref.read(ollamaModelProvider.notifier).state =
                  modelCtrl.text.trim();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Konfigurasi AI disimpan!'),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;

  const _MessageBubble({required this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUser = msg['isUser'] as bool;
    final DateTime dt = msg['timestamp'] as DateTime;
    final String time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppColors.lushGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser
                    ? AppColors.lushGradient
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                      color: isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 9,
                        color: isUser
                            ? Colors.white70
                            : AppColors.textHint,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
