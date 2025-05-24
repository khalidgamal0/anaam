import 'package:an3am/core/app_theme/app_colors.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/cache_helper/cache_keys.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';
import '../../../core/network/api_end_points.dart';
import '../../../data/models/products_model/product_model.dart';
import '../../../data/models/exchange_rate_model.dart';
import 'product_image_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductItemComponent extends StatefulWidget {
  final bool isFavorite;
  final void Function()? onPressed;
  final ProductDataModel productDataModel;

  const ProductItemComponent({
    super.key,
    required this.isFavorite,
    this.onPressed,
    required this.productDataModel,
  });

  @override
  State<ProductItemComponent> createState() => _ProductItemComponentState();
}

class _ProductItemComponentState extends State<ProductItemComponent> {
  String productCurrencyName = 'ريال سعودي';
  String clientCurrencyName = 'ريال سعودي';
  String productCurrencyCode = 'SAR';
  String clientCurrencyCode = CacheHelper.getData(key: CacheKeys.currency) ?? 'SAR'; // # String userCurrency = CacheHelper.getData(key: 'currency') as String? ?? 'SAR';
  double exchangeRate = 1;

  // New helper function to map price type to Arabic text
  String mapPriceType(String? type) {
    final pt = type?.toLowerCase();
    if (pt == 'fixed') return 'ثابت';
    if (pt == 'limit') return 'حد';
    if (pt == 'sum') return 'سوم';
    if (pt == 'no_price') return 'بدون سعر';
    return 'بدون سعر';
  }

  // New helper to build flag widget from cached countries using countryId:
  Widget? _buildFlag() {
    final cached = CacheHelper.getData(key: 'all_countries');
    if (cached != null) {
      final Map<String, dynamic> data = json.decode(cached);
      if (data['result'] != null) {
        List<dynamic> countries = data['result'];
        final country = countries.firstWhere((e) => e['id'] == widget.productDataModel.countryId, orElse: () => null);
        if (country != null && country['CodeName'] != null) {
          return SvgPicture.network(
            "https://ban3am.com/flags/${country['CodeName']}.svg",
            width: 30.w,
            height: 30.h,
          );
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  void _fetchCurrencies() async {
    // Use cached currencies if available
    final cachedCurrencies = CacheHelper.getData(key: 'currencies');
    List<dynamic> currencies;
    if (cachedCurrencies != null) {
      currencies = json.decode(cachedCurrencies as String);
    } else {
      final response = await http.get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
      if (response.statusCode == 200) {
        currencies = json.decode(response.body);
        // Optionally cache the response
        CacheHelper.saveData(key: 'currencies', value: response.body);
      } else {
        return;
      }
    }

    int productCurrencyId = int.tryParse(widget.productDataModel.productCurrency ?? '1') ?? 1;
    for (var currency in currencies) {
      if (currency['id'] == productCurrencyId) {
        if (!mounted) return;
        setState(() {
          productCurrencyName = currency['name'];
          productCurrencyCode = currency['code'];
        });
        break;
      }
    }

    String? clientCurrencyId = CacheHelper.getData(key: CacheKeys.currency) ?? 'SAR';
    if (clientCurrencyId != null) {
      for (var currency in currencies) {
        if (currency['code'] == clientCurrencyId) {
          if (!mounted) return;
          setState(() {
            clientCurrencyName = currency['name'];
            clientCurrencyCode = currency['code'];
          });
          break;
        }
      }
    }

    _fetchExchangeRate();
  }

  void _fetchExchangeRate() async {
    if (productCurrencyCode != clientCurrencyCode) {
      final url = '${EndPoints.baseUrl}${EndPoints.exchangeRate(base: productCurrencyCode, target: clientCurrencyCode)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final exchangeRateData = ExchangeRateModel.fromJson(json.decode(response.body));
        if (exchangeRateData.success) {
          if (!mounted) return;
          setState(() {
            exchangeRate = exchangeRateData.rate;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double productPrice = double.tryParse(widget.productDataModel.salePrice?.toString() ?? '0') ?? 0;
    double convertedPrice = productPrice * exchangeRate;
    // Conditionally set the price type text with parentheses if available.
    final String priceTypeDisplay = (widget.productDataModel.priceType != null &&
         widget.productDataModel.priceType!.trim().isNotEmpty)
         ? " (${mapPriceType(widget.productDataModel.priceType)})" : "";

    return InkWell(
      onTap: widget.onPressed,
      splashColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemImageWidget(
            isFavorite: widget.isFavorite,
            productDataModel: widget.productDataModel,
          ),
          const CustomSizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.productDataModel.name ?? "",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.productDataModel.rate.toString(),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  Icon(
                    Icons.star,
                    color: AppColors.orangeColor,
                    size: 30.r,
                  ),
                  // Insert flag before rating:
                  if (_buildFlag() != null) ...[
                    _buildFlag()!,
                    SizedBox(width: 5.w),
                  ],
                ],
              ),
            ],
          ),
          const CustomSizedBox(height: 4),
          Text(
            widget.productDataModel.description ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontSize: 16.sp,
            ),
          ),
          const CustomSizedBox(height: 4),
          Text(
            "$convertedPrice $clientCurrencyName$priceTypeDisplay",
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
