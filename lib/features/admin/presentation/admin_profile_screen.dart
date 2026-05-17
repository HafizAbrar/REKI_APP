import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/user_api_service.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _email;
  String? _avatarUrl;
  String? _authProvider;
  bool _isVerified = false;
  bool _locationEnabled = false;
  bool _backgroundLocationEnabled = false;
  double? _currentLat;
  double? _currentLng;
  String? _locationUpdatedAt;
  String? _createdAt;
  int _savedVenuesCount = 0;
  List _vibes = [];
  List _music = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userApi = ref.read(userApiServiceProvider);
      final profile = await userApi.getProfile();
      final loc = profile['location'] as Map<String, dynamic>? ?? {};
      final prefs = profile['preferences'] as Map<String, dynamic>? ?? {};

      setState(() {
        _nameController.text = profile['name']?.toString() ?? '';
        _phoneController.text = profile['phone']?.toString() ?? '';
        _email = profile['email']?.toString();
        _avatarUrl = profile['avatar']?.toString();
        _authProvider = profile['authProvider']?.toString();
        _isVerified = profile['isVerified'] as bool? ?? false;
        _savedVenuesCount = profile['savedVenuesCount'] as int? ?? 0;
        _locationEnabled = loc['locationEnabled'] as bool? ?? false;
        _backgroundLocationEnabled = loc['backgroundLocationEnabled'] as bool? ?? false;
        _currentLat = (loc['currentLat'] as num?)?.toDouble();
        _currentLng = (loc['currentLng'] as num?)?.toDouble();
        _locationUpdatedAt = loc['locationUpdatedAt']?.toString();
        _createdAt = profile['createdAt']?.toString();
        _vibes = prefs['vibes'] as List? ?? [];
        _music = prefs['music'] as List? ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final userApi = ref.read(userApiServiceProvider);
      await userApi.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        locationEnabled: _locationEnabled,
        backgroundLocationEnabled: _backgroundLocationEnabled,
        currentLat: _currentLat,
        currentLng: _currentLng,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isSaving = true);
    try {
      final userApi = ref.read(userApiServiceProvider);
      final result = await userApi.updateProfile(avatarPath: image.path);
      if (mounted) {
        setState(() => _avatarUrl = result['avatar']?.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 15)),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2))),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surface,
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar ──────────────────────────────────────────
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryColor, width: 3),
                              ),
                              child: ClipOval(
                                child: _avatarUrl != null
                                    ? Image.network(_avatarUrl!, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _avatarFallback())
                                    : _avatarFallback(),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickAvatar,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.backgroundDark, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Verified + auth provider badges
                      Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (_isVerified)
                            _badge('Verified', const Color(0xFF10B981), Icons.verified),
                          if (_authProvider != null) ...[
                            const SizedBox(width: 8),
                            _badge(_authProvider!, const Color(0xFF8B5CF6), Icons.lock_outline),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // ── Basic Info ──────────────────────────────────────
                      _sectionLabel('BASIC INFO'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: TextEditingController(text: _email ?? ''),
                        label: 'Email',
                        icon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hint: 'Not set',
                      ),
                      const SizedBox(height: 24),

                      // ── Account Info ────────────────────────────────────
                      _sectionLabel('ACCOUNT INFO'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(children: [
                          _infoRow(Icons.bookmark_outline, 'Saved Venues', '$_savedVenuesCount'),
                          const Divider(color: Color(0xFF334155), height: 20),
                          _infoRow(Icons.calendar_today_outlined, 'Member Since', _formatDate(_createdAt)),
                          if (_vibes.isNotEmpty) ...[
                            const Divider(color: Color(0xFF334155), height: 20),
                            _infoRow(Icons.bolt_outlined, 'Vibe Prefs', _vibes.join(', ')),
                          ],
                          if (_music.isNotEmpty) ...[
                            const Divider(color: Color(0xFF334155), height: 20),
                            _infoRow(Icons.music_note_outlined, 'Music Prefs', _music.join(', ')),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // ── Location ────────────────────────────────────────
                      _sectionLabel('LOCATION'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(children: [
                          _switchRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location Enabled',
                            value: _locationEnabled,
                            onChanged: (v) => setState(() => _locationEnabled = v),
                          ),
                          const Divider(color: Color(0xFF334155), height: 20),
                          _switchRow(
                            icon: Icons.location_searching,
                            label: 'Background Location',
                            value: _backgroundLocationEnabled,
                            onChanged: (v) => setState(() => _backgroundLocationEnabled = v),
                          ),
                          const Divider(color: Color(0xFF334155), height: 20),
                          _infoRow(
                            Icons.my_location_outlined,
                            'Coordinates',
                            _currentLat != null && _currentLng != null
                                ? '${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}'
                                : 'Not set',
                          ),
                          if (_locationUpdatedAt != null) ...[
                            const Divider(color: Color(0xFF334155), height: 20),
                            _infoRow(Icons.update_outlined, 'Last Updated', _formatDate(_locationUpdatedAt)),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _avatarFallback() {
    final initial = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A';
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.15),
      child: Center(
        child: Text(initial, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 36, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5));

  Widget _badge(String label, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(children: [
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: AppTheme.primaryColor, size: 18),
    ),
    const SizedBox(width: 12),
    Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
  ]);

  Widget _switchRow({required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged}) =>
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ]);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: readOnly ? const Color(0xFF64748B) : Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF475569)),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
        ),
      );
}
