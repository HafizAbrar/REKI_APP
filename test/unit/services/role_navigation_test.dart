import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/user.dart';
import 'package:reki_mvp/core/router/role_navigation.dart';

void main() {
  User user(UserRole role) => User.fromJson({'id': 'test', 'role': role.name});
  test('one app routes each authenticated role to its dashboard', () {
    expect(roleHome(UserRole.USER), '/home');
    expect(roleHome(UserRole.BUSINESS), '/business-dashboard');
    expect(roleHome(UserRole.ADMIN), '/admin-dashboard');
    expect(roleHome(UserRole.WORKER), '/worker-home');
    for (final role in UserRole.values) {
      expect(roleRedirect(user(role), roleHome(role)), isNull);
    }
  });
  test('worker can scan and update status but cannot manage owners or admins',
      () {
    final worker = user(UserRole.WORKER);
    for (final path in [
      '/worker-home',
      '/qr-scan',
      '/venue-status/venue',
      '/change-password'
    ]) {
      expect(roleRedirect(worker, path), isNull, reason: path);
    }
    for (final path in [
      '/business-dashboard',
      '/staff-management',
      '/create-offer',
      '/business-profile',
      '/vibe-schedules',
      '/admin-dashboard',
      '/admin/create-venue'
    ]) {
      expect(roleRedirect(worker, path), '/worker-home', reason: path);
    }
  });
  test('customer and guest cannot open worker or management routes', () {
    for (final role in ['USER', 'GUEST']) {
      final customer = User.fromJson({'id': 'test', 'role': role});
      for (final path in [
        '/worker-home',
        '/qr-scan',
        '/venue-status/venue',
        '/staff-management',
        '/admin-dashboard'
      ]) {
        expect(roleRedirect(customer, path), '/home', reason: path);
      }
    }
  });
  test('owner management remains available while admin dashboard is restricted',
      () {
    final owner = user(UserRole.BUSINESS);
    expect(roleRedirect(owner, '/staff-management'), isNull);
    expect(roleRedirect(owner, '/my-venues'), isNull);
    expect(roleRedirect(owner, '/admin-dashboard'), '/business-dashboard');
    expect(roleRedirect(user(UserRole.ADMIN), '/staff-management'), isNull);
  });
  test('signed-out users keep existing login and shared-link behavior', () {
    expect(roleRedirect(null, '/login'), isNull);
    expect(roleRedirect(null, '/business-login'), isNull);
    expect(roleRedirect(null, '/venue/shared-id'), isNull);
    expect(roleRedirect(null, '/worker-home'), '/login');
    expect(roleRedirect(null, '/admin-dashboard'), '/login');
  });
}
