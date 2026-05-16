import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/env.dart';
import '../../../shared/widgets/app_cached_image.dart';
import 'business_provider.dart';

class EditBusinessProfileScreen extends ConsumerStatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  ConsumerState<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState
    extends ConsumerState<EditBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _avatarPath;   // local file path picked by user
  String? _currentAvatarUrl; // existing remote URL
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefill);
  }

  void _prefill() {
    final profile = ref.read(businessProfileProvider).valueOrNull;
    if (profile == null) return;
    setState(() {
      _nameCtrl.text = profile['name']?.toString() ?? '';
      _phoneCtrl.text = profile['phone']?.toString() ?? '';
      _currentAvatarUrl = profile['avatar']?.toString();
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file != null) setState(() => _avatarPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final error = await ref.read(businessProfileProvider.notifier).update(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          avatarPath: _avatarPath,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prefill once profile loads if it wasn't ready in initState
    ref.listen(businessProfileProvider, (_, next) {
      if (!_loaded) {
        next.whenData((p) {
          setState(() {
            _nameCtrl.text = p['name']?.toString() ?? '';
            _phoneCtrl.text = p['phone']?.toString() ?? '';
            _currentAvatarUrl = p['avatar']?.toString();
            _loaded = true;
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF14B8A6)))
                : const Text('Save',
                    style: TextStyle(
                        color: Color(0xFF14B8A6),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar picker
              Center(child: _avatarPicker()),
              const SizedBox(height: 32),

              // Name
              _label('Business Name'),
              const SizedBox(height: 8),
              _field(
                controller: _nameCtrl,
                hint: 'e.g. The Blue Moon Group',
                icon: Icons.business_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // Phone
              _label('Phone Number'),
              const SizedBox(height: 8),
              _field(
                controller: _phoneCtrl,
                hint: 'e.g. +447911123456',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 36),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPicker() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF14B8A6), width: 3),
            ),
            child: ClipOval(child: _avatarWidget()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarWidget() {
    // Newly picked local file takes priority
    if (_avatarPath != null) {
      return Image.file(File(_avatarPath!), fit: BoxFit.cover,
          width: 100, height: 100);
    }
    // Existing remote avatar
    if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      final url = _currentAvatarUrl!.startsWith('http')
          ? _currentAvatarUrl!
          : '${Env.apiBaseUrl}$_currentAvatarUrl';
      return AppCachedImage(
          url: url, width: 100, height: 100, fit: BoxFit.cover,
          placeholder: _fallback());
    }
    return _fallback();
  }

  Widget _fallback() {
    final name = _nameCtrl.text;
    return Container(
      color: const Color(0xFF14B8A6),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'B',
          style: const TextStyle(
              color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 13,
          fontWeight: FontWeight.w600));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF14B8A6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
