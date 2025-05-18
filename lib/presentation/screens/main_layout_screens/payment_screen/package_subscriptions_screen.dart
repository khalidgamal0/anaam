import 'dart:convert';
import 'dart:developer';

import 'package:an3am/core/cache_helper/cache_keys.dart';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/packages_model/packages_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_end_points.dart';
import '../../../../data/models/exchange_rate_model.dart';
import '../../../../domain/controllers/packages_cubit/packages_cubit.dart';
import '../../../widgets/payment_widgets/package_subscription_item.dart';
import '../../../widgets/shared_widget/custom_divider.dart';
import '../../../widgets/shared_widget/custom_elevated_button.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:an3am/core/app_router/screens_name.dart';

class PackageSubscriptionsScreen extends StatefulWidget {
  const PackageSubscriptionsScreen({super.key});

  @override
  State<PackageSubscriptionsScreen> createState() =>
      _PackageSubscriptionsScreenState();
}

class _PackageSubscriptionsScreenState
    extends State<PackageSubscriptionsScreen> with SingleTickerProviderStateMixin {
  int? currentIndex;
  var billingDetails = BillingDetails(
    CacheHelper.getData(key: CacheKeys.userName) ?? "Not Found",
    CacheHelper.getData(key: CacheKeys.userEmail) ?? "email@email.com",
    CacheHelper.getData(key: CacheKeys.phone) ?? "+97311111111",
    "st. 12 street",
    "sa",
    "saudi arabia",
    "saudi arabia",
    "52472",
  );

  late PaymentSdkConfigurationDetails configuration;

  void init() async {
    double amount = monthlyPackage?.price ?? 0.0;
    String packageCurrencyCode = await _fetchCurrencyCodeById(monthlyPackage?.packageCurrency ?? '1');

    if (packageCurrencyCode != 'SAR') {
      amount = await _convertToSAR(amount, packageCurrencyCode);
    }

    configuration = PaymentSdkConfigurationDetails(
      profileId: "104890",
      serverKey: "STJN6RNNDG-JHD2LZRKTJ-TBD9H6BZLR",
      clientKey: "CPKMVH-2BBD6H-DMB9RK-6TRB6K",
      cartId: "${monthlyPackage?.id}",
      cartDescription: "المستخدم برقم $userId اشترك في الباقة التي رقمها ${monthlyPackage?.id}",
      screentTitle: "الدفع بالبطاقة",
      merchantCountryCode: "SA",
      // transactionType: PaymentSdkTransactionType.SALE,
      currencyCode: "SAR",
      billingDetails: billingDetails,
      amount: amount,
      locale: PaymentSdkLocale.AR, //PaymentSdkLocale.AR or PaymentSdkLocale.DEFAULT
    );
    testPayCallTabs();
  }

  Future<double> _convertToSAR(double amount, String currencyCode) async {
    final url = '${EndPoints.baseUrl}${EndPoints.exchangeRate(base: currencyCode, target: 'SAR')}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final exchangeRateData = ExchangeRateModel.fromJson(json.decode(response.body));
      if (exchangeRateData.success) {
        return amount * exchangeRateData.rate;
      }
    }
    return amount;
  }

  Future<String> _fetchCurrencyCodeById(String currencyId) async {
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
        return 'SAR';
      }
    }
    for (var currency in currencies) {
      if (currency['id'].toString() == currencyId) {
        return currency['code'];
      }
    }
    return 'SAR';
  }

  void testPayCallTabs() {
    FlutterPaytabsBridge.startCardPayment(configuration, (event) {
      setState(() {
        if (event["status"] == "success") {
          // Handle transaction details here.

          var transactionDetails = event["data"];

          if (transactionDetails["isSuccess"]) {
            PackagesCubit.get(context).subscribeAPackage(
              tranRef: transactionDetails["transactionReference"],
              packageId: transactionDetails["cartID"],
            );
            // Fluttertoast.showToast(msg: transactionDetails["paymentResult"],backgroundColor: Colors.green,textColor: Colors.white,gravity: ToastGravity.SNACKBAR,);
            Fluttertoast.showToast(msg: "تمت عملية الشراء بنجاح",backgroundColor: Colors.green,textColor: Colors.white,gravity: ToastGravity.SNACKBAR,);
            // log(transactionDetails);
            log(jsonEncode(transactionDetails));
            Navigator.pushNamedAndRemoveUntil(
              context,
              ScreenName.mainLayoutScreen,
              (route) => false,
            );
          } else {
            Fluttertoast.showToast(msg: "فشل عملية الدفع",backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);
          }
        } else if (event["status"] == "error") {
         Fluttertoast.showToast(msg: event["status"],backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);

          // Handle error here.
        } else if (event["status"] == "event") {
          Fluttertoast.showToast(msg: event["status"],backgroundColor: Colors.red,textColor: Colors.white,gravity: ToastGravity.SNACKBAR);
          // Handle cancel events here.
        }
      });
    });
  }

  MonthlyPackage? monthlyPackage;

  bool isSubscribed = false;
  Map<String, dynamic>? accountDetails;

  Future<void> getAccount() async {
    try {
      final response = await http.get(
        Uri.parse('${EndPoints.baseUrl}${EndPoints.getaccount}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          final account = data["result"]["account"];
          setState(() {
            isSubscribed = DateTime.parse(account["subscription_end_date"]).isAfter(DateTime.now());
            accountDetails = account;
          });
        }
      }
    } catch (e) {
      // print("Error fetching account data: $e");
    }
  }

  late TabController _tabController;

  @override
  void initState() {
    getAccount();
    PackagesCubit.get(context).getAllPackages();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [];

    if (isSubscribed && accountDetails != null) {
      tabs.add(const Tab(text: 'اشتراكي الحالي'));
    }

    tabs.add(const Tab(text: 'الباقات المتاحة'));

    PackagesCubit cubit = PackagesCubit.get(context);
    final currentPackage = cubit.monthlyPackage?.firstWhere(
      (package) => package.id.toString() == accountDetails?["package_id"].toString(),
      orElse: () => MonthlyPackage(id: 0, title: "غير معروف", price: 0, duration: 0, packageCurrency: "SAR"),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("باقات الاشتراك"),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs, // استخدام القائمة الديناميكية
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // محتوى التبويب الأول (إذا كان موجودًا)
          if (isSubscribed && accountDetails != null)
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عرض الباقة المختارة
                  PackageSubscriptionItem(
                    isChecked: true, // لجعلها تبدو مختارة
                    onPressed: () {}, // لا يوجد فعل عند الضغط
                    monthlyPackage: currentPackage,
                    // MonthlyPackage(1, الباقة الشهرية, وصف الباقة, 15.0, 1, 10, 2023-11-06 16:21:17, 2025-02-11 17:05:23, 1)
                  ),
                  const SizedBox(height: 16),

                  // تفاصيل الاشتراك
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "تفاصيل الاشتراك",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow("العناصر المتبقية:", "${accountDetails!["remaining_items"]}"),
                          _buildDetailRow("تاريخ بدء الاشتراك:", accountDetails!["subscription_start_date"]),
                          _buildDetailRow("تاريخ انتهاء الاشتراك:", accountDetails!["subscription_end_date"]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // محتوى التبويب الثاني (الباقات المتاحة)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomDivider(
                hPadding: 16,
              ),
              const CustomSizedBox(
                height: 16,
              ),
              Expanded(
                child: BlocConsumer<PackagesCubit, PackagesState>(
                  listener: (context, state) {
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    PackagesCubit cubit = PackagesCubit.get(context);
                    return state is GetAllPackagesLoadingState
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 16.h),
                            itemBuilder: (_, index) {
                              return PackageSubscriptionItem(
                                isChecked: currentIndex == index,
                                onPressed: () {
                                  setState(() {
                                    currentIndex = index;
                                    monthlyPackage = cubit.monthlyPackage?[index];
                                  });
                                },
                                monthlyPackage: cubit.monthlyPackage?[index],
                              );
                            },
                            separatorBuilder: (_, index) {
                              return const CustomSizedBox(
                                height: 16,
                              );
                            },
                            itemCount: cubit.monthlyPackage?.length ?? 0,
                          );
                  },
                ),
              ),
              if (!isSubscribed) ...[
                CustomElevatedButton(
                  title: "اشتراك",
                  onPressed: () {
                    init();
                  },
                  buttonSize: const Size(
                    double.infinity,
                    48,
                  ),
                ).symmetricPadding(horizontal: 16),
              ],
              const CustomSizedBox(
                height: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لعرض تفاصيل الاشتراك
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}