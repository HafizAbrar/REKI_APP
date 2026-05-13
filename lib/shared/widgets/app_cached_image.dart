import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFF334155),
          child: const Center(
            child: Icon(Icons.image, color: Color(0xFF64748B), size: 32),
          ),
        );

    if (url == null || url!.isEmpty) return fallback;

    final image = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: const Color(0xFF334155),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2DD4BF),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => fallback,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
