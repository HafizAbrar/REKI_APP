import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const CodeVerificationScreen({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
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
                    Color(0xFF0F172A).withOpacity(0.7),
                    Color(0xFF0F172A).withOpacity(0.95),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Verification Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter the 4-digit code sent to ${widget.phoneNumber}',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      maxLength: 4,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '----',
                        hintStyle: TextStyle(color: Color(0xFF64748B), letterSpacing: 8),
                        filled: true,
                        fillColor: Color(0xFF1E293B),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9999),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9999),
                          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Code resent!'),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      },
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
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
                            offset: Offset(0, 4),
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
                        onPressed: () => context.push('/change-password'),
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Change phone number',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
