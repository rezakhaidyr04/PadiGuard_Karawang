import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'auth/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _riceWaveController;
  late AnimationController _particleController;

  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _progressAnim;
  late Animation<double> _riceWave;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _riceWaveController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeIn = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _riceWave = CurvedAnimation(
      parent: _riceWaveController,
      curve: Curves.easeInOut,
    );

    _mainController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _riceWaveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              return CustomPaint(
                size: size,
                painter: _ParticlePainter(_particleController.value),
              );
            },
          ),

          // Animated rice wave at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _riceWave,
              builder: (_, __) => SizedBox(
                height: 160,
                child: CustomPaint(
                  painter: _RiceWavePainter(_riceWave.value),
                  size: Size(size.width, 160),
                ),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo area
                  ScaleTransition(
                    scale: _scaleIn,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'app-logo',
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF81C784)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🌾',
                                style: TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SlideTransition(
                          position: _slideUp,
                          child: Column(
                            children: [
                              const Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Text(
                                  'AI Smart Farming untuk Petani Karawang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Feature pills
                  SlideTransition(
                    position: _slideUp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _featurePill('🤖 AI Deteksi Hama'),
                          const SizedBox(width: 8),
                          _featurePill('📊 Analitik Sawah'),
                          const SizedBox(width: 8),
                          _featurePill('💹 Harga Pasar'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading progress
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              minHeight: 5,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mempersiapkan sistem AI...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Rice Wave Painter ───────────────────────────────────────────────────────
class _RiceWavePainter extends CustomPainter {
  final double progress;
  _RiceWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint1, 0.6, progress, 40);
    _drawWave(canvas, size, paint2, 0.7, 1 - progress, 30);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double heightRatio,
      double offset, double amplitude) {
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * heightRatio +
          amplitude * math.sin((x / size.width * 2 * math.pi) + (offset * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RiceWavePainter old) =>
      old.progress != progress;
}

// ─── Particle Painter ────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final y = (baseY - progress * size.height * speed) % size.height;
      final radius = 1.5 + rng.nextDouble() * 3;
      final opacity = 0.05 + rng.nextDouble() * 0.12;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y < 0 ? y + size.height : y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
