import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/parameters/review_vendor_parameters.dart';
import 'package:an3am/presentation/widgets/auth_widgets/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_theme/app_colors.dart';
import '../../../domain/controllers/profile_cubit/profile_cubit.dart';
import '../../../domain/controllers/profile_cubit/profile_state.dart';
import '../../../translations/locale_keys.g.dart';
import '../shared_widget/custom_divider.dart';
import '../shared_widget/custom_elevated_button.dart';
import '../shared_widget/custom_sized_box.dart';
import 'base_bottom_sheet_widget.dart';
import '../shared_widget/bottom_sheet_title_text_widget.dart';

class AddVendorReviewBottomSheet extends StatefulWidget {
  final String id;

  const AddVendorReviewBottomSheet({super.key, required this.id});

  @override
  State<AddVendorReviewBottomSheet> createState() =>
      _AddVendorReviewBottomSheetState();
}

class _AddVendorReviewBottomSheetState
    extends State<AddVendorReviewBottomSheet> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheetWidget(
      child: SingleChildScrollView(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            ProfileCubit cubit = ProfileCubit.get(context);
            if (state is UploadReviewVendorLoadingState) {
              showProgressIndicator(context);
            }
            if (state is UploadReviewVendorSuccessState) {
              Navigator.pop(context);
              Navigator.pop(context);
              cubit.addVendorReviewEmail.clear();
              cubit.addVendorReviewLocation.clear();
              cubit.addVendorReviewAge.clear();
              cubit.addVendorReviewName.clear();
              cubit.addVendorReviewDescription.clear();
              cubit.addVendorReviewRate = 0;
              // cubit.fetchVendorReviews(vendorId: widget.id);
              showToast(
                  errorType: 0, message: state.baseResponseModel.message!);
            }
            if (state is UploadReviewVendorErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
          },
          builder: (context, state) {
            ProfileCubit cubit = ProfileCubit.get(context);
            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScreenTitleTextWidget(
                    title: LocaleKeys.rating.tr(),
                  ),
                  const CustomSizedBox(
                    height: 1,
                  ),
                  const CustomDivider(),
                  const CustomSizedBox(
                    height: 29,
                  ),
                  CustomTextField(
                    hintText: LocaleKeys.fullName.tr(),
                    controller: cubit.addVendorReviewName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.dataMustBeEntered.tr();
                      }
                      return null;
                    },
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  Container(
                    height: 48.h,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.authBorderColor,
                        width: 0.74.w,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.rating.tr(),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        RatingBar.builder(
                          initialRating: cubit.addVendorReviewRate.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0.w),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_border_outlined,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: cubit.changeVendorReviewRate,
                        ),
                      ],
                    ),
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  CustomTextField(
                    hintText: "${LocaleKeys.email.tr()}*",
                    controller: cubit.addVendorReviewEmail,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.dataMustBeEntered.tr();
                      }
                      return null;
                    },
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  CustomTextField(
                    hintText: LocaleKeys.text.tr(),
                    controller: cubit.addVendorReviewDescription,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.dataMustBeEntered.tr();
                      }
                      return null;
                    },
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  CustomTextField(
                    hintText: LocaleKeys.address.tr(),
                    controller: cubit.addVendorReviewLocation,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.dataMustBeEntered.tr();
                      }
                      return null;
                    },
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  CustomTextField(
                    hintText: LocaleKeys.age.tr(),
                    controller: cubit.addVendorReviewAge,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.dataMustBeEntered.tr();
                      }
                      return null;
                    },
                  ),
                  const CustomSizedBox(
                    height: 14,
                  ),
                  CustomElevatedButton(
                    title: LocaleKeys.addReview.tr(),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        cubit.addVendorReview(
                          reviewVendorParameters: ReviewVendorParameters(
                            email: cubit.addVendorReviewEmail.text,
                            adress: cubit.addVendorReviewLocation.text,
                            age: cubit.addVendorReviewAge.text,
                            name: cubit.addVendorReviewName.text,
                            review: cubit.addVendorReviewDescription.text,
                            rating: cubit.addVendorReviewRate,
                          ),
                          id: widget.id,
                        );
                      }
                    },
                    buttonSize: Size(double.infinity, 40.h),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
