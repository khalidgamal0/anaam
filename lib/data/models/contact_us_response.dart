import 'dart:convert';

class ContactUsResponse {
  final bool success;
  final String message;

  ContactUsResponse({
    required this.success,
    required this.message,
  });

  factory ContactUsResponse.fromJson(Map<String, dynamic> json) {
    return ContactUsResponse(
      success: json['success'],
      message: json['message'],
    );
  }

  static ContactUsResponse fromString(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return ContactUsResponse.fromJson(data);
  }
}
