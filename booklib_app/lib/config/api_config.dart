class ApiConfig {
  ApiConfig._();

  // The server address. It is given when the app is run or built:
  //   flutter run --dart-define=API_HOST=http://192.168.1.20:8000
  // With no value, the app uses the USB setup (adb reverse tcp:8000 tcp:8000).
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'http://127.0.0.1:8000',
  );

  // Every API route in Laravel starts with /api
  static const String baseUrl = '$host/api';

  // Laravel saves posters as "posters/abc.jpg" and serves them from /storage
  static String posterUrl(String path) => '$host/storage/$path';
}