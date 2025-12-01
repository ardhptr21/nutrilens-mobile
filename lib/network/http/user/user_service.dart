import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/user/user_model.dart';

abstract class UserService {
  Future<APIResponse<UserMeResponse>> getUserMe();
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
}
