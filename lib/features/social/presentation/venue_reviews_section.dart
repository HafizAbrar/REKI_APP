import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/social_models.dart';
import '../../../shared/widgets/guest_guard.dart';
import '../data/social_provider.dart';

class VenueReviewsSection extends ConsumerWidget {
  final String venueId;
  const VenueReviewsSection({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venueReviewsProvider(venueId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(
            child: Text('Ratings & reviews',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
          TextButton.icon(
            onPressed: () async {
              if (!await guardGuestAction(context) || !context.mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ReviewSheet(venueId: venueId),
              );
            },
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('Write review'),
          ),
        ]),
        state.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))),
          error: (_, __) => OutlinedButton(
            onPressed: () =>
                ref.read(venueReviewsProvider(venueId).notifier).load(),
            child: const Text('Retry reviews'),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return _panel(
                child: const Text(
                  'No reviews yet. Be the first to share what this venue feels like.',
                  style: TextStyle(color: Color(0xFF94A3B8), height: 1.4),
                ),
              );
            }
            final average =
                reviews.fold<int>(0, (sum, item) => sum + item.rating) /
                    reviews.length;
            final accurate = reviews.where((item) => item.vibeAccurate).length;
            return Column(children: [
              _panel(
                child: Row(children: [
                  Text(average.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Stars(value: average.round(), size: 18),
                          const SizedBox(height: 4),
                          Text('${reviews.length} reviews',
                              style: const TextStyle(color: Color(0xFF94A3B8))),
                        ]),
                  ),
                  Column(children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF2DD4BF)),
                    Text(
                        '${(accurate / reviews.length * 100).round()}% accurate',
                        style: const TextStyle(
                            color: Color(0xFF2DD4BF), fontSize: 11)),
                  ]),
                ]),
              ),
              const SizedBox(height: 10),
              ...reviews.take(5).map((review) => _panel(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(review.userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(DateFormat('d MMM').format(review.createdAt),
                                style: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 11)),
                            if (review.isMine)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: Color(0xFF94A3B8), size: 19),
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => _ReviewSheet(
                                        venueId: venueId,
                                        review: review,
                                      ),
                                    );
                                    return;
                                  }
                                  final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Delete review?'),
                                          content: const Text(
                                              'This cannot be undone.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext, false),
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext, true),
                                                child: const Text('Delete')),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                  if (confirmed && context.mounted) {
                                    await ref
                                        .read(venueReviewsProvider(venueId)
                                            .notifier)
                                        .delete(review.id);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                ],
                              ),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            _Stars(value: review.rating, size: 15),
                            if (review.vibeAccurate) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.verified,
                                  color: Color(0xFF2DD4BF), size: 14),
                              const SizedBox(width: 3),
                              const Text('Vibe accurate',
                                  style: TextStyle(
                                      color: Color(0xFF2DD4BF), fontSize: 11)),
                            ],
                          ]),
                          if (review.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(review.text,
                                style: const TextStyle(
                                    color: Color(0xFFCBD5E1), height: 1.4)),
                          ],
                        ]),
                  )),
            ]);
          },
        ),
      ],
    );
  }

  static Widget _panel({required Widget child, EdgeInsets? margin}) =>
      Container(
        width: double.infinity,
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
        ),
        child: child,
      );
}

class _ReviewSheet extends ConsumerStatefulWidget {
  final String venueId;
  final VenueReview? review;
  const _ReviewSheet({required this.venueId, this.review});
  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late final TextEditingController _controller;
  late int _rating;
  late bool _vibeAccurate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.review?.text ?? '');
    _rating = widget.review?.rating ?? 0;
    _vibeAccurate = widget.review?.vibeAccurate ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _saving = true);
    final notifier = ref.read(venueReviewsProvider(widget.venueId).notifier);
    final success = widget.review == null
        ? await notifier.submit(_rating, _controller.text, _vibeAccurate)
        : await notifier.update(
            widget.review!, _rating, _controller.text, _vibeAccurate);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      ref.invalidate(achievementsProvider);
      ref.invalidate(leaderboardProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              widget.review == null ? 'Review published' : 'Review updated'),
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text(widget.review == null ? 'Share your experience' : 'Edit review',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _Stars(
              value: _rating,
              size: 38,
              onChanged: (value) => setState(() => _rating = value)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 500,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What stood out?',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF2DD4BF),
            title: const Text('The listed vibe was accurate',
                style: TextStyle(color: Colors.white)),
            value: _vibeAccurate,
            onChanged: (value) => setState(() => _vibeAccurate = value),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _rating == 0 || _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  foregroundColor: const Color(0xFF0F172A)),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      widget.review == null ? 'Publish review' : 'Save changes',
                      style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;
  const _Stars({required this.value, required this.size, this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final selected = index < value;
          return GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(index + 1),
            child: Icon(selected ? Icons.star : Icons.star_border,
                color: const Color(0xFFF59E0B), size: size),
          );
        }),
      );
}
