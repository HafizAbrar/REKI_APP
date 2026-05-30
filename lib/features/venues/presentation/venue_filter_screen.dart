import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';

const _vibeTags = [
  'Cocktails', 'Date Night', 'Pub', 'Rooftop',
  'Live Music', 'Chill', 'Party', 'Sports',
];

class VenueFilterScreen extends ConsumerStatefulWidget {
  const VenueFilterScreen({super.key});

  @override
  ConsumerState<VenueFilterScreen> createState() => _VenueFilterScreenState();
}

class _VenueFilterScreenState extends ConsumerState<VenueFilterScreen> {
  String selectedBusyness = '';
  Set<String> selectedVibes = {};
  bool offersOnly = false;
  String selectedSort = 'Distance (Nearest)';

  @override
  void initState() {
    super.initState();
    final f = ref.read(filterProvider);
    selectedBusyness = f.busyness;
    selectedVibes = Set.from(f.vibes);
    offersOnly = f.offersOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              height: 6,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                const Text('Filters',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How busy is it?',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
                          child: Row(children: [
                            _buildBusynessOption('Quiet'),
                            _buildBusynessOption('Moderate'),
                            _buildBusynessOption('Busy'),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  _divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("What's the vibe?",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _vibeTags.map(_buildVibeChip).toList(),
                        ),
                      ],
                    ),
                  ),
                  _divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Offers Available',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Show only venues with active deals',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                            ],
                          ),
                        ),
                        Switch(
                          value: offersOnly,
                          onChanged: (v) => setState(() => offersOnly = v),
                          activeColor: const Color(0xFF14B8A6),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFF1E293B),
                        ),
                      ],
                    ),
                  ),
                  _divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sort by',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildSortOption('Distance (Nearest)', Icons.location_on),
                        const SizedBox(height: 8),
                        _buildSortOption('Trending', Icons.trending_up),
                        const SizedBox(height: 8),
                        _buildSortOption('Top Rated', Icons.star),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0F172A).withOpacity(0), const Color(0xFF0F172A), const Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.3), blurRadius: 16)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    ref.read(filterProvider.notifier).update(
                      busyness: selectedBusyness,
                      vibes: selectedVibes,
                      offersOnly: offersOnly,
                    );
                    context.pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Apply Filters',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${selectedVibes.length + (selectedBusyness.isNotEmpty ? 1 : 0) + (offersOnly ? 1 : 0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
      height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xFF1E293B));

  Widget _buildBusynessOption(String option) {
    final isSelected = selectedBusyness == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedBusyness = isSelected ? '' : option),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF14B8A6) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(option,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildVibeChip(String vibe) {
    final isSelected = selectedVibes.contains(vibe);
    return GestureDetector(
      onTap: () => setState(() => isSelected ? selectedVibes.remove(vibe) : selectedVibes.add(vibe)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFF14B8A6)) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.2), blurRadius: 8)]
              : [],
        ),
        child: Text(vibe,
            style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSortOption(String option, IconData icon) {
    final isSelected = selectedSort == option;
    return GestureDetector(
      onTap: () => setState(() => selectedSort = option),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF14B8A6) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(option,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF64748B), width: 2),
                color: isSelected ? const Color(0xFF14B8A6) : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedBusyness = '';
      selectedVibes = {};
      offersOnly = false;
      selectedSort = 'Distance (Nearest)';
    });
    ref.read(filterProvider.notifier).reset();
  }
}
