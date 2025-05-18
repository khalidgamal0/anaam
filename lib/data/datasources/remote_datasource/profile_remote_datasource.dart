import 'package:an3am/core/network/dio_helper.dart';
import 'package:an3am/core/parameters/change_password_parameters.dart';
import 'package:an3am/core/parameters/update_profile_parameters.dart';
import 'package:an3am/data/models/base_model.dart';
import 'package:an3am/data/models/following_model/following_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/error/error_exception.dart';
import '../../../core/network/api_end_points.dart';
import '../../../core/network/error_message_model.dart';
import '../../models/notification/notification_model.dart';
import '../../models/user_model/profile_model.dart';
import '../../models/vendor_data_model.dart';
import 'package:an3am/data/models/vendor_review_model.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:an3am/core/parameters/review_vendor_parameters.dart';

class ProfileRemoteDatasource {
  final DioHelper dioHelper;

  ProfileRemoteDatasource({required this.dioHelper});

  Future<Either<ErrorException, ProfileModel>> getProfileData() async {
    try {
      final response = await dioHelper.getData(
        url: EndPoints.profile,
        token: token,
      );
      print('cubit.profileModel response');
      print(response);
      return Right(ProfileModel.fromJson(response.data["result"]));
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

  Future<Either<ErrorException, List<NotificationModel>>>
      getNotification() async {
    try {
      final response = await dioHelper.getData(
        url: EndPoints.notifications,
        token: token,
      );
      final list = List<NotificationModel>.from(
        response.data["result"].map(
          (e) => NotificationModel.fromJson(e),
        ),
      );
      return Right(list);
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

  Future<Either<ErrorException, GetVendorDetailsWidget>> showVendorDetails(
      {required int id}) async {
    try {
      final response = await dioHelper.getData(
        url: "${EndPoints.vendorDetails}/$id",
        token: token,
      );
      return Right(GetVendorDetailsWidget.fromJson(response.data));
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

  Future<Either<ErrorException, GetUserFollowingModel>> getUserFollowing(
      {required String id}) async {
    try {
      final response = await dioHelper.getData(
        url: EndPoints.userFollowing(id: id.toString()),
        token: token,
      );
      return Right(GetUserFollowingModel.fromJson(response.data));
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

  Future<Either<ErrorException, GetUserFollowingModel>> getVendorFollowing(
      {required String id}) async {
    try {
      final response = await dioHelper.getData(
        url: EndPoints.vendorFollowing(id: id.toString()),
        token: token,
      );
      return Right(GetUserFollowingModel.fromJson(response.data));
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

  Future<Either<ErrorException, BaseResponseModel>> changePassword(
      {required ChangePasswordParameters changePasswordParameters}) async {
    try {
      final response = await dioHelper.putData(
        url: EndPoints.password,
        data: FormData.fromMap(
          changePasswordParameters.toMap(),
        ),
        token: token,
      );
      return Right(BaseResponseModel.fromJson(response.data));
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

  Future<Either<ErrorException, BaseResponseModel>> followVendor(
      {required int id}) async {
    try {
      final response = await dioHelper.putData(
        url:"${EndPoints.users}/$id${EndPoints.follow}",
        token: token,
      );
      if(response.data['code'] == 200){
        Fluttertoast.showToast(msg: 'تم المتابعة بنجاح!',backgroundColor: Colors.green,textColor: Colors.white,gravity: ToastGravity.SNACKBAR,);
      }else{
        Fluttertoast.showToast(msg: 'حدث خطاء اثناء إلغاء المتابعة!!',backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);
      }
      return Right(BaseResponseModel.fromJson(response.data));
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

  Future<Either<ErrorException, BaseResponseModel>> unfollowVendor(
      {required int id}) async {
    try {
      final response = await dioHelper.putData(
        url:"${EndPoints.users}/$id${EndPoints.unfollow}",
        token: token,
      );
      if(response.data['code'] == 200){
        Fluttertoast.showToast(msg: 'تم إلغاء المتابعة بنجاح!',backgroundColor: Colors.green,textColor: Colors.white,gravity: ToastGravity.SNACKBAR,);
      }else{
        Fluttertoast.showToast(msg: 'حدث خطاء اثناء إلغاء المتابعة!!',backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);
      }
      return Right(BaseResponseModel.fromJson(response.data));
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

  Future<Either<ErrorException, BaseResponseModel>> changeProfileData(
      {required UpdateProfileParameters updateProfileParameters}) async {
    try {
      final response = await dioHelper.postData(
        url: EndPoints.profile,
        data: FormData.fromMap(
          await updateProfileParameters.toMap(),
        ),
        token: token,
      );
      return Right(BaseResponseModel.fromJson(response.data));
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


  Future<Either<ErrorException, List<VendorReviewModel>>> getVendorReviews({required int vendorId}) async {
    try {
      print('Fetching reviews for vendorId: $vendorId, token: $token');
      final response = await dioHelper.getData(
        url: EndPoints.vendorReviews(vendorId),
        token: token,
      );
      print('API Response: ${response.data}');
      if (response.data['success'] == true) {
        final reviews = (response.data['result'] as List)
            .map((review) => VendorReviewModel.fromJson(review))
            .toList();
        return Right(reviews);
      } else {
        print('API Failure: ${response.data['message']}');
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel(
              message: response.data['message'] ?? 'Unknown error',
              success: response.data['success'] ?? false,
              code: response.data['code'] ?? 400,
              errors: response.data['errors'] != null
                  ? List<String>.from(response.data['errors'])
                  : ['Failed to retrieve reviews'],
            ),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        print('DioException: ${e.message}, Response: ${e.response?.data}');
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel(
              message: e.response?.data['message'] ?? 'Network error: ${e.message}',
              success: e.response?.data['success'] ?? false,
              code: e.response?.data['code'] ?? 400,
              errors: e.response?.data['errors'] != null
                  ? List<String>.from(e.response?.data['errors'])
                  : ['Network error occurred'],
            ),
          ),
        );
      } else {
        print('Unexpected error: $e');
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel(
              message: e.toString(),
              success: false,
              code: 400,
              errors: ['Unexpected error'],
            ),
          ),
        );
      }
    }
  }

  Future<Either<ErrorException, BaseResponseModel>> addVendorReview({
    required String id,
    required ReviewVendorParameters reviewVendorParameters,
  }) async {
    print('addVendorReview: Starting request for vendorId: $id, parameters: ${reviewVendorParameters.toMap()}');
    try {
      final response = await dioHelper.postData(
        url: EndPoints.postReviewVendor(id: id),
        token: token,
        data: FormData.fromMap(reviewVendorParameters.toMap()),
      );
      print('addVendorReview: Success response received: ${response.data}');
      return Right(
        BaseResponseModel.fromJson(
          response.data,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        print('addVendorReview: DioException occurred: ${e.response?.data ?? e.message}');
        return Left(
          ErrorException(
            baseErrorModel: BaseErrorModel.fromJson(
              e.response!.data,
            ),
          ),
        );
      } else {
        print('addVendorReview: Unexpected error occurred: $e');
        rethrow;
      }
    }
  }

}
