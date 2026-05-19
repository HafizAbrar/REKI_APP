import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 1;
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    await ref.read(authStateProvider.notifier).forgotPassword(email);
  }

  Future<void> _resetPassword() async {
    final token = _tokenController.text.trim();
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    if (token.isEmpty || newPass.isEmpty) return;
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Passwords do not match'), backgroundColor: Colors.red[700]),
      );
      return;
    }
    await ref.read(authStateProvider.notifier).resetPassword(token, newPass);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next is AuthStateForgotPasswordSuccess && _step == 1) {
        setState(() => _step = 2);
      } else if (next is AuthStateResetPasswordSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Password reset successfully!'), backgroundColor: Colors.green[700]),
        );
        context.go('/login');
      } else if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red[700]),
        );
      }
    });

    final isLoading = ref.watch(authStateProvider) is AuthStateLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => _step == 2 ? setState(() => _step = 1) : context.pop(),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _stepDot(1),
                      _stepLine(),
                      _stepDot(2),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_step == 1) ...[
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your email and we\'ll send a reset code.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    const SizedBox(height: 36),
                    _inputField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    _primaryButton(label: 'Send Reset Code', isLoading: isLoading, onPressed: _requestReset),
                  ] else ...[
                    const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the code sent to your email and choose a new password.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mail_outline, color: AppTheme.primaryColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _emailController.text.trim(),
                            style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _inputField(controller: _tokenController, hint: 'Reset Code', icon: Icons.pin_outlined),
                    const SizedBox(height: 16),
                    _inputField(
                      controller: _newPasswordController,
                      hint: 'New Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm New Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 28),
                    _primaryButton(label: 'Reset Password', isLoading: isLoading, onPressed: _resetPassword),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => ref.read(authStateProvider.notifier).forgotPassword(_emailController.text.trim()),
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int step) {
    final active = _step >= step;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppTheme.primaryColor : const Color(0xFF334155),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: active ? AppTheme.darkBg : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _stepLine() => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: _step == 2 ? AppTheme.primaryColor : const Color(0xFF334155),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: onToggle,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9999), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, required bool isLoading, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.darkBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            elevation: 0,
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBg))
              : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
