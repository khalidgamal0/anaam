import 'package:equatable/equatable.dart';

class ProductDataModel extends Equatable {
  final int? id;
  final String? name;
  final int? regularPrice;
  final String? salePrice;
  final String? description;
  final String? coordinates;
  final String? youtubeLink;
  final String? advantages;
  final String? defects;
  final String? location;
  final String? mainImage;
  final bool? inStock;
  final bool? isApproved;
  final bool? isFavorite;
  final String? mapLocation;
  final int? rate;
  final UploadedBy? uploadedBy;
  final Category? category;
  final SubCategoryModel? subCategoryId;
  final List<Images>? images;
  final String? createdAt;
  final String? updatedAt;
  final String? phone; // Add phone field
  final String? productCurrency; // Add productCurrency field
  final String? tags; // Add tags field
  final String? priceType;
  final int? countryId;
  final String? phoneNumber;
  final String? phoneCode;

  const ProductDataModel({
    this.id,
    this.name,
    this.regularPrice,
    this.salePrice,
    this.description,
    this.coordinates,
    this.youtubeLink,
    this.advantages,
    this.defects,
    this.location,
    this.isFavorite,
    this.mainImage,
    this.inStock,
    this.isApproved,
    this.mapLocation,
    this.rate,
    this.uploadedBy,
    this.category,
    this.subCategoryId,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.phone, // Initialize phone
    this.productCurrency, // Initialize productCurrency
    this.tags, // Initialize tags
    this.priceType,
    this.countryId,
    this.phoneNumber,
    this.phoneCode,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'],
      name: json['name'],
      regularPrice: json['regular_price'],
      salePrice: json['sale_price'].toString(),
      description: json['description'],
      coordinates: json['coordinates'],
      youtubeLink: json['youtube_link'],
      advantages: json['advantages'],
      defects: json['defects'],
      location: json['location'],
      mainImage: json['main_image'],
      inStock: json['in_stock'],
      isFavorite: json['is_favourite'],
      isApproved: json['is_approved'],
      mapLocation: json['map_location'],
      rate: json['rate'],
      uploadedBy: json['uploaded_by'] != null
          ? UploadedBy.fromJson(json['uploaded_by'])
          : null,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      subCategoryId: json['sub_category_id'] != null
          ? SubCategoryModel.fromJson(json['sub_category_id'])
          : null,
      images: List<Images>.from(json["images"].map((e) => Images.fromJson(e))),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      phone: json['phone'], // Parse phone from JSON
      productCurrency:
          json['product_currency'], // Parse productCurrency from JSON
      tags: json['tags'], // Parse productCurrency from JSON
      priceType: json['price_type']?.toString(),
      countryId: json['country_id'] is int ? json['country_id'] : int.tryParse(json['country_id']?.toString() ?? ''),
      phoneNumber: json['phone_number']?.toString(),
      phoneCode: json['phone_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    data['description'] = description;
    data['coordinates'] = coordinates;
    data['youtube_link'] = youtubeLink;
    data['advantages'] = advantages;
    data['defects'] = defects;
    data['is_favourite'] = isFavorite;
    data['location'] = location;
    data['main_image'] = mainImage;
    data['in_stock'] = inStock;
    data['is_approved'] = isApproved;
    data['map_location'] = mapLocation;
    data['rate'] = rate;
    if (uploadedBy != null) {
      data['uploaded_by'] = uploadedBy!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['sub_category_id'] = subCategoryId;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['phone'] = phone; // Add phone to JSON
    data['product_currency'] = productCurrency; // Add productCurrency to JSON
    data['tags'] = tags; // Add productCurrency to JSON
    data['price_type'] = priceType;
    data['country_id'] = countryId;
    data['phone_number'] = phoneNumber;
    data['phone_code'] = phoneCode;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        name,
        regularPrice,
        salePrice,
        description,
        coordinates,
        youtubeLink,
        advantages,
        isFavorite,
        defects,
        location,
        mainImage,
        inStock,
        isApproved,
        mapLocation,
        rate,
        uploadedBy,
        category,
        subCategoryId,
        images,
        createdAt,
        updatedAt,
        phone, // Add phone to props
        productCurrency, // Add productCurrency to props
        tags, // Add tags to props
        priceType,
        countryId,
        phoneNumber,
        phoneCode,
      ];
}

class UploadedBy extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? email;
  final String? phone;
  final String? location;
  final String? address;
  final bool? isFollowed;
  final String? socialId;
  final String? socialType;
  final String? vendorPage;
  final String? createdAt;
  final String? updatedAt;
  final String? country_code;

  const UploadedBy(
      {this.id,
      this.name,
      this.image,
      this.email,
      this.phone,
      this.location,
      this.address,
      this.isFollowed,
      this.socialId,
      this.socialType,
      this.vendorPage,
      this.createdAt,
      this.updatedAt,
      this.country_code});

  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      address: json['address'],
      isFollowed: json['is_followed'],
      socialId: json['social_id'],
      socialType: json['social_type'],
      vendorPage: json['vendor_page'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      country_code: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['email'] = email;
    data['phone'] = phone;
    data['location'] = location;
    data['address'] = address;
    data['is_followed'] = isFollowed;
    data['social_id'] = socialId;
    data['social_type'] = socialType;
    data['vendor_page'] = vendorPage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['country_code'] = country_code;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        name,
        image,
        email,
        phone,
        location,
        address,
        isFollowed,
        socialId,
        socialType,
        vendorPage,
        createdAt,
        updatedAt,
        country_code,
      ];
}

class Category extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? parentCategory;
  final String? createdAt;
  final String? updatedAt;

  const Category({
    this.id,
    this.name,
    this.image,
    this.parentCategory,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      parentCategory: json['parent_category'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['parent_category'] = parentCategory;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [id, name, image, parentCategory, createdAt, updatedAt];
}

class Images extends Equatable {
  final int? id;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const Images({
    this.id,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      id: json['id'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        image,
        createdAt,
        updatedAt,
      ];
}

class SubCategoryModel extends Equatable {
  final int id;
  final String name;
  final String image;
  final String createdAt;
  final String updatedAt;

  const SubCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, image, createdAt, updatedAt];

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
