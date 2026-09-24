import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:reki_mvp/core/services/city_auto_select_service.dart';
import 'package:reki_mvp/core/services/city_selection_service.dart';
import 'package:reki_mvp/core/services/city_repository.dart';
import 'package:reki_mvp/core/services/city_api_service.dart';
import 'package:reki_mvp/core/services/location_service.dart';
import 'package:reki_mvp/core/storage/secure_storage.dart';
import 'package:reki_mvp/core/models/city.dart';

// Fake implementations for testing
class FakeCityApiService extends CityApiService {
  FakeCityApiService() : super(dio: Dio());

  City? _cityToReturn;
  Exception? _exceptionToThrow;
  List<City>? _citiesToReturn;

  void setCityToReturn(City? city) => _cityToReturn = city;
  void setExceptionToThrow(Exception e) => _exceptionToThrow = e;
  void setCitiesToReturn(List<City> cities) => _citiesToReturn = cities;
  void clearException() => _exceptionToThrow = null;

  @override
  Future<City?> detectCityFromLocation(double lat, double lng) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getCityById(String id) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getCityBySlug(String slug) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getUserCity() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<List<City>> getActiveCities() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _citiesToReturn ??
        City.defaultCities().where((c) => c.isActive).toList();
  }

  @override
  Future<void> setUserCity(String cityId) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
  }

  @override
  Future<List<City>> getCities() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _citiesToReturn ?? City.defaultCities();
  }
}

class FakeCityRepository extends CityRepository {
  FakeCityRepository() : super(FakeCityApiService());

  City? _cityToReturn;
  Exception? _exceptionToThrow;
  List<City>? _citiesToReturn;

  void setCityToReturn(City? city) => _cityToReturn = city;
  void setExceptionToThrow(Exception e) => _exceptionToThrow = e;
  void setCitiesToReturn(List<City> cities) => _citiesToReturn = cities;
  void clearException() => _exceptionToThrow = null;

  @override
  Future<City?> detectCityFromLocation(double lat, double lng) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getCityById(String id) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getCityBySlug(String slug) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getUserCity() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<List<City>> getActiveCities() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _citiesToReturn ??
        City.defaultCities().where((c) => c.isActive).toList();
  }

  @override
  Future<void> setUserCity(String cityId) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
  }

  @override
  Future<List<City>> getCities({bool forceRefresh = false}) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _citiesToReturn ?? City.defaultCities();
  }
}

class FakeSecureStorage extends SecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _data.containsKey(key);
}

class FakeCitySelectionService extends CitySelectionService {
  FakeCitySelectionService() : super(FakeCityRepository(), FakeSecureStorage());

  City? _cityToReturn;
  Exception? _exceptionToThrow;

  void setCityToReturn(City? city) => _cityToReturn = city;
  void setExceptionToThrow(Exception e) => _exceptionToThrow = e;
  void clearException() => _exceptionToThrow = null;

  @override
  Future<City?> autoDetectAndSelectCity(double lat, double lng) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> detectCity(double lat, double lng) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }

  @override
  Future<City?> getLastDetectedCity() async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _cityToReturn;
  }
}

class FakeLocationService extends LocationService {
  bool _hasPermission = true;
  bool _serviceEnabled = true;
  Position? _positionToReturn;
  Exception? _exceptionToThrow;

  void setHasPermission(bool value) => _hasPermission = value;
  void setServiceEnabled(bool value) => _serviceEnabled = value;
  void setPositionToReturn(Position? position) => _positionToReturn = position;
  void setExceptionToThrow(Exception e) => _exceptionToThrow = e;
  void clearException() => _exceptionToThrow = null;

  @override
  Future<bool> hasLocationPermission() async => _hasPermission;

  @override
  Future<bool> isLocationServiceEnabled() async => _serviceEnabled;

  @override
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    if (_positionToReturn != null) return _positionToReturn!;
    throw Exception('No position set');
  }

  @override
  Future<Position?> getLastKnownPosition() async => _positionToReturn;

  @override
  Future<bool> requestLocationPermission() async => _hasPermission;
}

void main() {
  group('CityAutoSelectService', () {
    late CityAutoSelectService service;
    late FakeCitySelectionService fakeCitySelectionService;
    late FakeLocationService fakeLocationService;

    setUp(() {
      fakeCitySelectionService = FakeCitySelectionService();
      fakeLocationService = FakeLocationService();
      service =
          CityAutoSelectService(fakeCitySelectionService, fakeLocationService);
    });

    group('canAutoDetect', () {
      test('returns true when permission granted and service enabled',
          () async {
        fakeLocationService.setHasPermission(true);
        fakeLocationService.setServiceEnabled(true);

        final result = await service.canAutoDetect();
        expect(result, isTrue);
      });

      test('returns false when permission denied', () async {
        fakeLocationService.setHasPermission(false);
        fakeLocationService.setServiceEnabled(true);

        final result = await service.canAutoDetect();
        expect(result, isFalse);
      });

      test('returns false when location service disabled', () async {
        fakeLocationService.setHasPermission(true);
        fakeLocationService.setServiceEnabled(false);

        final result = await service.canAutoDetect();
        expect(result, isFalse);
      });
    });

    group('autoDetectAndSelectCity', () {
      test('returns null when permission denied', () async {
        fakeLocationService
            .setExceptionToThrow(LocationPermissionException('denied'));

        final result = await service.autoDetectAndSelectCity();
        expect(result, isNull);
      });

      test('returns null when location service disabled', () async {
        fakeLocationService
            .setExceptionToThrow(LocationServicesDisabledException('disabled'));

        final result = await service.autoDetectAndSelectCity();
        expect(result, isNull);
      });

      test('returns city when detection succeeds', () async {
        final testCity = City(
          id: '1',
          name: 'Manchester',
          slug: 'manchester',
          country: 'UK',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 53.4808,
          defaultLng: -2.2426,
          isActive: true,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        );

        final position = Position(
          latitude: 53.4808,
          longitude: -2.2426,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        fakeLocationService.setPositionToReturn(position);
        fakeCitySelectionService.setCityToReturn(testCity);

        final result = await service.autoDetectAndSelectCity();
        expect(result, equals(testCity));
      });
    });

    group('detectCityOnly', () {
      test('returns null when getCurrentPosition throws', () async {
        fakeLocationService.setExceptionToThrow(Exception('error'));

        final result = await service.detectCityOnly();
        expect(result, isNull);
      });

      test('returns city from backend when available', () async {
        final testCity = City(
          id: '1',
          name: 'Manchester',
          slug: 'manchester',
          country: 'UK',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 53.4808,
          defaultLng: -2.2426,
          isActive: true,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        );

        final position = Position(
          latitude: 53.4808,
          longitude: -2.2426,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        fakeLocationService.setPositionToReturn(position);
        fakeCitySelectionService.setCityToReturn(testCity);

        final result = await service.detectCityOnly();
        expect(result, equals(testCity));
      });
    });

    group('requestPermissionAndDetect', () {
      test('returns null when permission request denied', () async {
        fakeLocationService.setHasPermission(false);

        final result = await service.requestPermissionAndDetect();
        expect(result, isNull);
      });

      test('returns null when location service disabled after permission',
          () async {
        fakeLocationService.setHasPermission(true);
        fakeLocationService.setServiceEnabled(false);

        final result = await service.requestPermissionAndDetect();
        expect(result, isNull);
      });
    });
  });
}
