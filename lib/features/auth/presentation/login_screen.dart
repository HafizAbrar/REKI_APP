import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref.read(authStateProvider.notifier).login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStateLoginSuccess) {
        final user = ref.read(authNotifierProvider).currentUser;
        if (user != null) {
          switch (user.role) {
            case UserRole.ADMIN:
              context.go('/admin-dashboard');
            case UserRole.BUSINESS:
              context.go('/business-dashboard');
            case UserRole.USER:
              context.go('/personalize');
          }
        } else {
          context.go('/personalize');
        }
      } else if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthStateLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAbUJHdVYXEM5nb7gdCJuVW7JCDHX57JIbHlYa1QpCwLUn3IQ18tWdOP6jjy3OzZFeql3aQIRSc8wPeA8vaC6vRU3T_5DxF_C73GGcJIfrB1ITMzi9x8PXpXmxXCfSpxFffphHCdnz0ZqfuDGZKFvKzy6FldO8KPMejI_K6IPmQc2plM0xNFnJs5m-WKeFdub0DJzwa6N37lz-xVZjkCCXVWncXp2ZAd7Fua4l0bLXe22WfCLqtsp83Ep1GvowtKY7ZneCKhcWUxEBs'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0.7),
                    const Color(0xFF0F172A).withOpacity(0.95),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo with glow
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryHover],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.39),
                          blurRadius: 14,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.equalizer, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'REKI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover the vibe.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8), // slate-400
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Email input
                  _buildInputField(
                    controller: _emailController,
                    hint: 'Email or Phone Number',
                    icon: Icons.mail,
                  ),
                  const SizedBox(height: 20),
                  // Password input
                  _buildInputField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.39),
                            blurRadius: 14,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.darkBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.darkBg,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFF334155))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: Color(0xFF64748B), // slate-500
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(Icons.apple),
                      const SizedBox(width: 24),
                      _socialButton(Icons.g_mobiledata),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Explore as guest button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF475569), width: 1), // slate-600
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () => context.push('/signup'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore as Guest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Token input link
                  TextButton(
                    onPressed: () => context.push('/token-input'),
                    child: const Text(
                      'Login with Token',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Terms text
                  const Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF475569),
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF475569),
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFCCCCCC), size: 24),
        onPressed: () {},
      ),
    );
  }
}
