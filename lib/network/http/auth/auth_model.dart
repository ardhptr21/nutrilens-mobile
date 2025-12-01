import 'package:nutrilens/models/user_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
  };
}

class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse(token: json['token'] ?? '');
}

typedef RegisterResponse = UserModel;
