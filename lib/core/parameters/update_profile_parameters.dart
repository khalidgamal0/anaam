import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:an3am/core/utils/image_helper.dart';

class UpdateProfileParameters {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? location;
  final String? address;
  final String? birth_date;
  final File? image;
  final String? method;
  final String? country_id;
  final String? city_id;
  final String? state_id;

  UpdateProfileParameters({
    this.firstName,
    this.lastName,
    this.image,
    this.method,
    this.email,
    this.phone,
    this.location,
    this.address,
    this.birth_date,
    this.country_id,
    this.city_id,
    this.state_id,
  });

  Future<Map<String, dynamic>> toMap() async {
    Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['location'] = location;
    data['address'] = address;
    data['birth_date'] = birth_date;
    data['country_id'] = country_id;
    data['city_id'] = city_id;
    data['state_id'] = state_id;
    data['_method'] = method;

    if (image != null) {
      final compressedImage = await compressImage(image!);
      final fileToUpload = compressedImage ?? image!;
      data['image'] = await MultipartFile.fromFile(
        fileToUpload.path,
        filename: path.basename(fileToUpload.path),
      );
    }

    return data;
  }
}
