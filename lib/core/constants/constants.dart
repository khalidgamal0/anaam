
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app_theme/app_colors.dart';
import '../cache_helper/cache_keys.dart';
import '../cache_helper/shared_pref_methods.dart';

void showProgressIndicator(BuildContext context) {
  AlertDialog alertDialog = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: Container(
        padding: EdgeInsets.all(
          32.sp,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.whiteColor,
        ),
        child: const CircularProgressIndicator.adaptive(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
    ),

  );
  showDialog(
      context: context,
      builder: (context) => WillPopScope(
        child: alertDialog,
        onWillPop: () async {
          return true;
        },
      ),
      barrierDismissible: false);
}

void showToast({required int errorType, required String message}){
  if(errorType == 0){
    Fluttertoast.showToast(msg: message,backgroundColor: Colors.green,textColor: Colors.white,gravity: ToastGravity.SNACKBAR,);
  }else{
    Fluttertoast.showToast(msg: message,backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);
  }
}
String? token = CacheHelper.getData(key: CacheKeys.token);
String? onboarding = CacheHelper.getData(key: CacheKeys.onboarding);
String? googleClientIdIos = "519171617357-ea5stt0mq1vavf89nvj9e15rgnc0ikjp.apps.googleusercontent.com";
String? googleClientIdAndroid = "519171617357-gb5jkffo2fpdek02j89souen5balhfos.apps.googleusercontent.com";
String? userId = CacheHelper.getData(key: CacheKeys.userId).toString();
String? userType = CacheHelper.getData(key: CacheKeys.userType);
String? username = CacheHelper.getData(key: CacheKeys.userName);
String? userEmail = CacheHelper.getData(key: CacheKeys.userEmail);
String? phone = CacheHelper.getData(key: CacheKeys.phone);
String? initialLocale = CacheHelper.getData(key: CacheKeys.initialLocale)??"ar";
Size appBarSize = AppBar().preferredSize; 