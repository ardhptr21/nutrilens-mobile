import 'package:nutrilens/models/user_model.dart';

typedef UserMeResponse = UserModel;

class UserUpdateRequest {
  final String name;

  UserUpdateRequest({required this.name});
}

class UserGetPreferenceResponse {
  final double targetCal;
  final double targetFat;
  final double targetCarbs;
  final double targetProtein;

  UserGetPreferenceResponse({
    required this.targetCal,
    required this.targetFat,
    required this.targetCarbs,
    required this.targetProtein,
  });

  factory UserGetPreferenceResponse.fromJson(Map<String, dynamic> json) {
    return UserGetPreferenceResponse(
      targetCal: (json['targetCal'] as num).toDouble(),
      targetFat: (json['targetFat'] as num).toDouble(),
      targetCarbs: (json['targetCarbs'] as num).toDouble(),
      targetProtein: (json['targetProtein'] as num).toDouble(),
    );
  }
}

class UserUpdatePreferenceRequest {
  final double targetCal;
  final double targetFat;
  final double targetCarbs;
  final double targetProtein;

  UserUpdatePreferenceRequest({
    required this.targetCal,
    required this.targetFat,
    required this.targetCarbs,
    required this.targetProtein,
  });
}
