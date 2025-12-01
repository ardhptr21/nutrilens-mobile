import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';

abstract class NutritionService {
  Future<APIResponse<NutritionStatisticsResponse>>
  getNutritionStatisticsToday();
}

class NutritionServiceImpl implements NutritionService {
  final Dio _dio = locator<DioClient>().dio;

  @override
  Future<APIResponse<NutritionStatisticsResponse>>
  getNutritionStatisticsToday() async {
    final res = await _dio.get('/nutritions/today');
    return APIResponse.fromJson(
      res.data,
      (data) => NutritionStatisticsResponse.fromJson(data),
    );
  }
}
