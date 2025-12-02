import 'package:dio/dio.dart';
import 'package:nutrilens/config/locator.dart';
import 'package:nutrilens/models/api_model.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_model.dart';

abstract class NutritionService {
  Future<APIResponse<NutritionStatisticsResponse>>
  getNutritionStatisticsToday();
  Future<APIResponse<List<NutritionStatisticsResponse>>> getNutritionHistory(
    int days,
  );
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
  Future<APIResponse<List<NutritionStatisticsResponse>>> getNutritionHistory(
    int days,
  ) async {
    final List<NutritionStatisticsResponse> history = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      try {
        final res = await _dio.get('/nutritions/$formattedDate');
        final nutritionData = NutritionStatisticsResponse.fromJson(
          res.data['data'],
        );
        history.add(nutritionData);
      } catch (e) {
        // Skip if no data for this date
      }
    }

    return APIResponse<List<NutritionStatisticsResponse>>(
      success: true,
      message: 'Nutrition history retrieved',
      data: history,
      statusCode: 200,
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
