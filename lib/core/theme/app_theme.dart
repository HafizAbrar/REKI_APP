import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2DD4BF); // Vibrant Teal
  static const primaryHover = Color(0xFF14B8A6);
  static const iceBlue = Color(0xFFCFFAFE);
  static const backgroundLight = Color(0xFFF0F9FF);
  static const backgroundDark = Color(0xFF0F172A); // slate-900
  static const darkBg = backgroundDark;
  static const surface = Color(0xFF1E293B); // slate-800
  static const surfaceHighlight = Color(0xFF334155); // slate-700
  static const cardBg = surface;
  static const cardDark = surface; // Add cardDark alias
  static const accentPurple = Color(0xFF9D4EDD);
  static const accentPink = Color(0xFFFF006E);
  
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryColor,
    cardColor: cardBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
    ),
  );
}

class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double glowSpread;
  
  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppTheme.primaryColor,
    this.glowRadius = 20,
    this.glowSpread = 5,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: glowRadius,
            spreadRadius: glowSpread,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  
  const NeonText(this.text, {super.key, this.style, this.glowColor = AppTheme.primaryColor});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text, style: style?.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = glowColor.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
        )),
        Text(text, style: style),
      ],
    );
  }
}

class GlowButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final Color? textColor;
  
  const GlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppTheme.primaryColor,
    this.isLoading = false,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: textColor ?? Colors.white))
            : Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor ?? Colors.white)),
      ),
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  
  const GlowCard({super.key, required this.child, this.glowColor});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppTheme.primaryColor).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
