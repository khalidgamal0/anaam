import 'package:an3am/data/models/laborers_models/laborer_model.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/add_laborer_screen.dart';
import 'package:an3am/presentation/widgets/services_widgets/vet_services_item_widget.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_elevated_button.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/app_router/screens_name.dart';
import '../../../core/app_theme/app_colors.dart';
import '../../../core/app_theme/custom_themes.dart';
import '../../../core/cache_helper/cache_keys.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';
import '../../../core/constants/constants.dart';
import '../../../domain/controllers/profile_cubit/profile_cubit.dart';
import '../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../domain/controllers/services_cubit/services_state.dart';
import '../../../translations/locale_keys.g.dart';

class LaborerServicesWidget extends StatelessWidget {
  final LaborerModel laborerModel;

  const LaborerServicesWidget({
    super.key,
    required this.laborerModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesCubit, ServicesState>(
      listener: (context, state) {
        // ...existing code...
      },
      builder: (context, state) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                    height: 325.h,
                    width: double.infinity,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: laborerModel.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerFirstColor,
                        highlightColor: AppColors.shimmerSecondColor,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                    // Image.asset(
                    //   ImagesPath.personDummyImage,
                    //   fit: BoxFit.cover,
                    // ),
                    ),
                PositionedDirectional(
                  start: 15.w,
                  bottom: 18.h,
                  child: InkWell(
                    
                    onTap: () {
                      ProfileCubit.get(context).showVendorProfile(id: laborerModel.vendor!.id!).then(
                        (value) {
                          Navigator.pushNamed(
                              context, ScreenName.vendorDetailsScreen,
                              arguments: ProfileCubit.get(context).vendorProfileModel);
                        },
                      );
                    },
                    child: Container(
                      height: 48.h,
                      width: 48.w,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: laborerModel.vendor!.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerFirstColor,
                          highlightColor: AppColors.shimmerSecondColor,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const CustomSizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    laborerModel.name!,
                    style: CustomThemes.greyColor34TextTheme(context).copyWith(
                      fontSize: 14.sp,
                      height: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min, // Added to avoid overflow
                  children: [
                    if (CacheHelper.getData(key: CacheKeys.token) != null && laborerModel.vendor!.id.toString() == userId)
                      BlocConsumer<ServicesCubit, ServicesState>(
                        listener: (context, state) {
                          var cubit = ServicesCubit.get(context);
                          if (state is ShowLaborerMultiLangErrorState) {
                            Navigator.pop(context);
                          }
                          if (state is ShowLaborerMultiLangSuccessState) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddLaborerScreen(
                                  laborerMultiLangModel:
                                  cubit.laborerMultiLangModel,
                                ),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          var cubit = ServicesCubit.get(context);
                          return CustomElevatedButton(
                            title: LocaleKeys.edit.tr(),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              cubit.getMultiLangLaborer(id: laborerModel.id!);
                              showProgressIndicator(context);
                            },
                            buttonSize: Size(120.w, 40.h),
                          );
                        },
                      ),
                    const CustomSizedBox(
                      width: 8,
                    ),
                    if (CacheHelper.getData(key: CacheKeys.token) != null && laborerModel.vendor!.id.toString() != userId)
                      BlocConsumer<ServicesCubit, ServicesState>(
                        listener: (context, state) {
                          // TODO: implement listener
                        },
                        builder: (context, state) {
                          var cubit = ServicesCubit.get(context);
                          return CustomElevatedButton(
                            title: (cubit.followedVendors[laborerModel.vendor!.id!.toString()] ?? false)
                              ? LocaleKeys.unFollow.tr()
                              : LocaleKeys.follow.tr(),
                            onPressed: () {
                              if (!(cubit.followedVendors[laborerModel.vendor!.id!.toString()] ?? false)) {
                                cubit.followVendor(vendorId: laborerModel.vendor!.id!);
                              } else {
                                cubit.unfollowVendor(vendorId: laborerModel.vendor!.id!);
                              }
                            },
                            padding: EdgeInsets.zero,
                            buttonSize: Size(120.w, 40.h),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
            const CustomSizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    laborerModel.country?.name ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                ),

                if (buildFlag( laborerModel.country?.id) != null) ...[
                  buildFlag( laborerModel.country?.id)!,
                  SizedBox(width: 5.w),
                ],
              ],
            ),
            const CustomSizedBox(height: 4),


          ],
        );
      },
      buildWhen: (previous, current) {
        return true; // Ensure the return value is a boolean
      },
    );
  }
}
