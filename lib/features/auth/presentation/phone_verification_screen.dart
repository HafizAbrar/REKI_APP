import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  
  const PhoneVerificationScreen({Key? key, required this.phoneNumber}) : super(key: key);
  
  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Container(
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40),
                          NeonText(
                            'Verify Phone',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enter the 6-digit code sent to',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) => _buildOTPField(index)),
                          ),
                          SizedBox(height: 32),
                          Center(
                            child: _canResend
                                ? TextButton(
                                    onPressed: _resendCode,
                                    child: Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Resend code in $_countdown seconds',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white54,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: GlowButton(
                              text: 'Verify',
                              onPressed: _verifyCode,
                              isLoading: _isVerifying,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return GlowContainer(
      glowRadius: _controllers[index].text.isNotEmpty ? 15 : 0,
      glowSpread: _controllers[index].text.isNotEmpty ? 2 : 0,
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _controllers[index].text.isNotEmpty ? AppTheme.primaryColor : Colors.white24,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  void _verifyCode() async {
    String code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter complete code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() => _isVerifying = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone verified successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
