import 'package:flutter/material.dart';

import '../../core/models/venue.dart';

class VenueBudgetTag extends StatelessWidget {
  final Venue venue;
  final bool showLabel;
  final bool compact;

  const VenueBudgetTag({
    super.key,
    required this.venue,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = venue.budgetSymbol;
    final label = venue.budgetLabel;
    if (symbol == null || label == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF5EEAD4).withValues(alpha: 0.5)),
      ),
      child: Text(
        showLabel ? '$symbol · $label' : symbol,
        style: TextStyle(
          color: const Color(0xFFF0FDFA),
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
