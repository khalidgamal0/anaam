import 'package:an3am/core/app_theme/app_colors.dart';
import 'package:an3am/core/app_theme/custom_themes.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_check_box.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_outlined_button.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/data/models/exchange_rate_model.dart';
import 'package:an3am/core/network/api_end_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/models/packages_model/packages_model.dart';

class PackageSubscriptionItem extends StatefulWidget {
  final bool isChecked;
  final void Function()? onPressed;
  final MonthlyPackage? monthlyPackage;

  const PackageSubscriptionItem({
    super.key,
    required this.isChecked,
    this.onPressed,
    this.monthlyPackage,
  });

  @override
  _PackageSubscriptionItemState createState() => _PackageSubscriptionItemState();
}

class _PackageSubscriptionItemState extends State<PackageSubscriptionItem> {
  String userCurrencyName = 'ريال سعودي';
  double exchangeRate = 1.0;
  String _packageCurrencyCode = 'SAR';
  String _packageCurrencyName = 'ريال سعودي';

  @override
  void initState() {
    super.initState();
    _fetchUserCurrencyName();
    _fetchPackageCurrencyData();
    _fetchExchangeRate();
  }

  Future<void> _fetchUserCurrencyName() async {
    final String userCurrencyCode = CacheHelper.getData(key: CacheKeys.currency) ?? 'SAR';
    final cachedCurrencies = CacheHelper.getData(key: 'currencies');
    if (cachedCurrencies != null) {
      final List<dynamic> currencies = json.decode(cachedCurrencies as String);
      for (var currency in currencies) {
        if (currency['code'] == userCurrencyCode) {
          setState(() {
            userCurrencyName = currency['name'];
          });
          return;
        }
      }
    } else {
      final response = await http.get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
      if (response.statusCode == 200) {
        final List<dynamic> currencies = json.decode(response.body);
        for (var currency in currencies) {
          if (currency['code'] == userCurrencyCode) {
            setState(() {
              userCurrencyName = currency['name'];
            });
            break;
          }
        }
      }
    }
  }

  Future<void> _fetchPackageCurrencyData() async {
    final cachedCurrencies = CacheHelper.getData(key: 'currencies');
    List<dynamic> currencies;
    if (cachedCurrencies != null) {
      currencies = json.decode(cachedCurrencies as String);
    } else {
      final response = await http.get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
      if (response.statusCode == 200) {
        currencies = json.decode(response.body);
        CacheHelper.saveData(key: 'currencies', value: response.body);
      } else {
        currencies = [];
      }
    }
    final currencyId = widget.monthlyPackage?.packageCurrency ?? '1';
    for (var currency in currencies) {
      if (currency['id'].toString() == currencyId) {
        setState(() {
          _packageCurrencyCode = currency['code'];
          _packageCurrencyName = currency['name'];
        });
        break;
      }
    }
  }

  Future<void> _fetchExchangeRate() async {
    final String userCurrencyCode = CacheHelper.getData(key: CacheKeys.currency) ?? 'SAR';
    final cachedRates = CacheHelper.getData(key: 'exchange_rates');
    if (cachedRates != null) {
      final Map<String, dynamic> allExchangeRates = json.decode(cachedRates);
      if (allExchangeRates.containsKey(_packageCurrencyCode) &&
          allExchangeRates[_packageCurrencyCode].containsKey(userCurrencyCode)) {
        double rate = (allExchangeRates[_packageCurrencyCode][userCurrencyCode]).toDouble();
        setState(() {
          exchangeRate = rate;
        });
        return;
      }
    }
    final url = '${EndPoints.baseUrl}${EndPoints.exchangeRate(base: _packageCurrencyCode, target: userCurrencyCode)}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final exchangeRateData = ExchangeRateModel.fromJson(json.decode(response.body));
      if (exchangeRateData.success) {
        setState(() {
          exchangeRate = exchangeRateData.rate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagePrice = double.tryParse(widget.monthlyPackage?.price?.toString() ?? '0') ?? 0;
    final convertedPrice = packagePrice * exchangeRate;

    return CustomOutlinedButton(
      backgroundColor: widget.isChecked
          ? AppColors.orangeColor.withOpacity(0.20)
          : AppColors.whiteColor,
      onPressed: widget.onPressed,
      borderColor: widget.isChecked ? AppColors.orangeColor : AppColors.grey7DColor,
      foregroundColor: AppColors.orangeColor,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.monthlyPackage?.title ?? "",
                style: CustomThemes.darkGreyColorTextTheme(context)
                    .copyWith(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
              CustomCheckBox(isChecked: widget.isChecked),
            ],
          ),
          const CustomSizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "السعر: ${convertedPrice.toStringAsFixed(2)} $userCurrencyName",
                style: CustomThemes.primaryColorTextTheme(context).copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.orangeColor,
                    ),
              ),
            ],
          ),
          const CustomSizedBox(
            height: 12,
          ),
          Text(
            "${widget.monthlyPackage?.description}",
            style: CustomThemes.grey7DColorTextTheme(context)
                .copyWith(fontSize: 16.sp, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
