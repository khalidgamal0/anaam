import 'package:an3am/data/models/vendor_data_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../../domain/controllers/services_cubit/services_state.dart';
import '../../../core/app_theme/app_colors.dart';
import '../shared_widget/custom_circle_button.dart';
import '../../../../core/cache_helper/cache_keys.dart';
import '../../../../core/cache_helper/shared_pref_methods.dart';

class VendorDetailsImagesWidget extends StatelessWidget {
  final VendorProfileModel vendorProfileModel;

  const VendorDetailsImagesWidget({super.key, required this.vendorProfileModel});

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = CacheHelper.getData(key: CacheKeys.token) != null;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(height: 105.h, width: 75.h),
        Container(
          height: 75.h,
          width: 75.h,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CachedNetworkImage(
            imageUrl: vendorProfileModel.image ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[300]!,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        if (isAuthenticated)
          Positioned(
            top: 60.h,
            child: BlocBuilder<ServicesCubit, ServicesState>(
              builder: (context, state) {
                final cubit = context.watch<ServicesCubit>();

                bool isFollowed = cubit.followedVendors[vendorProfileModel.id.toString()] ??
                    vendorProfileModel.isFollowed ??
                    false;

                return CustomCircleButton(
                  width: 28.w,
                  height: 28.h,
                  iconPath: isFollowed ? Icons.check : Icons.add,
                  iconSize: 20.r,
                  iconColor: Colors.white,
                  onPressed: () {
                    isFollowed
                        ? cubit.unfollowVendor(vendorId: vendorProfileModel.id!)
                        : cubit.followVendor(vendorId: vendorProfileModel.id!);
                  },
                  backgroundColor: isFollowed ? AppColors.primaryColor : AppColors.orangeColor,
                );
              },
            ),
          ),
      ],
    );
  }
}
