import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:an3am/core/utils/image_helper.dart';

class ProductParameters {
  final String? productId;
  final String? catId;
  final String? subCatId;
  final String? nameAr;
  final String? salePrice;
  final File? mainImage;
  final String? locationAr;
  final String? method;
  final String? descriptionAr;
  final String? coordinates;
  final String? mapLocation;
  final String? youtubeLink;
  final String? advantagesAr;
  final String? defectsAr;
  String? productCurrency;
  List<String>? tags;
  final List<File>? images;
  
  // New fields added:
  final String? priceType;
  final int? countryId;
  final String? phoneNumber;
  final String? phoneCode;

  ProductParameters({
    this.productId,
    this.catId,
    this.method,
    this.subCatId,
    required this.nameAr,
    required this.salePrice,
    this.mainImage,
    required this.locationAr,
    required this.descriptionAr,
    required this.coordinates,
    required this.mapLocation,
    required this.youtubeLink,
    required this.advantagesAr,
    this.defectsAr,
    this.productCurrency,
    this.tags,
    required this.images,
    // New parameters:
    this.priceType,
    this.countryId,
    this.phoneNumber,
    this.phoneCode,
  });

  Future<Map<String, dynamic>> toMap() async {
    Map<String, dynamic> data = <String, dynamic>{};

    data['category_id'] = (catId != null && catId!.isNotEmpty) ? int.parse(catId!) : '';
    data['sub_category_id'] = (subCatId != null && subCatId!.isNotEmpty) ? int.parse(subCatId!) : '';
    data['name_ar'] = nameAr;
    data['sale_price'] = salePrice;
    data['location_ar'] = locationAr;
    data['description_ar'] = descriptionAr;
    data['coordinates'] = coordinates;
    data['map_location'] = mapLocation;
    data['youtube_link'] = youtubeLink;
    data['advantages_ar'] = advantagesAr;
    data['defects_ar'] = defectsAr;
    data['product_currency'] = productCurrency ?? '1';

    // New field mappings:
    data['price_type'] = priceType;
    data['country_id'] = countryId;
    data['phone_number'] = phoneNumber;
    data['phone_code'] = phoneCode;

    if (tags != null && tags!.isNotEmpty) {
      data['tags[]'] = tags!.map((tag) => tag.trim()).toList();
    }

    if (mainImage != null) {
      File? compressedMain = await compressImage(mainImage!);
      data['main_image'] = await MultipartFile.fromFile(
        (compressedMain ?? mainImage!).path,
        filename: path.basename((compressedMain ?? mainImage!).path),
      );
    }

    if (images != null && images!.isNotEmpty) {
      List<MultipartFile> imageFiles = [];
      List<File> imagesList = List.from(images!);
      for (var image in imagesList) {
        File? compressedImage = await compressImage(image);
        String filename = path.basename((compressedImage ?? image).path);
        imageFiles.add(await MultipartFile.fromFile(
          (compressedImage ?? image).path,
          filename: filename,
        ));
      }
      data['images[]'] = imageFiles;
    }

    if (method != null) data['_method'] = method;

    return data;
  }
}
