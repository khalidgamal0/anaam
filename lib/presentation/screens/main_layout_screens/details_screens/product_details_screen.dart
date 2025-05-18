import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/products_model/product_model.dart';
import 'package:an3am/presentation/widgets/bottom_sheets_widgets/add_review_bottom_sheet.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_divider.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:an3am/data/models/exchange_rate_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/app_theme/app_colors.dart';
import '../../../../core/app_theme/custom_themes.dart';
import '../../../../core/assets_path/images_path.dart';
import '../../../widgets/product_details_widgets/product_details_images_widget.dart';
import '../../../widgets/shared_widget/title_and_body_text_widget.dart';
import '../../../widgets/vendor_details_widgets/rating_component_builder.dart';
import '../../../../core/cache_helper/cache_keys.dart';
import '../../../../core/cache_helper/shared_pref_methods.dart';
import '../../../../core/network/api_end_points.dart';
import '../google_maps_screens/open_current_loctaion_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../../domain/controllers/services_cubit/services_state.dart';
import '../../../../domain/controllers/profile_cubit/profile_cubit.dart';
import 'package:an3am/core/app_router/screens_name.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductDataModel productDataModel;

  const ProductDetailsScreen({super.key, required this.productDataModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String currencyName = 'ريال سعودي';
  String cachedCurrencyName = 'ريال سعودي';
  double exchangeRate = 1;
  String productCurrencyCode = 'SAR';

  List<dynamic> tagsJson = [];
  List<String> arabicTags = [];
  String tagsText = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrencyName();
    _fetchCachedCurrencyName();
    _parseTags(); // Parse tags when the state is initialized
  }

  void _fetchCurrencyName() async {
    int currencyId =
        int.tryParse(widget.productDataModel.productCurrency ?? '1') ?? 1;
    final response =
        await http.get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
    if (response.statusCode == 200) {
      final List<dynamic> currencies = json.decode(response.body);
      for (var currency in currencies) {
        if (currency['id'] == currencyId) {
          setState(() {
            currencyName = currency['name'];
            productCurrencyCode = currency['code'];
          });
          _fetchExchangeRate();
          break;
        }
      }
    }
  }

  void _fetchCachedCurrencyName() async {
    String? cachedCurrencyCode = CacheHelper.getData(key: CacheKeys.currency);
    if (cachedCurrencyCode != null) {
      final response = await http
          .get(Uri.parse('${EndPoints.baseUrl}${EndPoints.currency}'));
      if (response.statusCode == 200) {
        final List<dynamic> currencies = json.decode(response.body);
        for (var currency in currencies) {
          if (currency['code'] == cachedCurrencyCode) {
            setState(() {
              cachedCurrencyName = currency['name'];
            });
            break;
          }
        }
      }
    }
  }

  void _fetchExchangeRate() async {
    String? cachedCurrencyCode = CacheHelper.getData(key: CacheKeys.currency);
    if (cachedCurrencyCode != null) {
      final url =
          '${EndPoints.baseUrl}${EndPoints.exchangeRate(base: productCurrencyCode, target: cachedCurrencyCode)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final exchangeRateData =
            ExchangeRateModel.fromJson(json.decode(response.body));
        if (exchangeRateData.success) {
          setState(() {
            exchangeRate = exchangeRateData.rate;
          });
        }
      }
    }
  }

  void _launchWhatsApp() async {
    // Use the new product phone fields instead of uploadedBy
    final phone = widget.productDataModel.phoneNumber ?? '';
    final phoneCode = widget.productDataModel.phoneCode ?? '';
    final formattedPhone = phoneCode + phone;
    final productName = widget.productDataModel.name ?? 'اسم المنتج';
    final productPrice = widget.productDataModel.salePrice?.toString() ?? '0';
    final productLink =
        '${EndPoints.siteUrl}products/${widget.productDataModel.id}';
    final userName = CacheHelper.getData(key: CacheKeys.userName) ?? 'عميل';
    final message =
        "مرحبًا، أنا $userName.\n\nأنا مهتم بمنتجك: $productName.\nالسعر: $productPrice $currencyName.\nرقم الجوال: $phoneCode$phone\nرابط المنتج: $productLink.\n\nشكرًا.";
    if (phone.isNotEmpty && phoneCode.isNotEmpty && formattedPhone.isNotEmpty) {
      final url =
          "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _parseTags() {
    try {
      tagsJson = jsonDecode(widget.productDataModel.tags ?? '[]');
      arabicTags =
          tagsJson.map((tag) => tag['name']['ar']?.toString() ?? '').toList();
      tagsText = arabicTags.join(', ');
    } catch (e) {
      debugPrint('Error parsing tags: $e');
      tagsText = 'لا توجد علامات'; // Fallback text if parsing fails
    }
  }

  // Add helper method to map price type
  String mapPriceType(String? type) {
    final pt = type?.toLowerCase();
    if (pt == 'fixed') return 'ثابت';
    if (pt == 'limit') return 'حد';
    if (pt == 'sum') return 'سوم';
    if (pt == 'no_price') return 'بدون سعر';
    return 'بدون سعر';
  }

  // New helper to build flag widget using product's country_id:
  Widget? _buildFlag() {
    final cached = CacheHelper.getData(key: 'all_countries');
    print('all_countries');
    print(cached);
    print('all_countries');
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
  Widget build(BuildContext context) {
    // Conditionally add parentheses only if price_type exists.
    final String priceTypeDisplay = (widget.productDataModel.priceType != null &&
         widget.productDataModel.priceType!.trim().isNotEmpty)
         ? " (${mapPriceType(widget.productDataModel.priceType)})" : "";
  
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              children: [
                ProductDetailsImagesWidget(
                  imagesList: widget.productDataModel.images!,
                  id: widget.productDataModel.id,
                ),
                const CustomSizedBox(
                  height: 15,
                ),
                // ...existing code...

                // SizedBox(height: 10.h),
                Text(
                  widget.productDataModel.name ?? 'Product Name!',
                  style: TextStyle(
                    fontSize: 30.sp, // Updated font size to match 3rem
                    color: Color(0xFF12263A), // Updated color to match #12263a
                    fontWeight:
                        FontWeight.w700, // Updated font weight to match 700
                    textBaseline: TextBaseline
                        .alphabetic, // Ensure text is aligned properly
                  ),
                ).symmetricPadding(horizontal: 16),
                // SizedBox(height: 5.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ProfileCubit.get(context)
                            .showVendorProfile(
                                id: widget.productDataModel.uploadedBy!.id!)
                            .then((value) {
                          Navigator.pushNamed(
                            context,
                            ScreenName.vendorDetailsScreen,
                            arguments:
                                ProfileCubit.get(context).vendorProfileModel,
                          );
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF25559D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.productDataModel.uploadedBy!.name ??
                              'Vendor Name!',
                          style: TextStyle(
                            fontSize: 18.sp, // 0.9rem equivalent
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing:
                                1.5, // Simulate text-transform: uppercase
                          ),
                        ),
                      ).symmetricPadding(horizontal: 16),
                    ),
                    // Insert flag image right after vendor info:
                    if (_buildFlag() != null) ...[
                      _buildFlag()!,
                      SizedBox(width: 4.w),
                    ],
                    if (CacheHelper.getData(key: CacheKeys.token) != null)
                      BlocBuilder<ServicesCubit, ServicesState>(
                        builder: (context, state) {
                          var cubit = ServicesCubit.get(context);
                          bool isFollowing = cubit.followedVendors[widget
                                  .productDataModel.uploadedBy!.id!
                                  .toString()] ??
                              false;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              Color defaultColor =
                                  Color.fromARGB(255, 13, 110, 253);
                              Color hoverColor =
                                  Color.fromARGB(255, 10, 88, 202);
                              bool isHovered = false;

                              return MouseRegion(
                                onEnter: (_) =>
                                    setState(() => isHovered = true),
                                onExit: (_) =>
                                    setState(() => isHovered = false),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isFollowing) {
                                      cubit.followVendor(
                                          vendorId: widget.productDataModel
                                              .uploadedBy!.id!);
                                    } else {
                                      cubit.unfollowVendor(
                                          vendorId: widget.productDataModel
                                              .uploadedBy!.id!);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color:
                                          isHovered ? hoverColor : defaultColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        isFollowing ? '-' : '+',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 30.sp,
                    ),
                    Text(
                      '(${widget.productDataModel.rate?.toString() ?? '0'})',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  // 'السعر: ${widget.productDataModel.salePrice?.toString() ?? '0'} ريال سعودي',
                  'السعر: ${widget.productDataModel.salePrice ?? '0'} $currencyName$priceTypeDisplay',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ).symmetricPadding(horizontal: 16),
                if (cachedCurrencyName.isNotEmpty &&
                    cachedCurrencyName != currencyName)
                  Text(
                    'السعر بعملة العميل: ${(double.tryParse(widget.productDataModel.salePrice?.toString() ?? '0') ?? 0) * exchangeRate} $cachedCurrencyName',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ).symmetricPadding(horizontal: 16),

                const CustomDivider(hPadding: 28),
                const CustomSizedBox(
                  height: 24,
                ),
                TileAndBodyTextWidget(
                  titleText: LocaleKeys.productDescription.tr(),
                  bodyText: widget.productDataModel.description ?? "",
                  titleFontSize: 20,
                  horizontalPadding: 16,
                  bodyFontSize: 16,
                  bodyMaxLines: 10,
                  titleMaxLines: 5,
                  spaceBetweenTitleAndBody: 8,
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 28),
                const CustomSizedBox(
                  height: 19,
                ),
                TileAndBodyTextWidget(
                  titleText: LocaleKeys.advantages.tr(),
                  bodyText: widget.productDataModel.advantages ?? "",
                  titleFontSize: 20,
                  bodyFontSize: 16,
                  horizontalPadding: 16,
                  bodyMaxLines: 5,
                  spaceBetweenTitleAndBody: 3,
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 28),
                const CustomSizedBox(
                  height: 19,
                ),
                TileAndBodyTextWidget(
                  titleText: LocaleKeys.disadvantages.tr(),
                  bodyText: widget.productDataModel.defects ?? "",
                  titleFontSize: 20,
                  bodyFontSize: 16,
                  horizontalPadding: 16,
                  bodyMaxLines: 5,
                  spaceBetweenTitleAndBody: 3,
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 28),
                TileAndBodyTextWidget(
                  titleText: 'العلامات',
                  bodyText: tagsText,
                  titleFontSize: 20,
                  bodyFontSize: 16,
                  horizontalPadding: 16,
                  bodyMaxLines: 5,
                  spaceBetweenTitleAndBody: 3,
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 28),
                const CustomSizedBox(
                  height: 19,
                ),
                RatingComponentBuilder(
                  componentTitle: LocaleKeys.customerReviews.tr(),
                  buttonTitle: LocaleKeys.addReview.tr(),
                  onAddPressed: () {
                    if (CacheHelper.getData(key: CacheKeys.token) != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => AddProductReviewBottomSheet(
                            id: widget.productDataModel.id.toString()),
                      );
                    }
                  },
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 16),
                const CustomSizedBox(
                  height: 19,
                ),
                Text(
                  LocaleKeys.attachedLinks.tr(),
                  style: CustomThemes.darkGreyColorTextTheme(context).copyWith(
                    fontSize: 20.sp,
                    height: 1,
                    fontWeight: FontWeight.w400,
                  ),
                ).symmetricPadding(horizontal: 16),
                const CustomSizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () async {
                    final url = widget.productDataModel.youtubeLink ?? "";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    widget.productDataModel.youtubeLink ?? "",
                    style: CustomThemes.primaryColorTextTheme(context).copyWith(
                      fontSize: 16.sp,
                      height: 1,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ).symmetricPadding(horizontal: 16),
                ),
                const CustomSizedBox(
                  height: 19,
                ),
                const CustomDivider(hPadding: 16),
                const CustomSizedBox(
                  height: 19,
                ),
                Text(
                  LocaleKeys.locationOnMap.tr(),
                  style: CustomThemes.darkGreyColorTextTheme(context).copyWith(
                    fontSize: 20.sp,
                    height: 1,
                    fontWeight: FontWeight.w400,
                  ),
                ).symmetricPadding(horizontal: 16),
                const CustomSizedBox(
                  height: 22,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LocationOnMapScreen(
                                  initialLocation: LatLng(
                                      double.parse(widget
                                          .productDataModel.coordinates!
                                          .split(",")
                                          .first),
                                      double.parse(
                                        widget.productDataModel.coordinates!
                                            .split(",")
                                            .last
                                            .trim(),
                                      )),
                                )));
                  },
                  child: SizedBox(
                    height: 193.h,
                    width: double.infinity,
                    child: Image.asset(
                      ImagesPath.mapImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ).symmetricPadding(horizontal: 16),
                const CustomDivider(hPadding: 28),
                const CustomSizedBox(
                  height: 19,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton:
          (widget.productDataModel.phoneNumber?.isNotEmpty == true &&
           widget.productDataModel.phoneCode?.isNotEmpty == true)
              ? FloatingActionButton(
                  onPressed: _launchWhatsApp,
                  backgroundColor: Colors.green,
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 28.sp,
                    color: Colors.white,
                  ),
                )
              : null,
    );
  }
}
