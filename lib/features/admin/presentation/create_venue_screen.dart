import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/business_api_service.dart';

class CreateVenueScreen extends ConsumerStatefulWidget {
  const CreateVenueScreen({super.key});

  @override
  ConsumerState<CreateVenueScreen> createState() => _CreateVenueScreenState();
}

class _CreateVenueScreenState extends ConsumerState<CreateVenueScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Manchester');
  final _areaController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'bar';
  int _priceLevel = 2;
  final List<String> _tags = [];
  final List<String> _images = [];
  bool _isLoading = false;

  static const _categories = ['bar', 'club', 'restaurant', 'cafe', 'lounge', 'pub', 'other'];
  static const _availableTags = ['Chill', 'Party', 'Romantic', 'Business', 'Energetic', 'Social', 'Live Music', 'Sports', 'Cocktails', 'Dining'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _openingHoursController.dispose();
    _closingTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _images.add(url);
      _imageUrlController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select at least one tag'), backgroundColor: Colors.orange[700]),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(businessApiServiceProvider).createVenue({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'area': _areaController.text.trim(),
        'category': _selectedCategory,
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'priceLevel': _priceLevel,
        'openingHours': _openingHoursController.text.trim(),
        'closingTime': _closingTimeController.text.trim(),
        'tags': _tags,
        if (_images.isNotEmpty) 'images': _images,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Venue created successfully!'), backgroundColor: Colors.green[700]),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Create Venue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Venue Details ─────────────────────────────────────────
              _sectionCard(
                icon: Icons.store,
                title: 'Venue Details',
                children: [
                  _field(_nameController, 'Venue Name', Icons.store_mall_directory, required: true),
                  const SizedBox(height: 14),
                  _field(_addressController, 'Address', Icons.location_on, required: true),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _field(_cityController, 'City', Icons.location_city, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_areaController, 'Area', Icons.map_outlined)),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // ── Category ──────────────────────────────────────────────
              _sectionCard(
                icon: Icons.category,
                title: 'Category',
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        items: _categories.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c[0].toUpperCase() + c.substring(1),
                              style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Location ──────────────────────────────────────────────
              _sectionCard(
                icon: Icons.my_location,
                title: 'Location Coordinates',
                children: [
                  Row(children: [
                    Expanded(child: _field(_latController, 'Latitude', Icons.north,
                        required: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        })),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_lngController, 'Longitude', Icons.east,
                        required: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        })),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // ── Hours & Price ─────────────────────────────────────────
              _sectionCard(
                icon: Icons.schedule,
                title: 'Hours & Pricing',
                children: [
                  Row(children: [
                    Expanded(child: _timeField(_openingHoursController, 'Opening Time', required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _timeField(_closingTimeController, 'Closing Time', required: true)),
                  ]),
                  const SizedBox(height: 16),
                  _sectionLabel('PRICE LEVEL'),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (i) {
                      final level = i + 1;
                      final selected = _priceLevel == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _priceLevel = level),
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primaryColor : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? AppTheme.primaryColor : const Color(0xFF334155),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '£' * level,
                                  style: TextStyle(
                                    color: selected ? AppTheme.darkBg : const Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ['Budget', 'Mid', 'Upscale', 'Luxury'][i],
                                  style: TextStyle(
                                    color: selected ? AppTheme.darkBg : const Color(0xFF64748B),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Tags ──────────────────────────────────────────────────
              _sectionCard(
                icon: Icons.local_offer,
                title: 'Vibe Tags',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final selected = _tags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() =>
                            selected ? _tags.remove(tag) : _tags.add(tag)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryColor.withOpacity(0.15) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppTheme.primaryColor : const Color(0xFF334155),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: selected ? AppTheme.primaryColor : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Images ────────────────────────────────────────────────
              _sectionCard(
                icon: Icons.image,
                title: 'Images (Optional)',
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageUrlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Paste image URL',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.link, color: Color(0xFF64748B), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addImage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ]),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._images.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.image_outlined, color: AppTheme.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.value,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                        GestureDetector(
                          onTap: () => setState(() => _images.removeAt(e.key)),
                          child: const Icon(Icons.close, color: Color(0xFF64748B), size: 16),
                        ),
                      ]),
                    )),
                  ],
                ],
              ),
              const SizedBox(height: 28),

              // ── Submit ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.darkBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.darkBg))
                        : const Text('Create Venue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppTheme.primaryColor, size: 16),
            const SizedBox(width: 8),
            Text(title.toUpperCase(),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
      );

  Widget _timeField(TextEditingController controller, String hint, {bool required = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
      onTap: () => _pickTime(controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: const Icon(Icons.access_time, color: Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator ?? (required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
