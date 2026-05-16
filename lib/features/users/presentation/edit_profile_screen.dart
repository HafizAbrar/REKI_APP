import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/user_preferences_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  bool _locationEnabled = false;
  bool _backgroundLocationEnabled = false;
  File? _avatarFile;
  String? _existingAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) _applyProfile(profile);
  }

  void _applyProfile(Map<String, dynamic> profile) {
    _nameController.text = profile['name']?.toString() ?? _nameController.text;
    _phoneController.text = profile['phone']?.toString() ?? '';
    final location = profile['location'] as Map<String, dynamic>? ?? {};
    setState(() {
      _locationEnabled = location['locationEnabled'] == true;
      _backgroundLocationEnabled = location['backgroundLocationEnabled'] == true;
      _existingAvatarUrl = profile['avatar']?.toString() ?? profile['profilePicture']?.toString();
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    final success = await ref.read(updateProfileProvider.notifier).update(
      name: name.isNotEmpty ? name : null,
      phone: phone.isNotEmpty ? phone : null,
      locationEnabled: _locationEnabled,
      backgroundLocationEnabled: _backgroundLocationEnabled,
      avatarPath: _avatarFile?.path,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Profile updated successfully'),
          ]),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(updateProfileProvider).error?.toString() ?? 'Update failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final isLoading = ref.watch(updateProfileProvider).isLoading;

    // Apply profile data once loaded
    ref.listen(userProfileProvider, (_, next) {
      next.whenData(_applyProfile);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _save,
            child: isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                : const Text('Save',
                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white))),
        data: (_) => _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor, width: 3),
                        color: const Color(0xFF1E293B),
                      ),
                      child: ClipOval(child: _buildAvatarContent()),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Tap to change photo',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ),
            const SizedBox(height: 32),

            // Personal Info
            _sectionLabel('Personal Information'),
            _buildField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Location Settings
            _sectionLabel('Location Settings'),
            _buildToggleTile(
              icon: Icons.location_on_outlined,
              title: 'Location Tracking',
              subtitle: 'Allow REKI to use your location for nearby venues',
              value: _locationEnabled,
              onChanged: (v) => setState(() {
                _locationEnabled = v;
                if (!v) _backgroundLocationEnabled = false;
              }),
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.location_searching,
              title: 'Background Location',
              subtitle: 'Track location even when app is in background',
              value: _backgroundLocationEnabled,
              enabled: _locationEnabled,
              onChanged: _locationEnabled
                  ? (v) => setState(() => _backgroundLocationEnabled = v)
                  : null,
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: ref.watch(updateProfileProvider).isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: ref.watch(updateProfileProvider).isLoading
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_avatarFile != null) {
      return Image.file(_avatarFile!, fit: BoxFit.cover, width: 100, height: 100);
    }
    if (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty) {
      return Image.network(
        _existingAvatarUrl!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 48),
      );
    }
    return const Icon(Icons.person, color: Colors.white, size: 48);
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    ValueChanged<bool>? onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ]),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            inactiveThumbColor: const Color(0xFF475569),
            inactiveTrackColor: const Color(0xFF334155),
          ),
        ]),
      ),
    );
  }
}
