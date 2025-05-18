import 'package:an3am/data/models/multi_lang_models/product_multi_lang_model.dart';
import 'package:an3am/core/assets_path/images_path.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:an3am/domain/controllers/products_cubit/products_cubit.dart';
import 'package:an3am/presentation/widgets/shared_widget/tags_input_field.dart';
import 'dart:convert'; // added import for json
import 'package:an3am/core/cache_helper/shared_pref_methods.dart'; // added import for CacheHelper

import '../../../../core/app_theme/app_colors.dart';
import '../../../../try_screen.dart';
import '../../../widgets/auth_widgets/custom_drop_down_button.dart';
import '../../../widgets/auth_widgets/custom_text_field.dart';
import '../../../widgets/shared_widget/custom_divider.dart';
import '../../../widgets/shared_widget/custom_elevated_button.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';

class EditProductScreen extends StatefulWidget {
  final ProductMultiLangModel
      productMultiLangModel; // استقبال النموذج عند التعديل

  const EditProductScreen({Key? key, required this.productMultiLangModel})
      : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final ProductsCubit cubit;

  @override
  void initState() {
    super.initState();
    print("DEBUG: EditProductScreen initState called");
    cubit = ProductsCubit.get(context);
    // تعيين التاجات من النموذج عند التعديل
    if (widget.productMultiLangModel.tags != null &&
        widget.productMultiLangModel.tags!.isNotEmpty) {
      cubit.tags.text = widget.productMultiLangModel.tags!.join(', ');
    } else {
      cubit.tags.clear();
    }
    // تعيين قيمة coordinates من النموذج إذا كانت موجودة
    if (widget.productMultiLangModel.coordinates != null &&
        widget.productMultiLangModel.coordinates!.isNotEmpty) {
      cubit.mapCoordinates = widget.productMultiLangModel.coordinates;
    } else {
      // إذا كانت القيمة فارغة، يمكنك إما تعيين قيمة افتراضية
      // أو عرض رسالة تنبيه للمستخدم لتحديد الموقع.
      print("Coordinates missing. Please select a location.");
    }
    // NEW: Populate missing fields converting values to String
    cubit.productCurrency.text = widget.productMultiLangModel.productCurrency?.toString() ?? "";
    cubit.priceType.text = widget.productMultiLangModel.priceType?.toString() ?? "";
    cubit.countryId.text = widget.productMultiLangModel.countryId?.toString() ?? "";
    cubit.phoneNumber.text = widget.productMultiLangModel.phoneNumber?.toString() ?? "";
    cubit.phoneCode.text = widget.productMultiLangModel.phoneCode?.toString() ?? "";
     print("Yousef");
    // DEBUG: Print assigned values
    Future.delayed(Duration.zero, () {
      print("DEBUG: ProductCurrency = ${cubit.productCurrency.text}");
      print("DEBUG: PriceType = ${cubit.priceType.text}");
      print("DEBUG: CountryId = ${cubit.countryId.text}");
      print("DEBUG: PhoneNumber = ${cubit.phoneNumber.text}");
      print("DEBUG: PhoneCode = ${cubit.phoneCode.text}");
    });
  }

