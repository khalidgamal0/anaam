import 'dart:convert';

class ContactUsRequest {
  final String name;
  final String email;
  final String phone;
  final String notes;

  ContactUsRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
    };
  }

  String toJsonString() => json.encode(toJson());
}
