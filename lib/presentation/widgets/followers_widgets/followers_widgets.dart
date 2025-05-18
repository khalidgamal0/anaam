import 'package:an3am/core/assets_path/images_path.dart';
import 'package:an3am/data/models/user_model/user_data_model.dart';
import 'package:an3am/domain/controllers/services_cubit/services_cubit.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_cubit.dart';
import 'package:an3am/core/app_router/screens_name.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme/custom_themes.dart';
import '../../../domain/controllers/services_cubit/services_state.dart';
import '../shared_widget/custom_sized_box.dart';

class FollowersWidgets extends StatelessWidget {
  final bool isAccepted;
  final UserDataModel userDataModel;

  const FollowersWidgets({
    super.key,
    required this.isAccepted,
    required this.userDataModel,
  });

  void _navigateToVendorProfile(BuildContext context) {
    ProfileCubit.get(context).showVendorProfile(id: userDataModel.id).then((_) {
      Navigator.pushNamed(
        context,
        ScreenName.vendorDetailsScreen,
        arguments: ProfileCubit.get(context).vendorProfileModel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        ServicesCubit cubit = ServicesCubit.get(context);
        return Row(
          children: [
            GestureDetector(
              onTap: () => _navigateToVendorProfile(context),
              child: Container(
                height: 40.h,
                width: 40.w,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: userDataModel.image.isNotEmpty
                    ? Image.network(
                        userDataModel.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ImagesPath.personDummyImage,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        ImagesPath.personDummyImage,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const CustomSizedBox(width: 30),
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToVendorProfile(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDataModel.name,
                      style: CustomThemes.greyColor34TextTheme(context).copyWith(
                        fontSize: 14.sp,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "${userDataModel.address}",
                      style: CustomThemes.grey7DColorTextTheme(context).copyWith(
                        fontSize: 14.sp,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isAccepted
                ? Text(
                    userDataModel.createdAt,
                    style: CustomThemes.grey7DColorTextTheme(context).copyWith(
                      fontSize: 14.sp,
                      height: 1,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : CustomElevatedButton(
                    title: cubit.followedVendors[userDataModel.id.toString()] ?? false
                        ? "إلغاء المتابعة"
                        : "متابعة",
                    onPressed: () {
                      bool isFollowed = cubit.followedVendors[userDataModel.id.toString()] ?? false;
                      if (isFollowed) {
                        cubit.unfollowVendor(vendorId: userDataModel.id);
                      } else {
                        cubit.followVendor(vendorId: userDataModel.id);
                      }
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        ScreenName.followingScreen,
                        (route) => false,
                      );
                    },
                    buttonSize: Size(132.w, 36.h),
                  ),
          ],
        );
      },
    );
  }
}
