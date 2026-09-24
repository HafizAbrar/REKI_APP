import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reki_mvp/core/services/location_service.dart';

void main() {
  group('LocationService', () {
    late LocationService service;

    setUp(() {
      service = LocationService();
    });

    group('LocationPermissionException', () {
      test('toString contains message', () {
        final exception = LocationPermissionException('test message');
        expect(exception.toString(), contains('test message'));
      });
    });

    group('LocationServicesDisabledException', () {
      test('toString contains message', () {
        final exception = LocationServicesDisabledException('test message');
        expect(exception.toString(), contains('test message'));
      });
    });

    group('Service methods exist and are callable', () {
      test('hasLocationPermission is callable', () {
        expect(service.hasLocationPermission, isA<Future<bool> Function()>());
      });

      test('requestLocationPermission is callable', () {
        expect(
            service.requestLocationPermission, isA<Future<bool> Function()>());
      });

      test('isLocationServiceEnabled is callable', () {
        expect(
            service.isLocationServiceEnabled, isA<Future<bool> Function()>());
      });

      test('getCurrentPosition is callable', () {
        expect(
            service.getCurrentPosition,
            isA<
                Future<Position> Function(
                    {LocationAccuracy accuracy, Duration? timeLimit})>());
      });

      test('getLastKnownPosition is callable', () {
        expect(
            service.getLastKnownPosition, isA<Future<Position?> Function()>());
      });

      test('openAppSettings is callable', () {
        expect(service.openAppSettings, isA<Future<void> Function()>());
      });

      test('openLocationSettings is callable', () {
        expect(service.openLocationSettings, isA<Future<void> Function()>());
      });
    });
  });
}
