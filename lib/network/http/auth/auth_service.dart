import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/auth/auth_model.dart';

abstract class AuthService {
  Future<APIResponse<LoginResponse>> login(LoginRequest body);

  Future<APIResponse<RegisterResponse>> register(RegisterRequest body);
}

class AuthServiceImpl implements AuthService {
  final Dio _dio = locator<DioClient>().dio;

  @override
  Future<APIResponse<LoginResponse>> login(LoginRequest body) async {
    final res = await _dio.post('/auth/login', data: body.toJson());
    return APIResponse.fromJson(
      res.data,
      (data) => LoginResponse.fromJson(data),
    );
  }

  @override
  Future<APIResponse<RegisterResponse>> register(RegisterRequest body) async {
    final res = await _dio.post('/auth/register', data: body.toJson());
    return APIResponse.fromJson(
      res.data,
      (data) => RegisterResponse.fromJson(data),
    );
  }
}
