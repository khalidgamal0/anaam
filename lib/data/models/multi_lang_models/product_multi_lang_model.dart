import 'package:equatable/equatable.dart';

import 'image_multi_lang_model.dart';

class ProductMultiLangModel extends Equatable {
  final int? id;
  final Map<String, String>? name;
  final int? regularPrice;
  final int? salePrice;
  final Map<String, String>? description;
  final String? youtubeLink;
  final Map<String, String>? advantages;
  final Map<String, String>? defects;
  final Map<String, String>? location;
  final Map<String, String>? mainImage;
  final int? isApproved;
  final int? inStock;
  final String? coordinates;
  final String? mapLocation;
  final int? uploadedById;
  final int? categoryId;
  final List<ProductMultiLangImageModel>? images;
  final int? subCategoryId;
  final int? statusId;
  final String? createdAt;
  final String? updatedAt;
  final List<String>? tags;
  final String? productCurrency;
  // New fields:
  final String? priceType;
  final int? countryId;
  final String? phoneNumber;
  final String? phoneCode;

  const ProductMultiLangModel({
    this.id,
    this.name,
    this.regularPrice,
    this.salePrice,
    this.images,
    this.description,
    this.youtubeLink,
    this.advantages,
    this.defects,
    this.location,
    this.mainImage,
    this.isApproved,
    this.inStock,
    this.coordinates,
    this.mapLocation,
    this.uploadedById,
    this.categoryId,
    this.subCategoryId,
    this.statusId,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.productCurrency,
    // New parameters:
    this.priceType,
    this.countryId,
    this.phoneNumber,
    this.phoneCode,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        regularPrice,
        salePrice,
        description,
        youtubeLink,
        advantages,
        defects,
        location,
        mainImage,
        isApproved,
        inStock,
        coordinates,
        mapLocation,
        uploadedById,
        categoryId,
        subCategoryId,
        statusId,
        createdAt,
        updatedAt,
        tags,
        productCurrency,
        // New fields in props:
        priceType,
        countryId,
        phoneNumber,
        phoneCode,
      ];

  factory ProductMultiLangModel.fromJson(Map<String, dynamic> json) {
    // Safely handle tags parsing
    List<String>? parsedTags;
    try {
      if (json['tags'] != null && json['tags'] is List) {
        var tagsList = json['tags'] as List;
        if (tagsList.isNotEmpty) {
          if (tagsList.first is Map) {
            parsedTags = tagsList
                .map((tag) {
                  if (tag is Map && tag['name'] is Map) {
                    return (tag['name']['ar'] ?? '').toString();
                  }
                  return '';
                })
                .where((tag) => tag.isNotEmpty)
                .toList();
          } else {
            parsedTags = tagsList.map((tag) => tag.toString()).toList();
          }
        }
      }
    } catch (e) {
      parsedTags = [];
    }

    // Safely handle multi-language fields
    Map<String, String>? parseName() {
      try {
        if (json['name'] != null) {
          return Map<String, String>.from(
            Map.fromEntries(
              (json['name'] as Map).entries.map(
                    (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing name: $e");
      }
      return null;
    }

    Map<String, String>? parseLocation() {
      try {
        if (json['location'] != null) {
          return Map<String, String>.from(
            Map.fromEntries(
              (json['location'] as Map).entries.map(
                    (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing location: $e");
      }
      return null;
    }

    Map<String, String>? parseDescription() {
      try {
        if (json['description'] != null) {
          return Map<String, String>.from(
            Map.fromEntries(
              (json['description'] as Map).entries.map(
                    (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing description: $e");
      }
      return null;
    }

    // Similar safe parsing for other map fields
    Map<String, String>? parseAdvantages() {
      try {
        if (json['advantages'] != null) {
          return Map<String, String>.from(
            Map.fromEntries(
              (json['advantages'] as Map).entries.map(
                    (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing advantages: $e");
      }
      return null;
    }

    Map<String, String>? parseDefects() {
      try {
        if (json['defects'] != null) {
          return Map<String, String>.from(
            Map.fromEntries(
              (json['defects'] as Map).entries.map(
                    (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error parsing defects: $e");
      }
      return null;
    }

    return ProductMultiLangModel(
      id: json['id'],
      name: parseName(),
      regularPrice: json['sale_price'],
      salePrice: json['sale_price'],
      description: parseDescription(),
      youtubeLink: json['youtube_link']?.toString(),
      advantages: parseAdvantages(),
      defects: parseDefects(),
      location: parseLocation(),
      mainImage: json['main_image'] != null
          ? Map<String, String>.from(
              Map.fromEntries(
                (json['main_image'] as Map).entries.map(
                      (e) => MapEntry(e.key.toString(), e.value?.toString() ?? ''),
                    ),
              ),
            )
          : null,
      isApproved: json['is_approved'],
      inStock: json['in_stock'],
      coordinates: json['coordinates']?.toString(),
      images: json['images'].isNotEmpty && json['images'] != null
          ? List<ProductMultiLangImageModel>.from(
              json['images'].map((e) => ProductMultiLangImageModel.fromJson(e)),
            )
          : null,
      mapLocation: json['map_location']?.toString(),
      uploadedById: json['uploaded_by_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      statusId: json['status_id'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      tags: parsedTags,
      productCurrency: json['product_currency']?.toString(),
      // Mapping new fields from JSON:
      priceType: json['price_type']?.toString(),
      countryId: json['country_id'] is int ? json['country_id'] : int.tryParse(json['country_id']?.toString() ?? ''),
      phoneNumber: json['phone_number']?.toString(),
      phoneCode: json['phone_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null)'id': id,
      'name': name,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'description': description,
      'youtube_link': youtubeLink,
      'advantages': advantages,
      'defects': defects,
      'location': location,
      'main_image': mainImage,
      'is_approved': isApproved,
      'in_stock': inStock,
      'coordinates': coordinates,
      'map_location': mapLocation,
      'uploaded_by_id': uploadedById,
      'category_id': categoryId,
      if(subCategoryId!=null)'sub_category_id': subCategoryId,
      'status_id': statusId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (tags != null) 'tags': tags,
      'product_currency': productCurrency,
      // New fields added:
      'price_type': priceType,
      'country_id': countryId,
      'phone_number': phoneNumber,
      'phone_code': phoneCode,
    };
  }
}
