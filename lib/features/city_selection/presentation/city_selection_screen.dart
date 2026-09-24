import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/city.dart';
import '../../../core/services/city_providers.dart';
export '../../../core/services/city_providers.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  final bool showAsModal;
  final VoidCallback? onCitySelected;
  const CitySelectionScreen(
      {super.key, this.showAsModal = false, this.onCitySelected});
  @override
  ConsumerState<CitySelectionScreen> createState() =>
      _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  bool _busy = false;
  Future<void> _select(City? city, {bool detect = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (detect) {
        city = await ref
            .read(cityAutoSelectServiceProvider)
            .requestPermissionAndDetect();
      }
      if (city == null) {
        throw StateError(
            'No supported city found. Choose a city below or enable location access.');
      }
      if (!detect) {
        await ref.read(citySelectionServiceProvider).selectCity(city);
      }
      ref.invalidate(selectedCityProvider);
      if (!mounted) return;
      widget.onCitySelected?.call();
      if (widget.showAsModal) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCityProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Choose your city'),
          automaticallyImplyLeading: widget.showAsModal),
      body: Column(children: [
        if (_busy) const LinearProgressIndicator(),
        ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Use my location'),
            onTap: _busy ? null : () => _select(null, detect: true)),
        Expanded(
            child: ref.watch(availableCitiesProvider).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                      child: TextButton(
                          onPressed: () =>
                              ref.invalidate(availableCitiesProvider),
                          child: const Text('Could not load cities. Retry'))),
                  data: (cities) => cities.isEmpty
                      ? const Center(
                          child: Text('No cities are available yet.'))
                      : ListView.builder(
                          itemCount: cities.length,
                          itemBuilder: (_, index) {
                            final city = cities[index];
                            return ListTile(
                                title: Text(city.name),
                                subtitle: Text(city.country),
                                leading: const Icon(Icons.location_city),
                                trailing: selected?.id == city.id
                                    ? const Icon(Icons.check_circle)
                                    : null,
                                enabled: !_busy && city.isActive,
                                onTap: () => _select(city));
                          },
                        ),
                )),
      ]),
    );
  }
}

class CompactCitySelector extends ConsumerWidget {
  final VoidCallback? onTap;
  const CompactCitySelector({super.key, this.onTap});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider).valueOrNull;
    return TextButton.icon(
      icon: const Icon(Icons.location_city),
      label: Text(city?.name ?? 'Choose city'),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child:
                CitySelectionScreen(showAsModal: true, onCitySelected: onTap)),
      ),
    );
  }
}
