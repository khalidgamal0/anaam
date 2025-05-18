import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_elevated_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_theme/app_colors.dart';
import '../../../translations/locale_keys.g.dart';

class ContactContainerWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String price;
  final String rate;
  final String phone; // Add phone parameter
  final String message; // Add message parameter

  const ContactContainerWidget({
    super.key,
    this.onPressed,
    required this.price,
    required this.rate,
    required this.phone, // Initialize phone
    required this.message, // Initialize message    
    });

  // Function to launch WhatsApp
  void launchWhatsApp({required String phone, required String message}) async {
    String url = "https://wa.me/$phone?text=${Uri.encodeFull(message)}";
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$price ${LocaleKeys.sar.tr()}",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 24.sp,
                    color: AppColors.blackColor,
                  ),
            ),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.orangeColor,
                  size: 18.r,
                ),
                Text(
                  rate,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.blackColor,
                      ),
                ),
              ],
            ),
          ],
        ),
        CustomElevatedButton(
          title: "${LocaleKeys.contact.tr()} $phone", // Ensure phone number is displayed
          buttonSize: Size(212.w, 48.h),
          radius: 6,
          onPressed: () {
            // Launch WhatsApp when the button is pressed
            launchWhatsApp(phone:  phone, message: message);
          },
        )
      ],
    ).symmetricPadding(horizontal: 16);
  }
}
