import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../storage/secure_storage.dart';
import 'city_api_service.dart';
import 'city_repository.dart';
import 'city_selection_service.dart';
import 'city_auto_select_service.dart';
import 'location_service.dart';

final cityApiServiceProvider = Provider<CityApiService>((ref) {
  final api = CityApiService();
  ref.onDispose(api.dispose);
  return api;
});
final cityRepositoryProvider = Provider<CityRepository>(
    (ref) => CityRepository(ref.read(cityApiServiceProvider)));
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
final citySelectionServiceProvider =
    Provider<CitySelectionService>((ref) => CitySelectionService(
          ref.read(cityRepositoryProvider),
          ref.read(secureStorageProvider),
        ));
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
final cityAutoSelectServiceProvider =
    Provider<CityAutoSelectService>((ref) => CityAutoSelectService(
          ref.read(citySelectionServiceProvider),
          ref.read(locationServiceProvider),
        ));

final availableCitiesProvider = FutureProvider<List<City>>((ref) async {
  return await ref.read(citySelectionServiceProvider).getAvailableCities();
});

final selectedCityProvider = FutureProvider<City?>((ref) async {
  final service = ref.read(citySelectionServiceProvider);
  // 1. Local snapshot (fastest — works offline)
  final saved = await service.getSelectedCity();
  if (saved != null) return saved;
  // 2. Server preference (logged-in users switching devices)
  try {
    final serverCity = await ref.read(cityApiServiceProvider).getUserCity();
    if (serverCity != null && serverCity.isActive) {
      await service.selectCity(serverCity);
      return serverCity;
    }
  } catch (_) {}
  // 3. GPS auto-detect (only if permission already granted)
  final detector = ref.read(cityAutoSelectServiceProvider);
  try {
    if (await detector.canAutoDetect()) {
      final detected = await detector.detectCityOnly();
      final latest = await service.getSelectedCity();
      if (latest != null) return latest;
      if (detected != null) {
        await service.selectCity(detected);
        return detected;
      }
    }
  } catch (_) {}
  // 4. Hardcoded Manchester fallback
  return City.findBySlug('manchester');
});
