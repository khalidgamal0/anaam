import 'dart:developer';

import 'package:an3am/core/error/error_exception.dart';
import 'package:an3am/core/parameters/laborer_parameters.dart';
import 'package:an3am/data/datasources/remote_datasource/services_base_remote_data_source.dart';
import 'package:an3am/data/models/base_model.dart';
import 'package:an3am/data/models/laborers_models/get_all_laborers_model.dart';
import 'package:an3am/data/models/laborers_models/laborer_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/network/api_end_points.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/error_message_model.dart';

class LaborersRemoteDatasource extends ServicesBaseDatasource<
    GetAllLaborersModel, LaborerModel, LaborerParameters> {
  final DioHelper dioHelper;

  LaborersRemoteDatasource({required this.dioHelper});

  @override
  Future<Either<ErrorException, BaseResponseModel>> delete(
      {required int id}) async {
    try {
      final response = await dioHelper.deleteData(
        url: "${EndPoints.laborers}/$id",
        token: token,
      );
      return Right(
        BaseResponseModel.fromJson(
          response.data,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(
              e.response!.data,
            ),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<ErrorException, GetAllLaborersModel>> getAll(
      {required int pageNumber, String? mapIds,}) async
  {
    try {
      String url = "${EndPoints.laborers}?page=$pageNumber";
      if (mapIds != null) {
        url += "&mapids=$mapIds";
      }
      log("urlurlurlurlurlurlurlurlurlurlurlurl ${url}");
      final response = await dioHelper.getData(
        url: url,
        token: token,
      );
      return Right(GetAllLaborersModel.fromJson(response.data));
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(e.response!.data),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<ErrorException, GetAllLaborersModel>> getUserFollowing(
      {required int pageNumber})
  async {
    try {
      final response = await dioHelper.getData(
        url: "${EndPoints.laborers}${EndPoints.following}?page=$pageNumber",
        token: token,
      );
      return Right(GetAllLaborersModel.fromJson(response.data));
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(e.response!.data),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<ErrorException, LaborerModel>> showSingle(
      {required int id,})
  async {
    try {
      final response = await dioHelper.getData(
        url: "${EndPoints.laborers}/$id",
        token: token,
      );
      return Right(
        LaborerModel.fromJson(response.data),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(e.response!.data),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<ErrorException, LaborerModel>> update(
      {required LaborerParameters parameters}) async {
    try {
      final response = await dioHelper.postData(
        url: "${EndPoints.laborers}/${parameters.id}",
        data: FormData.fromMap(
          await parameters.toMap(),
        ),
        token: token,
      );
      return Right(
        LaborerModel.fromJson(
          response.data,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(
              e.response!.data,
            ),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<Either<ErrorException, LaborerModel>> upload(
      {required LaborerParameters parameters}) async {
    try {
      final response = await dioHelper.postData(
        url: EndPoints.laborers,
        data: FormData.fromMap(
          await parameters.toMap(),
        ),
        token: token,
      );
      return Right(
        LaborerModel.fromJson(response.data),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(e.response!.data),
          ),
        );
      } else {
        rethrow;
      }
    }
  }


}
