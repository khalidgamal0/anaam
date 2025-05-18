import 'package:an3am/data/models/base_model.dart';
import 'product_model.dart';

class UploadOrUpdateProductModel extends BaseResponseModel {
  final ProductDataModel? productDataModel;
  final String? productCurrency; // Add productCurrency field
  // New fields added:
  final String? priceType;
  final int? countryId;
  final String? phoneNumber;
  final String? phoneCode;

  const UploadOrUpdateProductModel({
    required super.success,
    required super.code,
    required super.message,
    this.productDataModel,
    this.productCurrency, // Initialize productCurrency
    // New parameters:
    this.priceType,
    this.countryId,
    this.phoneNumber,
    this.phoneCode,
  });

  factory UploadOrUpdateProductModel.fromJson(Map<String, dynamic> json) {
    return UploadOrUpdateProductModel(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      productDataModel: ProductDataModel.fromJson(
        json["result"],
      ),
      productCurrency: json['product_currency'], // Parse productCurrency from JSON
      // Mapping new fields from JSON:
      priceType: json['price_type']?.toString(),
      countryId: json['country_id'] is int ? json['country_id'] : int.tryParse(json['country_id']?.toString() ?? ''),
      phoneNumber: json['phone_number']?.toString(),
      phoneCode: json['phone_code']?.toString(),
    );
  }
}


