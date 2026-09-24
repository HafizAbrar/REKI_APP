import 'package:dio/dio.dart';
import '../../models/city.dart';

class CityInterceptor extends Interceptor {
  final Future<City?> Function() selectedCity;
  CityInterceptor(this.selectedCity);
  static const scopedPaths = {
    '/venues',
    '/venues/search',
    '/venues/filter-options',
    '/venues/trending',
    '/venues/map-markers',
    '/offers',
    '/venues/sync',
    '/offers/sync',
    '/analytics/popular-areas',
    '/live/feed',
    '/live/snapshot',
    '/live/map',
  };
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (options.method == 'GET' && scopedPaths.contains(options.path)) {
        final city = await selectedCity();
        options.queryParameters['city'] = city?.slug ?? 'manchester';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }
}
