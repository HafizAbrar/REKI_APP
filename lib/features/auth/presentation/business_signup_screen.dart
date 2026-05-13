import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

const _venueCategories = ['bar', 'restaurant', 'club', 'casino', 'cafe', 'other'];

class BusinessSignupScreen extends ConsumerStatefulWidget {
  const BusinessSignupScreen({super.key});

  @override
  ConsumerState<BusinessSignupScreen> createState() => _BusinessSignupScreenState();
}

class _BusinessSignupScreenState extends ConsumerState<BusinessSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _venueAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCategory = 'bar';
  bool _obscurePassword = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _venueNameError;
  String? _venueAddressError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final venueName = _venueNameController.text.trim();
    final venueAddress = _venueAddressController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Please enter your full name.' : null;
      _emailError = email.isEmpty ? 'Please enter your business email.' : null;
      _passwordError = password.isEmpty ? 'Please enter a password.' : null;
      _venueNameError = venueName.isEmpty ? 'Please enter your venue name.' : null;
      _venueAddressError = venueAddress.isEmpty ? 'Please enter your venue address.' : null;
    });

    if (_nameError != null || _emailError != null || _passwordError != null ||
        _venueNameError != null || _venueAddressError != null) return;

    await ref.read(authStateProvider.notifier).registerBusiness(
      email: email,
      password: password,
      name: name,
      venueName: venueName,
      venueAddress: venueAddress,
      venueCategory: _selectedCategory,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next is AuthStateRegisterSuccess) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2DD4BF), size: 56),
                const SizedBox(height: 16),
                const Text('Business Registered!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Your business account has been approved. You can now log in.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
                    ),
                    onPressed: () { Navigator.pop(context); context.go('/business-login'); },
                    child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red[700]),
        );
      }
    });

    final isLoading = ref.watch(authStateProvider) is AuthStateLoading;

    return ValueListenableBuilder(
      valueListenable: _nameController,
      builder: (context, _, __) => ValueListenableBuilder(
        valueListenable: _emailController,
        builder: (context, _, __) => ValueListenableBuilder(
          valueListenable: _passwordController,
          builder: (context, _, __) => ValueListenableBuilder(
            valueListenable: _venueNameController,
            builder: (context, _, __) => ValueListenableBuilder(
              valueListenable: _venueAddressController,
              builder: (context, _, __) {
                final canSubmit = _nameController.text.trim().isNotEmpty &&
                    _emailController.text.trim().isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _venueNameController.text.trim().isNotEmpty &&
                    _venueAddressController.text.trim().isNotEmpty;
                return _buildScaffold(isLoading, canSubmit);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(bool isLoading, bool canSubmit) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAbUJHdVYXEM5nb7gdCJuVW7JCDHX57JIbHlYa1QpCwLUn3IQ18tWdOP6jjy3OzZFeql3aQIRSc8wPeA8vaC6vRU3T_5DxF_C73GGcJIfrB1ITMzi9x8PXpXmxXCfSpxFffphHCdnz0ZqfuDGZKFvKzy6FldO8KPMejI_K6IPmQc2plM0xNFnJs5m-WKeFdub0DJzwa6N37lz-xVZjkCCXVWncXp2ZAd7Fua4l0bLXe22WfCLqtsp83Ep1GvowtKY7ZneCKhcWUxEBs',
                  ),
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
                    AppTheme.darkBg.withOpacity(0.7),
                    AppTheme.darkBg.withOpacity(0.95),
                    AppTheme.darkBg,
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
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryHover]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.39),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.business_center, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Register Business',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your business account.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // — Personal Info —
                  _sectionLabel('Personal Info'),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    hint: 'Business Email',
                    icon: Icons.mail,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) => setState(() => _emailError = null),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _phoneController,
                    hint: 'Phone (optional)',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                    errorText: _passwordError,
                    onChanged: (_) => setState(() => _passwordError = null),
                  ),
                  const SizedBox(height: 28),

                  // — Venue Info —
                  _sectionLabel('Venue Info'),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _venueNameController,
                    hint: 'Venue Name',
                    icon: Icons.store_outlined,
                    errorText: _venueNameError,
                    onChanged: (_) => setState(() => _venueNameError = null),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _venueAddressController,
                    hint: 'Venue Address',
                    icon: Icons.location_on_outlined,
                    errorText: _venueAddressError,
                    onChanged: (_) => setState(() => _venueAddressError = null),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 32),

                  // Submit button
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
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.darkBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          elevation: 0,
                        ),
                        onPressed: isLoading || !canSubmit ? null : _register,
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBg))
                            : const Text('Create Business Account',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already registered? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go('/business-login'),
                        child: const Text('Log In',
                            style: TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
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

  Widget _sectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFF334155)),
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          items: _venueCategories.map((cat) => DropdownMenuItem(
            value: cat,
            child: Row(
              children: [
                const Icon(Icons.category_outlined, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 12),
                Text(
                  cat[0].toUpperCase() + cat.substring(1),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          )).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
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
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: hasError ? const Color(0xFFEF4444) : const Color(0xFF334155),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF64748B), size: 20),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9999), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9999),
                borderSide: BorderSide(
                  color: hasError ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 13),
                const SizedBox(width: 4),
                Text(errorText, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}
