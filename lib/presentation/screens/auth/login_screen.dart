import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../home/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulasi loading — bypass langsung ke dashboard
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Green wave shape at top
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: -80,
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
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Top logo area
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'app-logo',
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.agriculture_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI Smart Farming Asisten Berbasis Smartphone',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // White card form
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat Datang 👋',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Masuk untuk melanjutkan ke dashboard',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email wajib diisi';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'contoh@email.com',
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: AppColors.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Kata sandi wajib diisi';
                                    }
                                    if (v.length < 6) {
                                      return 'Minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Kata Sandi',
                                    hintText: 'Masukkan kata sandi',
                                    prefixIcon: const Icon(Icons.lock_outlined,
                                        color: AppColors.primary),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Lupa Kata Sandi?',
                                      style:
                                          TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Divider
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'atau',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Skip / Demo button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              const DashboardScreen(),
                                          transitionsBuilder:
                                              (_, anim, __, child) =>
                                                  FadeTransition(
                                                      opacity: anim,
                                                      child: child),
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Coba Demo Tanpa Login'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Register link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Belum punya akun? ',
                                      style: TextStyle(
                                          color: AppColors.textSecondary),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        'Daftar Sekarang',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
