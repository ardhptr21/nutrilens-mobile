import 'package:get_it/get_it.dart';
import 'package:nutrilens/network/dio.dart';
import 'package:nutrilens/network/http/auth/auth_service.dart';
import 'package:nutrilens/network/http/nutrition/nutrition_service.dart';
import 'package:nutrilens/network/http/user/user_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<DioClient>(() => DioClient());
  locator.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  locator.registerLazySingleton<UserService>(() => UserServiceImpl());
  locator.registerLazySingleton<NutritionService>(() => NutritionServiceImpl());
}