  @override
  void dispose() {
    ProductsCubit.get(context).resetCategorySelection(); // Clear category selections
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: EditProductScreen build called");
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 20.h),
          children: [
            Text(
              LocaleKeys.editProduct.tr(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontSize: 20.sp),
            ),
            const CustomSizedBox(
              height: 10,
            ),
            const CustomDivider(),
            const CustomSizedBox(
              height: 10,
            ),
            Text(
              "عرض 001",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontSize: 16.sp),
            ),
            const CustomSizedBox(
              height: 17,
            ),
            CustomDropDownButton(
              height: 45,
              onChanged: (value) {},
              hint: LocaleKeys.mainClassification.tr(),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontSize: 14.sp)),
                      ))
                  .toList(),
              value: mainCategoryValue,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomDropDownButton(
              height: 45,
              onChanged: (value) {},
              hint: LocaleKeys.subCategory.tr(),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              value: subcategoryValue,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              hintText: LocaleKeys.displayName.tr(),
              height: 45,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              hintText: LocaleKeys.price.tr(),
              height: 45,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            // Updated currency dropdown: show actual value if available
            CustomDropDownButton<String>(
              height: 45,
              onChanged: (value) {
                setState(() {
                  cubit.productCurrency.text = value!;
                });
              },
              hint: LocaleKeys.productCurrency.tr(),
              items: [
                DropdownMenuItem(value: '1', child: Text('ريال سعودي (ر.س)')),
                DropdownMenuItem(value: '2', child: Text('درهم إماراتي (د.إ)')),
                DropdownMenuItem(value: '3', child: Text('دينار كويتي (د.ك)')),
                DropdownMenuItem(value: '4', child: Text('ريال قطري (ر.ق)')),
                DropdownMenuItem(value: '5', child: Text('ريال عماني (ر.ع)')),
                DropdownMenuItem(value: '6', child: Text('دينار بحريني (د.ب)')),
              ],
              value: cubit.productCurrency.text.isNotEmpty
                  ? cubit.productCurrency.text
                  : null,
            ),
            const CustomSizedBox(height: 11),
            // Updated price type dropdown: display saved value if any
            CustomDropDownButton<String>(
              height: 45,
              onChanged: (value) {
                setState(() {
                  cubit.priceType.text = value!;
                });
              },
              hint: "نوع السعر",
              items: [
                DropdownMenuItem(value: "fixed", child: Text("ثابت")),
                DropdownMenuItem(value: "limit", child: Text("حد")),
                DropdownMenuItem(value: "sum", child: Text("سوم")),
                DropdownMenuItem(value: "no_price", child: Text("بدون سعر")),
              ],
              value: cubit.priceType.text.isNotEmpty
                  ? cubit.priceType.text
                  : null,
            ),
            const CustomSizedBox(height: 11),
            // Add country and phone code selection similar to the add product screen:
            FutureBuilder<List<dynamic>>(
              future: () async {
                final raw = CacheHelper.getData(key: 'all_countries');
                if (raw != null) {
                  final data = json.decode(raw);
                  return data['result'] as List<dynamic>;
                }
                return [];
              }(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final countries = snapshot.data!;
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: "بلد المنتج",
                      ),
                      value: cubit.countryId.text.isNotEmpty ? cubit.countryId.text : null,
                      items: countries.map<DropdownMenuItem<String>>((country) {
                        return DropdownMenuItem<String>(
                          value: country['id'].toString(),
                          child: Text("${country['name']}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cubit.countryId.text = value ?? "";
                          final selected = countries.firstWhere(
                            (country) => country['id'].toString() == value,
                            orElse: () => countries.first,
                          );
                          cubit.phoneCode.text = selected['code'] ?? "";
                        });
                      },
                    ),
                    const CustomSizedBox(height: 11),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: "رمز الهاتف",
                      ),
                      value: cubit.phoneCode.text.isNotEmpty ? cubit.phoneCode.text : null,
                      items: countries.map<DropdownMenuItem<String>>((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Text("${country['name']} (${country['code']})"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cubit.phoneCode.text = value ?? "";
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            const CustomSizedBox(height: 11),
            CustomTextField(
              hintText: LocaleKeys.countryId.tr(),
              controller: cubit.countryId,
              height: 45,
            ),
            const CustomSizedBox(height: 11),
            CustomTextField(
              hintText: LocaleKeys.phoneNumber.tr(),
              controller: cubit.phoneNumber,
              height: 45,
            ),
            const CustomSizedBox(height: 11),
            CustomTextField(
              hintText: LocaleKeys.phoneCode.tr(),
              controller: cubit.phoneCode,
              height: 45,
            ),
            const CustomSizedBox(height: 11),
            CustomTextField(
              hintText: LocaleKeys.description.tr(),
              minLines: null,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              height: 140,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              prefix: Icon(
                Icons.camera_alt,
                size: 20.r,
                color: AppColors.authBorderColor,
              ),
              hintText: LocaleKeys.uploadImages.tr(),
              enabled: false,
              height: 45,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            // Update cover image input to match add product screen:
            GestureDetector(
              onTap: () {
                cubit.getCoverImagePick();
              },
              child: Container(
                height: 45.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.authBorderColor),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(LocaleKeys.uploadCoverImage.tr()),
                ),
              ),
            ),
            const CustomSizedBox(height: 11),
            // Show cover image preview with same size as additional images:
            if (cubit.coverImage != null)
              Stack(
                children: [
                  Container(
                    height: 36.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: AppColors.authBorderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Image.file(
                        cubit.coverImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          cubit.coverImage = null;
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            const CustomSizedBox(height: 11),
            CustomSizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 36.h,
                    width: 50.w,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Image.asset(
                      ImagesPath.uploadedImages,
                      fit: BoxFit.cover,
                    ),
                  ).onlyDirectionalPadding(end: 5);
                },
              ),
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              prefix: Icon(
                Icons.link_rounded,
                size: 20.r,
                color: AppColors.authBorderColor,
              ),
              hintText: LocaleKeys.youtubeLink.tr(),
              height: 45,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            TagsInputField(
              controller: cubit.tags,
              hintText: LocaleKeys.addTags.tr(),
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              hintText: LocaleKeys.pros.tr(),
              minLines: null,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              height: 86,
            ),
            const CustomSizedBox(
              height: 11,
            ),
            CustomTextField(
              hintText: LocaleKeys.cons.tr(),
              minLines: null,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              height: 86,
            ),
            const CustomSizedBox(
              height: 40,
            ),
            CustomElevatedButton(
              title: LocaleKeys.uploadYourProduct.tr(),
              onPressed: () {},
              buttonSize: Size(double.infinity, 48.h),
            ),
          ],
        ),
      ),
    );
  }
}
