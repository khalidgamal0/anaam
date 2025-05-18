import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;
import 'package:an3am/core/utils/image_helper.dart';

class StoreParameters extends Equatable {
  final String? countryId;
  final String? cityId;
  final String? nameAr;
  final String? nameEn;
  final String? phone;
  final String? phone_code;
  final File? image;
  final String? coordinates;
  final String? mapLocation;
  final String? truckTypeAr;
  final String? truckTypeEn;
  final List<File>? images;
  final String? email;
  final String? id;
  final String? method;

  const StoreParameters({
    this.countryId,
    this.cityId,
    this.nameAr,
    this.method,
    this.nameEn,
    this.phone,
    this.phone_code,
    this.image,
    this.coordinates,
    this.mapLocation,
    this.truckTypeAr,
    this.id,
    this.truckTypeEn,
    this.images,
    this.email,
  });

  @override
  List<Object?> get props => [
        countryId,
        cityId,
        nameAr,
        nameEn,
        phone,
        phone_code,
        image,
        coordinates,
        mapLocation,
        truckTypeAr,
        method,
        truckTypeEn,
        images,
        email,
      ];

  Future<Map<String, dynamic>> toMap() async {
    final formData = FormData();

    if (images != null) {
      for (var element in images!) {
        final compressed = await compressImage(element);
        final fileToUpload = compressed ?? element;
        formData.files.add(
          MapEntry(
            "images[]", // modified key to an array key
            await MultipartFile.fromFile(
              fileToUpload.path,
              filename: path.basename(fileToUpload.path),
            ),
          ),
        );
      }
    }

    final compressedImage = image != null ? await compressImage(image!) : null;
    final imageToUpload = compressedImage ?? image;

    Map<String, dynamic> data = {
      'country_id': countryId,
      'city_id': cityId,
      'name_ar': nameAr,
      if (method != null) "_method": method,
      'name_en': nameEn,
      'phone': phone,
      'phone_code': phone_code,
      if (imageToUpload != null)
        'image': await MultipartFile.fromFile(
          imageToUpload.path,
          filename: path.basename(imageToUpload.path),
        ),
      'coordinates': coordinates,
      'map_location': mapLocation,
      'truck_type_ar': truckTypeAr,
      'truck_type_en': truckTypeEn,
      'email': email,
    };

    for (var file in formData.files) {
      data[file.key] = file.value;
    }

    return data;
  }
}
