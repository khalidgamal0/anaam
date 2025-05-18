import 'package:an3am/core/network/dio_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/error/error_exception.dart';
import '../../../core/network/api_end_points.dart';
import '../../../core/network/error_message_model.dart';
import '../../../data/models/user_model/account_data_model.dart';


class AccountRemoteDatasource {
  final DioHelper dioHelper;

  AccountRemoteDatasource({required this.dioHelper});

  Future<Either<ErrorException, AccountDataModel>> getAccountData() async {
    try {
      final response = await dioHelper.getData(
        url: EndPoints.getaccount,
        token: token,
      );
      return Right(AccountDataModel.fromJson(response.data["result"]["account"]));
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
