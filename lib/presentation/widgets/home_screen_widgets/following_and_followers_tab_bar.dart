import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_theme/app_colors.dart';
import '../../../core/app_theme/custom_themes.dart';
import '../../../core/cache_helper/cache_keys.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';

class FollowingAndFollowersTabBar extends StatelessWidget {
  final TabController tabController;
  final void Function(int)? onTap;
  const FollowingAndFollowersTabBar({
    super.key,
    required this.tabController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: EdgeInsets.symmetric(horizontal: 11.w),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelStyle: CustomThemes.greyD9ColorTextTheme(context).copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: CustomThemes.greyD9ColorTextTheme(context).copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      onTap: onTap,
      labelColor: AppColors.greyColor22,
      unselectedLabelColor: AppColors.greyColor22,
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 3.w)),
      tabs: [
        // if(CacheHelper.getData(key: CacheKeys.userType)==UserTypeEnum.user.name)
        Tab(
          text: LocaleKeys.productList.tr(),
        ),
        if (CacheHelper.getData(key: CacheKeys.userType) != null) 
          Tab(
            text: LocaleKeys.followingList.tr(),
          ),
      ],
      controller: tabController,
    ).symmetricPadding(horizontal: 16);
  }
}
