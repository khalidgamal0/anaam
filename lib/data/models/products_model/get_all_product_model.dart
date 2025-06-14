import '../base_model.dart';
import '../pagination_model.dart';
import 'product_model.dart';

class GetAllProductModel extends BaseResponseModel {
  final GetPaginatedProductResultModel? getPaginatedProductResultModel;
  final String? productCurrency;
  // New fields:
  final String? priceType;
  final int? countryId;
  final String? phoneNumber;
  final String? phoneCode;

  const GetAllProductModel({
    required super.success,
    required super.code,
    this.getPaginatedProductResultModel,
    required super.message,
    this.productCurrency,
    // New parameters:
    this.priceType,
    this.countryId,
    this.phoneNumber,
    this.phoneCode,
  });

  factory GetAllProductModel.fromJson(Map<String, dynamic> json) {
    return GetAllProductModel(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      getPaginatedProductResultModel: GetPaginatedProductResultModel.fromJson(
        json['result'],
      ),
      productCurrency: json['product_currency']?.toString(),
      // Mapping new fields from JSON:
      priceType: json['price_type']?.toString(),
      countryId: json['country_id'] is int ? json['country_id'] : int.tryParse(json['country_id']?.toString() ?? ''),
      phoneNumber: json['phone_number']?.toString(),
      phoneCode: json['phone_code']?.toString(),
    );
  }
}

class GetPaginatedProductResultModel extends PaginationModel {
  final List<ProductDataModel>? products;

  const GetPaginatedProductResultModel({
    this.products = const [],
    super.currentPage,
    super.lastPage,
    super.total,
  });

  factory GetPaginatedProductResultModel.fromJson(Map<String, dynamic> json) {
    return GetPaginatedProductResultModel(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      products: List<ProductDataModel>.from(json["data"].map((e) => ProductDataModel.fromJson(e))),
    );
  }

  @override
  List<Object?> get props => [
        products,
        lastPage,
        currentPage,
        total,
      ];
}
