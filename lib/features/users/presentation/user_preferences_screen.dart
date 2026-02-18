import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_repository.dart';

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  final List<String> _availablePreferences = [
    'Chill', 'Energetic', 'Romantic', 'Business', 'Party',
    'Live Music', 'Sports', 'Rooftop', 'Cocktails', 'Food'
  ];
  final Set<String> _selectedPreferences = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Preferences')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _availablePreferences.length,
              itemBuilder: (context, index) {
                final pref = _availablePreferences[index];
                return CheckboxListTile(
                  title: Text(pref),
                  value: _selectedPreferences.contains(pref),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedPreferences.add(pref);
                      } else {
                        _selectedPreferences.remove(pref);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                child: const Text('Save Preferences'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.updatePreferences(_selectedPreferences.toList());

    if (mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences updated')),
          );
          Navigator.pop(context);
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
