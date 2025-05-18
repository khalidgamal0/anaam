import 'dart:io';

import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/parameters/change_password_parameters.dart';
import 'package:an3am/core/parameters/update_profile_parameters.dart';
import 'package:an3am/data/datasources/remote_datasource/profile_remote_datasource.dart';
import 'package:an3am/data/models/base_model.dart';
import 'package:an3am/data/models/notification/notification_model.dart';
import 'package:an3am/data/models/user_model/profile_model.dart';
import 'package:an3am/data/models/vendor_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/error_message_model.dart';
import '../../../core/services/services_locator.dart';
import '../../../data/models/user_model/user_data_model.dart';
import 'profile_state.dart';
import 'package:an3am/data/models/vendor_review_model.dart';
import 'package:an3am/core/parameters/review_vendor_parameters.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  static ProfileCubit get(context) => BlocProvider.of(context);
  final ProfileRemoteDatasource profileRemoteDatasource = sl();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  // Added new controllers
  final TextEditingController countryIdController = TextEditingController();
  final TextEditingController cityIdController = TextEditingController();
  final TextEditingController stateIdController = TextEditingController();

  final TextEditingController addVendorReviewName = TextEditingController();
  final TextEditingController addVendorReviewEmail = TextEditingController();
  final TextEditingController addVendorReviewDescription =
      TextEditingController();
  final TextEditingController addVendorReviewAge = TextEditingController();
  final TextEditingController addVendorReviewLocation =
      TextEditingController();
  
  int addVendorReviewRate = 0;

  ProfileModel? profileModel;
  VendorProfileModel? vendorProfileModel;
  BaseErrorModel? baseErrorModel;
  BaseResponseModel? baseResponseModel;
  bool isLoggedIn = true;
  File? profileImage;

  final _picker = ImagePicker();

  Future<void> getImagePick() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(GetPickedImageSuccessState());
    } else {
      emit(GetPickedImageErrorState());
    }
  }

  void logout() {
    isLoggedIn = false;
    emit(LogoutStatus());
  }

  void login() {
    isLoggedIn = true;
    emit(LoginStatus());
  }

  bool getProfileData = false;

  void showProfile() async {
    getProfileData = true;
    emit(ShowProfileLoadingState());
    final response = await profileRemoteDatasource.getProfileData();
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;

        getProfileData = false;
        emit(ShowProfileErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        profileModel = r;
        getProfileData = false;
        CacheHelper.saveData(key: CacheKeys.profileImage, value: r.image);
        emit(ShowProfileSuccessState());
      },
    );
  }


  // Vendor Review
  List<VendorReviewModel> vendorReviews = [];
  bool getVendorReviewsLoading = false;

  Future<void> fetchVendorReviews(int vendorId) async {
    getVendorReviewsLoading = true;
    emit(VendorReviewsLoadingState());
    final response = await profileRemoteDatasource.getVendorReviews(vendorId: vendorId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getVendorReviewsLoading = false;
        emit(VendorReviewsErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        vendorReviews = r;
        getVendorReviewsLoading = false;
        emit(VendorReviewsLoadedState());
      },
    );
  }

  void changeVendorReviewRate(double value) {
    addVendorReviewRate = value.round();
    emit(ChangeVendorReviewRate());
  }
  
  void addVendorReview({
    required ReviewVendorParameters reviewVendorParameters,
    required String id,
  }) async {
    emit(UploadReviewVendorLoadingState());
    final response = await profileRemoteDatasource.addVendorReview(
      id: id,
      reviewVendorParameters: reviewVendorParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UploadReviewVendorErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) {
        emit(UploadReviewVendorSuccessState(baseResponseModel: r));
      },
    );
  }

  void getNotification() async {
    emit(GetNotificationsLoadingState());
    final response = await profileRemoteDatasource.getNotification();
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;

        emit(
          GetNotificationsErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message,
          ),
        );
      },
      (r) async {
        notifications = r;
        emit(GetNotificationsSuccessState());
      },
    );
  }

  List<NotificationModel> notifications = [];

  bool getUserFollowingLoading = false;

  Map<String, dynamic> userFollowing = {};
  List<UserDataModel> userDataList = [];

  void getUserFollowing() async {
    userDataList = [];
    getUserFollowingLoading = true;
    emit(GetUserFollowingLoadingState());
    final response = await profileRemoteDatasource.getUserFollowing(
      id: userId!,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getUserFollowingLoading = false;
        emit(GetUserFollowingErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        if (r.getUserFollowingPaginatedModel!.userModel != null) {
          userDataList.addAll(r.getUserFollowingPaginatedModel!.userModel!);
        }
        getUserFollowingLoading = false;
        emit(GetUserFollowingSuccessState());
      },
    );
  }

  bool getVendorFollowingLoading = false;
  List<UserDataModel> vendorFollowingList = [];

  void getVendorFollowing() async {
    vendorFollowingList = [];
    getVendorFollowingLoading = true;
    emit(GetVendorFollowingLoadingState());
    final response = await profileRemoteDatasource.getVendorFollowing(
      id: userId!,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getVendorFollowingLoading = false;
        emit(GetVendorFollowingErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        if (r.getUserFollowingPaginatedModel!.userModel != null) {
          vendorFollowingList
              .addAll(r.getUserFollowingPaginatedModel!.userModel!);
        }

        getVendorFollowingLoading = false;
        emit(GetVendorFollowingSuccessState());
      },
    );
  }

  bool getVendorProfileData = false;

  Future showVendorProfile({required int id}) async {
    getVendorProfileData = true;
    vendorProfileModel = null;
    emit(ShowVendorProfileLoadingState());
    final response = await profileRemoteDatasource.showVendorDetails(id: id);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;

        getVendorProfileData = false;
        emit(ShowVendorProfileErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        vendorProfileModel = r.vendorProfileModel;
        getVendorProfileData = false;
        emit(ShowVendorProfileSuccessState());
      },
    );
  }

  void updateProfile({
    required UpdateProfileParameters updateProfileParameters,
  }) async {
    emit(UpdateProfileLoadingState());
    final response = await profileRemoteDatasource.changeProfileData(
      updateProfileParameters: updateProfileParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(
          UpdateProfileErrorState(
            error: baseErrorModel?.errors?[0] ?? "",
          ),
        );
      },
      (r) async {
        baseResponseModel = r;
        profileImage = null;
        showProfile();
        emit(UpdateProfileSuccessState());
      },
    );
  }

  void updatePassword({
    required ChangePasswordParameters changePasswordParameters,
  }) async {
    emit(UpdatePasswordLoadingState());
    final response = await profileRemoteDatasource.changePassword(
      changePasswordParameters: changePasswordParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(
          UpdatePasswordErrorState(
            error: baseErrorModel?.errors?[0] ?? "",
          ),
        );
      },
      (r) async {
        baseResponseModel = r;
        emit(UpdatePasswordSuccessState());
      },
    );
  }

  void handleLogout() {
    emit(ProfileInitial());
  }

  @override
  Future<void> close() {
    handleLogout();
    return super.close();
  }
}
