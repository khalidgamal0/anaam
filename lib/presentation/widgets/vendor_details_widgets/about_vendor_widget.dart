import 'package:an3am/data/models/vendor_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme/app_colors.dart';
import '../../../translations/locale_keys.g.dart';
import '../shared_widget/custom_sized_box.dart';

class AboutVendorWidget extends StatelessWidget {
  final VendorProfileModel vendorProfileModel;

  const AboutVendorWidget({super.key, required this.vendorProfileModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.aboutMerchant.tr(),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
          ),
          const CustomSizedBox(height: 8),
          _buildLocationRow(context),
          const CustomSizedBox(height: 8),
          _buildLocationText(context),
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.location_pin,
          color: AppColors.blackColor,
          size: 18.sp,
        ),
        const CustomSizedBox(width: 8),
        Expanded(
          child: Text(
            vendorProfileModel.address ?? "",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontSize: 16.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.blackColor,
                  color: AppColors.blackColor,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationText(BuildContext context) {
    return Text(
      vendorProfileModel.location ?? "",
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: 16.sp,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}