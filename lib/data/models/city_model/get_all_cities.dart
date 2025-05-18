import '../base_model.dart';
import 'city_model.dart';

class GetAllCitiesModel extends BaseResponseModel {
  final List<CityModel>? citiesList;
  final int? currentPage;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<dynamic>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  const GetAllCitiesModel({
    required super.success,
    required super.code,
    required super.message,
    this.citiesList,
    this.currentPage,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory GetAllCitiesModel.fromJson(Map<String, dynamic> json) {
    List<CityModel>? cityList;
    int? currentPage;
    String? firstPageUrl;
    int? from;
    int? lastPage;
    String? lastPageUrl;
    List<dynamic>? links;
    String? nextPageUrl;
    String? path;
    int? perPage;
    String? prevPageUrl;
    int? to;
    int? total;

    if (json['result'] != null) {
      if (json['result'] is List) {
        cityList = List<CityModel>.from(
            json['result'].map((e) => CityModel.fromJson(e)));
      } else if (json['result'] is Map) {
        var resultMap = json['result'];
        if (resultMap['data'] != null && (resultMap['data'] as List).isNotEmpty) {
          cityList = List<CityModel>.from(
              (resultMap['data'] as List).map((e) => CityModel.fromJson(e)));
        }
        currentPage = int.tryParse(resultMap['current_page']?.toString() ?? '');
        firstPageUrl = resultMap['first_page_url'];
        from = int.tryParse(resultMap['from']?.toString() ?? '');
        lastPage = int.tryParse(resultMap['last_page']?.toString() ?? '');
        lastPageUrl = resultMap['last_page_url'];
        links = resultMap['links'];
        nextPageUrl = resultMap['next_page_url'];
        path = resultMap['path'];
        perPage = int.tryParse(resultMap['per_page']?.toString() ?? '');
        prevPageUrl = resultMap['prev_page_url'];
        to = int.tryParse(resultMap['to']?.toString() ?? '');
        total = int.tryParse(resultMap['total']?.toString() ?? '');
      }
    }
    return GetAllCitiesModel(
      success: json['success'],
      code: json['code'],
      message: json['message'],
      citiesList: cityList,
      currentPage: currentPage,
      firstPageUrl: firstPageUrl,
      from: from,
      lastPage: lastPage,
      lastPageUrl: lastPageUrl,
      links: links,
      nextPageUrl: nextPageUrl,
      path: path,
      perPage: perPage,
      prevPageUrl: prevPageUrl,
      to: to,
      total: total,
    );
  }
}
