import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_router/screens_name.dart';
import '../../../core/assets_path/svg_path.dart';
import '../../../core/constants/constants.dart';
import '../../../translations/locale_keys.g.dart';
import 'account_seetings_item_widget.dart';
import '../../../core/network/api_end_points.dart';

class AccountSettingsComponent extends StatefulWidget {
  const AccountSettingsComponent({
    super.key,
  });

  @override
  _AccountSettingsComponentState createState() => _AccountSettingsComponentState();
}

class _AccountSettingsComponentState extends State<AccountSettingsComponent> {
  List<DropdownMenuItem<String>> _currencyItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  void _fetchCurrencies() async {
    final response = await http.get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
    if (response.statusCode == 200) {
      final List<dynamic> currencies = json.decode(response.body);
      setState(() {
        _currencyItems = currencies.map((currency) {
          return DropdownMenuItem<String>(
            value: currency['code'],
            child: Text('${currency['name']} (${currency['symbol']})'),
          );
        }).toList();
      });
    }
  }

  void changeCurrency(String? currencyCode) {
    if (currencyCode != null) {
      CacheHelper.saveData(key: CacheKeys.currency, value: currencyCode);
      Phoenix.rebirth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          Text(
            LocaleKeys.accountSettings.tr(),
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontSize: 20.sp, height: 1),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'اختر العملة',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 16.sp),
            ),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              value: CacheHelper.getData(key: CacheKeys.currency) ?? 'SAR',
              onChanged: changeCurrency,
              items: _currencyItems,
              isExpanded: true,
              underline: SizedBox(),
            ),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.followingScreen);
            },
            iconPath: SvgPath.followersList,
            title: LocaleKeys.followingList.tr(),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.followersScreen);
            },
            iconPath: SvgPath.followersList,
            title: LocaleKeys.followersList.tr(),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.productControlScreen);
            },
            iconPath: SvgPath.controllSetting,
            // title: LocaleKeys.controlPanel.tr(),
            title: 'المنتجات',
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.addVetScreen);
            },
            iconPath: SvgPath.controllSetting,
            title: 'إضافة بيطرة',
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.addStoreScreen);
            },
            iconPath: SvgPath.controllSetting,
            title: 'إضافة نقل مواشي',
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.addLaborerScreen);
            },
            iconPath: SvgPath.controllSetting,
            title: 'إضافة يد عاملة',
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.packageSubscriptionsScreen);
            },
            iconPath: SvgPath.choices,
            title: LocaleKeys.subscriptions.tr(),
          ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              Navigator.pushNamed(context, ScreenName.notificationsScreen);
            },
            iconPath: SvgPath.notification,
            title: LocaleKeys.notifications.tr(),
          ),
        AccountSettingItemWidget(
          onPressed: () {
            Navigator.pushNamed(context, ScreenName.privacyPolicyScreen);
          },
          iconPath: SvgPath.help,
          title: LocaleKeys.privacyPolicy.tr(),
        ),
        AccountSettingItemWidget( // New Item for About Us
          onPressed: () {
            Navigator.pushNamed(context, ScreenName.aboutUsScreen);
          },
          iconPath: SvgPath.infoCircle, // Assuming you have an icon for about us, or use a generic one
          title: LocaleKeys.about_us.tr(),
        ),
        if (CacheHelper.getData(key: CacheKeys.token) != null)
          AccountSettingItemWidget(
            onPressed: () {
              showProgressIndicator(context);
              Timer(
                const Duration(seconds: 1),
                () async {
                  await CacheHelper.clearAllData().then(
                    (value) {
                      Phoenix.rebirth(context);
                      Navigator.pushNamedAndRemoveUntil(
                          context, ScreenName.splashScreen, (route) => false);
                    },
                  );
                },
              );
            },
            iconPath: SvgPath.logout,
            isBordered: false,
            title: LocaleKeys.logout.tr(),
          ),
      ],
    ).onlyDirectionalPadding(start: 29, end: 27);
  }
}
