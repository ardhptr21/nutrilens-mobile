import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/user/user_model.dart';

abstract class UserService {
  Future<APIResponse<UserMeResponse>> getUserMe();
  Future<APIResponse<Null>> updateUser(UserUpdateRequest request);
  Future<APIResponse<UserGetPreferenceResponse>> getUserPreferences();
  Future<APIResponse<Null>> updateUserPreferences(
    UserUpdatePreferenceRequest request,
  );
}

class UserServiceImpl extends UserService {
  final Dio _dio = locator<DioClient>().dio;

  @override
  Future<APIResponse<UserMeResponse>> getUserMe() async {
    final res = await _dio.get('/users/me');
    return APIResponse.fromJson(
      res.data,
      (data) => UserMeResponse.fromJson(data),
    );
  }

  @override
  Future<APIResponse<Null>> updateUser(UserUpdateRequest request) async {
    final res = await _dio.patch('/users/me', data: {'name': request.name});
    return APIResponse.fromJson(res.data, (_) => null);
  }

  @override
  Future<APIResponse<UserGetPreferenceResponse>> getUserPreferences() async {
    final res = await _dio.get('/users/me/preference');
    return APIResponse.fromJson(
      res.data,
      (data) => UserGetPreferenceResponse.fromJson(data),
    );
  }

  @override
  Future<APIResponse<Null>> updateUserPreferences(
    UserUpdatePreferenceRequest request,
  ) async {
    final res = await _dio.put(
      '/users/me/preference',
      data: {
        'targetCal': request.targetCal,
        'targetFat': request.targetFat,
        'targetCarbs': request.targetCarbs,
        'targetProtein': request.targetProtein,
      },
    );
    return APIResponse.fromJson(res.data, (_) => null);
  }
}
