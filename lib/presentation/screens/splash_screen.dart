import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'auth/login_screen.dart';

/// Splash Screen with simple animation
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations for splash branding
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animationController.forward();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkUserStatus() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _goToLogin();
    });
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 550),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LoginScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'app-logo',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success,
                                AppColors.successLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.agriculture_rounded,
                              size: 60,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI Smart Farming Asisten Berbasis Smartphone',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary.withValues(alpha: 0.9),
                            ),
                            backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
