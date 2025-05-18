import 'package:an3am/core/app_theme/app_colors.dart';
import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/core/network/api_end_points.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_outlined_button.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import '../../../data/models/vendor_review_model.dart';

class VendorReviewsWidget extends StatelessWidget {
  final List<VendorReviewModel> reviews;
  final VoidCallback? onAddPressed;

  const VendorReviewsWidget({
    super.key,
    required this.reviews,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = CacheHelper.getData(key: CacheKeys.token) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                LocaleKeys.customerReviews.tr(),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoggedIn && onAddPressed != null)
              CustomOutlinedButton(
                height: 40.h,
                onPressed: onAddPressed,
                radius: 8.r,
                borderColor: AppColors.greyColor9D,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: AppColors.greyColor71,
                      size: 18.r,
                    ),
                    CustomSizedBox(width: 8.w),
                    Text(
                      LocaleKeys.addReview.tr(),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.greyColor71,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ).symmetricPadding(horizontal: 16),
        CustomSizedBox(height: 16.h),
        reviews.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: Text(
                    'لا توجد تقييمات',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyColor71,
                        ),
                  ),
                ),
              )
            : SizedBox(
                height: 190.h,
                child: Scrollbar(
                  thumbVisibility: true, // جعل الـ Scrollbar مرئيًا دائمًا
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    separatorBuilder: (_, index) => CustomSizedBox(width: 10.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return RatingContainerWidget(
                        rating: review.rate.toDouble(),
                        comment: review.review,
                        image: review.user.image ?? '/storage/initializing/profile.jpeg',
                        name: review.user.name,
                        date: review.createdAt,
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}

class RatingContainerWidget extends StatelessWidget {
  final double rating;
  final String comment;
  final String? image;
  final String name;
  final String date;

  const RatingContainerWidget({
    super.key,
    required this.rating,
    required this.comment,
    this.image,
    required this.name,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.greyColor9D,
          width: 0.72.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                ignoreGestures: true,
                itemCount: 5,
                itemSize: 18.r,
                itemPadding: EdgeInsets.zero,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: AppColors.orangeColor,
                ),
                onRatingUpdate: (rating) {},
              ),
              CustomSizedBox(width: 14.w),
              Text(
                "$rating",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                    ),
              ),
            ],
          ),
          CustomSizedBox(height: 7.h),
          Expanded(
            child: Text(
              comment,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp,
                    height: 1.49.h,
                    color: AppColors.blackColor,
                  ),
            ),
          ),
          CustomSizedBox(height: 5.h),
          Row(
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: image != null && image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: "${EndPoints.siteUrl}/$image",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[300]!,
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
                      )
                    : const Icon(Icons.person, size: 40),
              ),
              CustomSizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.greyColor71,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).onlyDirectionalPadding(end: 10);
  }
}