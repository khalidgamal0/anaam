import 'dart:io';

import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/network/error_message_model.dart';
import 'package:an3am/core/parameters/register_parameters.dart';
import 'package:an3am/data/datasources/remote_datasource/auth_remote_datasource.dart';
import 'package:an3am/data/models/auth_models/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';
import '../../../core/services/services_locator.dart';
import '../../../data/datasources/remote_datasource/cities_and_countries_remote_datasource.dart';
import '../../../data/models/country_model/country_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  final AuthRemoteDataSource authRemoteDataSource = sl();
  final CitiesAndCountriesRemoteDatasource citiesAndCountriesRemoteDatasource =
      sl();
  LoginAndRegisterModel? loginAndRegisterModel;
  BaseErrorModel? baseErrorModel;
  String? selectedRole = 'vendor'; // Set default role to 'vendor'
  List<CountryModel> countriesList = [];
  CountryModel? chosenCity;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController loginEmailController = TextEditingController();

  void login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoadingState());
    final response = await authRemoteDataSource.login(
      email: email,
      password: password,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(
          LoginErrorState(
            error: l.baseErrorModel.errors != null
                ? baseErrorModel!.errors![0]
                : l.baseErrorModel.message,
          ),
        );
      },
      (r) async {
        loginAndRegisterModel = r;
        await CacheHelper.saveData(
          key: CacheKeys.token,
          value: r.loginAndRegisterDataModel!.token!,
        );
        await CacheHelper.saveData(
          key: CacheKeys.userName,
          value: r.loginAndRegisterDataModel!.user!.name.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userEmail,
          value: r.loginAndRegisterDataModel!.user!.email.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.phone,
          value: r.loginAndRegisterDataModel!.user!.phone.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.profileImage,
          value: r.loginAndRegisterDataModel!.user!.image.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userId,
          value: r.loginAndRegisterDataModel!.user!.id,
        );
        await CacheHelper.saveData(
          key: CacheKeys.userType,
          value: r.loginAndRegisterDataModel!.user!.type,
        );
        token = CacheHelper.getData(
          key: CacheKeys.token,
        );
        userId = CacheHelper.getData(
          key: CacheKeys.userId.toString(),
        ).toString();
        userType = CacheHelper.getData(
          key: CacheKeys.userType.toString(),
        );
        emit(LoginSuccessState());
      },
    );
  }

  void socialLogin({
    required String email,
    required String socialId,
    required String name,
    required String socialType,
    required String userType,
  }) async {
    emit(SocialLoginLoadingState());
    final response = await authRemoteDataSource.authLogin(
      email: email,
      socialId: socialId,
      name: name,
      socialType: socialType,
      userType: userType,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(
          SocialLoginErrorState(
            error: l.baseErrorModel.errors != null
                ? baseErrorModel!.errors![0]
                : l.baseErrorModel.message,
          ),
        );
      },
      (r) async {
        loginAndRegisterModel = r;
        await CacheHelper.saveData(
          key: CacheKeys.token,
          value: r.loginAndRegisterDataModel!.token!,
        );
        await CacheHelper.saveData(
          key: CacheKeys.userId,
          value: r.loginAndRegisterDataModel!.user!.id,
        );
        await CacheHelper.saveData(
          key: CacheKeys.profileImage,
          value: r.loginAndRegisterDataModel!.user!.image.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userType,
          value: r.loginAndRegisterDataModel!.user!.type,
        );
        await CacheHelper.saveData(
          key: CacheKeys.userName,
          value: r.loginAndRegisterDataModel!.user!.name.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userEmail,
          value: r.loginAndRegisterDataModel!.user!.email.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.phone,
          value: r.loginAndRegisterDataModel!.user!.phone.toString(),
        );
        token = CacheHelper.getData(
          key: CacheKeys.token,
        );
        userId = CacheHelper.getData(
          key: CacheKeys.userId.toString(),
        ).toString();
        userType = CacheHelper.getData(
          key: CacheKeys.userType.toString(),
        );
        emit(SocialLoginSuccessState());
      },
    );
  }

  void register({
    required RegisterParameters registerParameters,
  }) async {
    emit(RegisterLoadingState());
    final response = await authRemoteDataSource.register(
      parameters: registerParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(
          RegisterErrorState(
            error: baseErrorModel?.errors?[0] ?? "",
          ),
        );
      },
      (r) async {
        loginAndRegisterModel = r;
        await CacheHelper.saveData(
          key: CacheKeys.token,
          value: r.loginAndRegisterDataModel!.token!,
        );
        await CacheHelper.saveData(
          key: CacheKeys.userId,
          value: r.loginAndRegisterDataModel!.user!.id.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userName,
          value: r.loginAndRegisterDataModel!.user!.name.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userEmail,
          value: r.loginAndRegisterDataModel!.user!.email.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.phone,
          value: r.loginAndRegisterDataModel!.user!.phone.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.userType,
          value: r.loginAndRegisterDataModel!.user!.type.toString(),
        );
        await CacheHelper.saveData(
          key: CacheKeys.profileImage,
          value: r.loginAndRegisterDataModel!.user!.image.toString(),
        );
        token = CacheHelper.getData(
          key: CacheKeys.token,
        );
        userId = CacheHelper.getData(
          key: CacheKeys.userId.toString(),
        );
        userType = CacheHelper.getData(
          key: CacheKeys.userType.toString(),
        );
        emit(RegisterSuccessState());
      },
    );
  }

  void changeRegisterType(String? value) {
    selectedRole = value;
    emit(ChangeRoleState());
  }

  void changeCity(CountryModel? value) {
    chosenCity = value;
    emit(ChangeCityState());
  }

  List<String> scopes = [
    'email',
    'profile',
  ];

  Future<void> googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? googleClientIdIos : null,
      scopes: scopes,
    );
    // if(googleSignIn.currentUser!=null){
    //   await googleSignIn.signOut();
    // }
    try {
      final response = await googleSignIn.signIn();
      socialLogin(
        email: response?.email ?? "",
        socialId: response?.id ?? "",
        name: response?.displayName ?? "",
        socialType: "google",
        userType: selectedRole ?? "",
      );
    } catch (error) {
      // print(error);
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      socialLogin(
        email: credential.email ?? "",
        socialId: credential.userIdentifier ?? "",
        name: credential.givenName ?? "",
        socialType: "apple",
        userType: selectedRole ?? "",
      );
    } catch (error) {
      // print(error.toString());
    }
  }

  Future<void> twitterSignIn() async {
    final twitterLogin = TwitterLogin(
      // Consumer API keys
      apiKey: 'd8u6VdPmV7QPRSCXjxYmKln8J',
      // Consumer API Secret keys
      apiSecretKey: 'gA89LiVHwJH5k0l4zZkfqjNS0YoFd88WYIeoTgfjPA5ZDuMHsN',
      // Registered Callback URLs in TwitterApp
      // Android is a deeplink
      // iOS is a URLScheme
      redirectURI: 'mainLayoutScreen://',
    );
    final authResult = await twitterLogin.login();
    switch (authResult.status) {
      case TwitterLoginStatus.loggedIn:
        // success
        socialLogin(
          email: authResult.user?.email ?? "",
          socialId: authResult.user?.id.toString() ?? "",
          name: authResult.user?.name ?? "",
          socialType: "twitter",
          userType: selectedRole ?? "",
        );
        break;
      case TwitterLoginStatus.cancelledByUser:
        // cancel
        break;
      case TwitterLoginStatus.error:
        // error
        break;
      default:
    }
  }

  void getAllCountries() async {
    emit(GetAllCountriesLoadingState());
    final response = await citiesAndCountriesRemoteDatasource.getAllCountries();
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetAllCountriesErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        countriesList.addAll(r.countriesList!);
        emit(GetAllCountriesSuccessState());
      },
    );
  }

  void handleLogout() {
    emit(AuthInitial());
  }

  @override
  Future<void> close() {
    handleLogout();
    return super.close();
  }
}
