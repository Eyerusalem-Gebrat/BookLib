class ApiConfig {
  // Private constructor: this class only holds settings, nobody creates objects from it
  ApiConfig._();

    // With "adb reverse tcp:8000 tcp:8000", the phone's 127.0.0.1 reaches your computer
  static const String host = 'http://127.0.0.1:8000';

  // Every API route in Laravel starts with /api
  static const String baseUrl = '$host/api';

  // Laravel saves posters as "posters/abc.jpg" and serves them from /storage
  static String posterUrl(String path) => '$host/storage/$path';
}