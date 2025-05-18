import 'dart:async';
import 'package:an3am/core/app_router/screens_name.dart';
import 'package:an3am/core/assets_path/images_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    animation = Tween<double>(begin: 0,end: 1).animate(controller);
    controller.forward();
    _loading();
    // if(CacheHelper.getData(key: CacheKeys.token) != null) {
    //   ProductsCubit.get(context)..allProductsPageNumber = 1..getAllProducts();
    // }
    super.initState();
  }

  void _loading(){
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, ScreenName.mainLayoutScreen);
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(ImagesPath.splashBackGround,fit: BoxFit.cover,),
            ),
            // FadeTransition(opacity: animation,child: SvgPicture.asset(SvgPath.anaanLogo,width: 214.w,height: 285.h,),)
            FadeTransition(opacity: animation,child: Image.asset(ImagesPath.anaamLogo,width: 214.w,height: 285.h,),)
          ],
        ),
      ),
    );
  }
}
