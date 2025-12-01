import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    const envFromDartDefine = String.fromEnvironment(
      'BASE_API_URL',
      defaultValue: '',
    );
    if (envFromDartDefine.isNotEmpty) return envFromDartDefine;

    final url = dotenv.env['BASE_API_URL'];
    if (url != null && url.isNotEmpty) return url;

    return 'https://4b85c5851729.ngrok-free.app';
  }
}
