import 'package:an3am/core/app_theme/custom_themes.dart';
import 'package:an3am/core/assets_path/images_path.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/stores_models/store_data_model.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_elevated_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/assets_path/svg_path.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../widgets/services_widgets/store_images_list_widget.dart';
import '../../../widgets/services_widgets/vet_services_images_widget.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';
import '../google_maps_screens/open_current_loctaion_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/cache_helper/cache_keys.dart';
import '../../../../core/cache_helper/shared_pref_methods.dart';
import '../../../../core/network/api_end_points.dart';

class StoreServiceDetailsScreen extends StatelessWidget {
  final StoreDataModel storeDataModel;
  const StoreServiceDetailsScreen({super.key, required this.storeDataModel});

  // Function to launch WhatsApp
  void launchWhatsApp({required String phone, required String message}) async {
    String url = "https://wa.me/$phone?text=${Uri.encodeFull(message)}";
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ServicesDetailsIntroImageWidget(image: storeDataModel.image!,),
            const CustomSizedBox(
              height: 24,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeDataModel.name??"",
                  style: CustomThemes.darkGreyColorTextTheme(context).copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const CustomSizedBox(
                  height: 16,
                ),
                IconTitleWidget(iconPath: SvgPath.location, title: storeDataModel.country!.name??""),
                const CustomSizedBox(
                  height: 16,
                ),
                IconTitleWidget(
                    iconPath: SvgPath.location,
                    title: storeDataModel.mapLocation??""),
                const CustomSizedBox(
                  height: 16,
                ),
                IconTitleWidget(
                  iconPath: SvgPath.phone,
                  title: CacheHelper.getData(key: CacheKeys.token) != null
                      ? (storeDataModel.phone_code != null && storeDataModel.phone != null
                      ? "${storeDataModel.phone_code!.replaceAll('+', '')}${storeDataModel.phone}"
                      : "الرقم غير متاح")
                      : "يرجى تسجيل الدخول لعرض الرقم",
                ),
                const CustomSizedBox(
                  height: 16,
                ),
                IconTitleWidget(
                  iconPath: SvgPath.email,
                  title: CacheHelper.getData(key: CacheKeys.token) != null 
                      ? (storeDataModel.email ?? "البريد الإلكتروني غير متاح") 
                      : "يرجي تسجيل الدخول لعرض البريد الإلكتروني",
                ),
                const CustomSizedBox(
                  height: 16,
                ),
                StoreImagesComponentBuilder(images: storeDataModel.truckImages!,),
                const CustomSizedBox(height: 48,),
                Row(
                  children: [
                    if (CacheHelper.getData(key: CacheKeys.token) != null) // Check if user is logged in
                      Expanded(
                        child: CustomElevatedButton(
                          title: LocaleKeys.contact.tr(),
                          onPressed: () {
                            final storeLink = '${EndPoints.siteUrl}stores/${storeDataModel.id}';
                            launchWhatsApp(
                              phone: "${storeDataModel.phone_code?.replaceAll('+', '')}${storeDataModel.phone}",
                              message: "مرحبًا، أنا مهتم بخدماتك. \n $storeLink"
                            );
                          },
                          titleSize: 16,
                        ),
                      ),
                    const CustomSizedBox(width: 16,),
                    Expanded(
                      child: CustomElevatedButton(
                        title: LocaleKeys.share.tr(),
                        onPressed: () {
                          final storeLink = '${EndPoints.siteUrl}stores/${storeDataModel.id}';
                          final String shareText = "تحقق من هذه الخدمة في المتجر: ${storeDataModel.name}. \n $storeLink";
                          Share.share(shareText);
                        },
                        titleSize: 16,
                      ),
                    ),
                  ],
                ),
                const CustomSizedBox(height: 24,),
                Text(
                  LocaleKeys.mapLocation.tr(),
                  style: CustomThemes.darkGreyColorTextTheme(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const CustomSizedBox(height: 24,),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>LocationOnMapScreen(initialLocation: LatLng(double.parse(storeDataModel.coordinates!.split(",").first), double.parse(storeDataModel.coordinates!.split(",").last.trim(),)),)));
                  },
                  child: SizedBox(
                    height: 193.h,
                    width: double.infinity,
                    child: Image.asset(ImagesPath.mapImage,fit: BoxFit.cover,),
                  ),
                )
              ],
            ).symmetricPadding(horizontal: 16)
          ],
        ),
      ),
    );
  }
}

class IconTitleWidget extends StatelessWidget {
  final String iconPath;
  final String title;

  const IconTitleWidget({
    super.key,
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 18.w,
          height: 18.h,
          // colorFilter: const ColorFilter.mode(
          //   AppColors.darkGreyTextColor,
          //   BlendMode.srcIn,
          // ),
        ),
        const CustomSizedBox(
          width: 24,
        ),
        Text(
          title,
          style: CustomThemes.darkGreyColorTextTheme(context).copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
