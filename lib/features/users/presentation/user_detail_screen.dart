import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_repository.dart';
import '../data/user_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: userAsync.when(
        data: (user) => _UserDetailContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _UserDetailContent extends ConsumerStatefulWidget {
  final User user;

  const _UserDetailContent({required this.user});

  @override
  ConsumerState<_UserDetailContent> createState() => _UserDetailContentState();
}

class _UserDetailContentState extends ConsumerState<_UserDetailContent> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          Text('Type: ${widget.user.type.name}'),
          const SizedBox(height: 8),
          Text('ID: ${widget.user.id}'),
          const SizedBox(height: 24),
          if (widget.user.preferences.isNotEmpty) ...[
            const Text('Preferences:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.user.preferences.map((p) => Chip(label: Text(p))).toList(),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Text(_isEditing ? 'Save' : 'Edit'),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = widget.user.name;
                        _emailController.text = widget.user.email;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.updateUser(widget.user.id, {
      'name': _nameController.text,
      'email': _emailController.text,
    });

    if (mounted) {
      result.when(
        success: (_) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
          ref.invalidate(userDetailProvider(widget.user.id));
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    }
  }
}
