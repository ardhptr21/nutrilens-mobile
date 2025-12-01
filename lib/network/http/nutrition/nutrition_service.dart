import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';

abstract class NutritionService {
  Future<APIResponse<NutritionStatisticsResponse>>
  getNutritionStatisticsToday();
  Future<APIResponse<NutritionScanResponse>> nutritionScan(
    NutritionScanRequest request,
  );
  Future<APIResponse<NutritionUploadMealResponse>> uploadMeal(
    NutritionUploadMealRequest request,
  );
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

  @override
  Future<APIResponse<NutritionScanResponse>> nutritionScan(
    NutritionScanRequest request,
  ) async {
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(request.image.path),
      'detail': request.detail,
    });
    final res = await _dio.post(
      '/nutritions/scan',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return APIResponse.fromJson(
      res.data,
      (data) => NutritionScanResponse.fromJson(data),
    );
  }

  @override
  Future<APIResponse<NutritionUploadMealResponse>> uploadMeal(
    NutritionUploadMealRequest request,
  ) async {
    FormData formData = FormData.fromMap({
      'name': request.name,
      'cal': request.cal,
      'fat': request.fat,
      'protein': request.protein,
      'carbs': request.carbs,
      'description': request.description,
      'image': await MultipartFile.fromFile(request.image.path),
    });
    final res = await _dio.post(
      '/nutritions/meals',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return APIResponse.fromJson(
      res.data,
      (data) => NutritionUploadMealResponse.fromJson(data),
    );
  }
}
