class ApiResponse {

  bool? success = false;
  dynamic data;
  String? message;
  String? debugMessage;

  ApiResponse({this.data, this.success, this.message, this.debugMessage});

  ApiResponse fromJson(Map<String, dynamic> json) {
    return ApiResponse(data: json["data"], success: json["success"], message: json["message"], debugMessage: json["debugMessage"]);
  }
}