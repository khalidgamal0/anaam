
import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:dio/dio.dart';
import 'api_end_points.dart';

class DioHelper {
  static late Dio dio;

   static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30)
      ),
    );
  }

   Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
     String? token = await CacheHelper.getData(key: CacheKeys.token);
     dio.options.headers = {
      'Content-Type': 'application/json',
      // 'lang': '',
      if (token != null) "Authorization": "Bearer $token",
      'Accept': 'text/plain',
      "Content-Language":CacheHelper.getData(key: CacheKeys.initialLocale)??"ar"
    };
    return await dio.get(url, queryParameters: query,);
  }

   Future<Response> postData({
    required String url,
    dynamic query,
    dynamic data,
    String? token,
  }) async {
     token  = await CacheHelper.getData(key: CacheKeys.token);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'lang': CacheHelper.getData(key:CacheKeys.initialLocale)??'ar',
      if (token != null) "Authorization": "Bearer $token",
      'Accept': 'text/plain',
    };
    return await dio.post(url, queryParameters: query, data: data);

    // return ;
  }

   Future<Response> deleteData({
    required String url,
    dynamic query,
    dynamic data,
    String lang = 'ar',
    String? token,
    String? contentType,
  }) async {
    dio.options.headers = {
      'Content-Type': contentType??'application/json',
      'lang': '',
      if (token != null) "Authorization": "Bearer $token",
      'Accept': 'text/plain',
    };
    return await dio.delete(url, queryParameters: query, data: data);
  }

   Future<Response> putData({
    required String url,
    dynamic query,
    dynamic data,
    String lang = 'ar',
    String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) "Authorization": "Bearer $token",
      'Accept': 'text/plain',
    };
    return await dio.put(
      url,
      queryParameters: query,
      data: data,
    );
  }
}
