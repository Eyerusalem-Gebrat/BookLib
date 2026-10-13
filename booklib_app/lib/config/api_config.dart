class ApiConfig {
  // Private constructor: this class only holds settings, nobody creates objects from it
  ApiConfig._();

  // 10.0.2.2 is how the Android emulator reaches "localhost" on your computer
  static const String host = 'http://10.0.2.2:8000';

  // Every API route in Laravel starts with /api
  static const String baseUrl = '$host/api';

  // Laravel saves posters as "posters/abc.jpg" and serves them from /storage
  static String posterUrl(String path) => '$host/storage/$path';
}