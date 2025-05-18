import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;
import 'package:an3am/core/utils/image_helper.dart';

class LaborerParameters extends Equatable {
  final String? nameAr;
  final String? nameEn;
  final String? phone;
  final String? phone_code;
  final String? method;
  final File? image;
  final String? id;
  final String? coordinates;
  final String? mapLocation;
  final String? nationalityAr;
  final String? nationalityEn;
  final String? email;
  final String? professionAr;
  final String? professionEn;
  final String? addressAr;
  final String? addressEn;

  const LaborerParameters({
    this.nameAr,
    this.id,
    this.nameEn,
    this.phone,
    this.phone_code,
    this.method,
    this.image,
    this.coordinates,
    this.mapLocation,
    this.nationalityAr,
    this.nationalityEn,
    this.email,
    this.professionAr,
    this.professionEn,
    this.addressAr,
    this.addressEn,
  });

  @override
  List<Object?> get props => [
        nameAr,
        nameEn,
        phone,
        phone_code,
        image,
        coordinates,
        mapLocation,
        nationalityAr,
        method,
        nationalityEn,
        email,
        professionAr,
        professionEn,
        addressAr,
        addressEn,
      ];

  Future<Map<String, dynamic>> toMap() async {
    final compressedImage = image != null ? await compressImage(image!) : null;
    final imageToUpload = compressedImage ?? image;

    return {
      'name_ar': nameAr,
      'name_en': nameEn,
      'phone': phone,
      'phone_code': phone_code,
      if (method != null) '_method': method,
      if (imageToUpload != null)
        'image': await MultipartFile.fromFile(
          imageToUpload.path,
          filename: path.basename(imageToUpload.path),
        ),
      'coordinates': coordinates,
      'map_location': mapLocation,
      'nationality_ar': nationalityAr,
      'nationality_en': nationalityEn,
      'email': email,
      'profession_ar': professionAr,
      'profession_en': professionEn,
      'address_ar': addressAr,
      'address_en': addressEn,
    };
  }
}