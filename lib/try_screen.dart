import 'package:an3am/core/assets_path/svg_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TryScreen extends StatefulWidget {
  const TryScreen({super.key});

  @override
  State<TryScreen> createState() => _TryScreenState();
}

List<String> items = [
  "dummy1",
  "dummy2",
  "dummy3",
  "dummy4",
  "dummy5",
];
String? stateOrRegionValue;
String? cityValue;
String? mainCategoryValue;
String? subcategoryValue;

class _TryScreenState extends State<TryScreen> {
  List<String> items = [
    "dummy1",
    "dummy2",
    "dummy3",
    "dummy4",
    "dummy5",
  ];
  String? value;

  bool isLoggedIn = false;
  Map userData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Login functionality removed"),
      ),
    );
  }
}

class PaymentPayTaps {
  var billingDetails = BillingDetails(
    "John Smith",
    "email@domain.com",
    "+97311111111",
    "st. 12",
    "eg",
    "dubai",
    "dubai",
    "12345",
  );
  var shippingDetails = ShippingDetails(
    "John Smith",
    "email@domain.com",
    "+97311111111",
    "st. 12",
    "eg",
    "dubai",
    "dubai",
    "12345",
  );
  late PaymentSdkConfigurationDetails configuration;

  void init() {
    configuration = PaymentSdkConfigurationDetails(
      profileId: "108520",
      serverKey: "S6JN6RNND9-JHR69NT2MJ-6R26LT6B69",
      clientKey: "CBKMVH-2BDG6H-RGPQ7M-6KKVKT",
      cartId: "19",
      cartDescription: "cart desc",
      merchantName: "merchant name",
      screentTitle: "Pay with Card",
      merchantCountryCode: "EG",
      currencyCode: "EGP",
      billingDetails: billingDetails,
      amount: 10.0,
      shippingDetails: shippingDetails,
      locale:
          PaymentSdkLocale.AR, //PaymentSdkLocale.AR or PaymentSdkLocale.DEFAULT
    );
  }

  void testPayCallTabs() {
    FlutterPaytabsBridge.startCardPayment(configuration, (event) {
      // setState(() {
      //   if (event["status"] == "success") {
      //     // Handle transaction details here.
      //     var transactionDetails = event["data"];
      //     print(transactionDetails);
      //
      //     if (transactionDetails["isSuccess"]) {
      //       print("successful transaction");
      //     } else {
      //       print("failed transaction");
      //     }
      //   } else if (event["status"] == "error") {
      //     // Handle error here.
      //   } else if (event["status"] == "event") {
      //     // Handle cancel events here.
      //   }
      // });
    });
  }
}

class OrderProgressScreen extends StatefulWidget {
  const OrderProgressScreen({super.key});

  @override
  State<OrderProgressScreen> createState() => _OrderProgressScreenState();
}

class _OrderProgressScreenState extends State<OrderProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Track your order",
          style: TextStyle(
            color: const Color(0xff676767),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(

              child: Stepper(
                type: StepperType.horizontal,
                steps: [
                  Step(title: const SizedBox.shrink(), content: SvgPicture.asset(SvgPath.accepted,),),
                  Step(title: const SizedBox.shrink(), content: SvgPicture.asset(SvgPath.accepted,),),
                  Step(title: const SizedBox.shrink(), content: SvgPicture.asset(SvgPath.accepted,),),
                  Step(title: const SizedBox.shrink(), content: SvgPicture.asset(SvgPath.accepted,),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
