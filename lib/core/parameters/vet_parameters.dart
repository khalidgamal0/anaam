import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:an3am/core/utils/image_helper.dart';

class VetParameters extends Equatable {
  final String? nameAr;
  final String? nameEn;
  final String? method;
  final String? phone;
  final String? phone_code;
  final File? image;
  final String? coordinates;
  final String? id;
  final String? mapLocation;
  final String? email;
  final String? addressAr;
  final String? addressEn;
  final String? qualificationAr;
  final String? qualificationEn;
  final String? cityId;
  final String? countryId;

  const VetParameters({
    this.nameAr,
    this.nameEn,
    this.method,
    this.id,
    this.phone,
    this.phone_code,
    this.image,
    this.coordinates,
    this.mapLocation,
    this.email,
    this.addressAr,
    this.addressEn,
    this.qualificationAr,
    this.qualificationEn,
    this.cityId,
    this.countryId,
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
        email,
        addressAr,
        method,
        addressEn,
        qualificationAr,
        qualificationEn,
        cityId,
        countryId,
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
      'email': email,
      'address_ar': addressAr,
      'address_en': addressEn,
      'qualification_ar': qualificationAr,
      'qualification_en': qualificationEn,
      'city_id': cityId,
      'country_id': countryId,
    };
  }
}
