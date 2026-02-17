class AppConstants {
  static const String appName = 'REKI';
  static const String cityName = 'Manchester';
  
  // Busyness levels
  static const String quiet = 'Quiet';
  static const String moderate = 'Moderate';
  static const String busy = 'Busy';
  
  // Vibe types
  static const List<String> vibeTypes = [
    'Chill', 'Energetic', 'Romantic', 'Business', 'Party'
  ];
  
  // Demo data refresh intervals (minutes)
  static const int busynessUpdateInterval = 15;
  static const int vibeUpdateInterval = 30;
}