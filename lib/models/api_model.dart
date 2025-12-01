class APIResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  APIResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory APIResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return APIResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
