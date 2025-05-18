import 'package:an3am/data/models/base_model.dart';
import 'package:an3am/data/models/pagination_model.dart';
import 'package:an3am/data/models/vet_models/vet_model.dart';

class GetAllVetModel extends BaseResponseModel {
  final VetPaginatedModel? storePaginatedModel;

  const GetAllVetModel({
    required super.success,
    required super.code,
    required super.message,
    this.storePaginatedModel,
  });

  factory GetAllVetModel.fromJson(Map<String, dynamic> json) {
    return GetAllVetModel(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      storePaginatedModel: json['result'] != null
          ? VetPaginatedModel.fromJson(json['result'])
          : null,
    );
  }
}

class VetPaginatedModel extends PaginationModel {
  final List<VetModel>? vetList;

  const VetPaginatedModel({
    required super.currentPage,
    required super.lastPage,
    required super.total,
    this.vetList,
  });

  factory VetPaginatedModel.fromJson(Map<String, dynamic> json) {
    return VetPaginatedModel(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      vetList: json['data'] != null && json['data'].isNotEmpty
          ? List<VetModel>.from(
          json['data'].map((e) => VetModel.fromJson(e)))
          : null,
    );
  }
}

List list = [];
