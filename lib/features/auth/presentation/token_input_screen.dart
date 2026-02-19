import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import 'auth_provider.dart';

class TokenInputScreen extends ConsumerStatefulWidget {
  const TokenInputScreen({super.key});

  @override
  ConsumerState<TokenInputScreen> createState() => _TokenInputScreenState();
}

class _TokenInputScreenState extends ConsumerState<TokenInputScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a token')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = ref.read(authNotifierProvider);
    await authService.setAccessToken(_tokenController.text);
    final user = await authService.fetchCurrentUser();

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      switch (user.role) {
        case UserRole.ADMIN:
          context.go('/admin-dashboard');
        case UserRole.BUSINESS:
          context.go('/business-dashboard');
        case UserRole.USER:
          context.go('/home');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user info. Check token.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text('Enter Access Token', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste your JWT token below to test role-based routing:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _tokenController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}
