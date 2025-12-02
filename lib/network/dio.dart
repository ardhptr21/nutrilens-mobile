import 'package:dio/dio.dart';
import 'package:nutrilens/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  String? _cachedToken;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return true;
        },
        responseType: ResponseType.json,
      ),
    );

    _addInterceptors();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('token');
  }

  void _addInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Use cached token to avoid repeated SharedPreferences reads
          if (_cachedToken == null) {
            await _loadToken();
          }

          if (_cachedToken != null && _cachedToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            _cachedToken = null; // Clear cache
          }

          return handler.next(error);
        },
      ),
    );
  }
}
