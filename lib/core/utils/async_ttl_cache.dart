/// Small in-memory metadata cache. Concurrent callers share one load per key.
/// Failed loads are never retained; entries expire and use bounded LRU eviction.
class AsyncTtlCache<K, V> {
  final Duration ttl;
  final int capacity;
  final DateTime Function() _now;
  final _values = <K, ({V value, DateTime expires})>{};
  final _pending = <K, Future<V>>{};
  AsyncTtlCache(
      {required this.ttl, this.capacity = 128, DateTime Function()? now})
      : assert(capacity > 0),
        _now = now ?? DateTime.now;

  Future<V> get(K key, Future<V> Function() load) {
    final cached = _values.remove(key);
    if (cached != null && _now().isBefore(cached.expires)) {
      _values[key] = cached;
      return Future.value(cached.value);
    }
    return _pending[key] ??= Future<V>.sync(load).then((value) {
      _values.removeWhere((_, entry) => !_now().isBefore(entry.expires));
      if (_values.length >= capacity) _values.remove(_values.keys.first);
      _values[key] = (value: value, expires: _now().add(ttl));
      return value;
    }).whenComplete(() {
      _pending.remove(key);
    });
  }
}
