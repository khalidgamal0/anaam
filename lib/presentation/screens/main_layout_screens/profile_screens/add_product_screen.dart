import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/core/parameters/upload_product_parameters.dart';
import 'package:an3am/data/models/categories/categories_model.dart';
import 'package:an3am/data/models/categories/sub_categories_model.dart';
import 'package:an3am/data/models/multi_lang_models/product_multi_lang_model.dart';
import 'package:an3am/presentation/screens/map_screen.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:an3am/core/cache_helper/shared_pref_methods.dart';
import '../../../../core/app_theme/app_colors.dart';
import '../../../../core/network/api_end_points.dart';
import '../../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../../domain/controllers/products_cubit/products_state.dart';
import '../../../widgets/auth_widgets/custom_drop_down_button.dart';
import '../../../widgets/auth_widgets/custom_text_field.dart';
import '../../../widgets/shared_widget/custom_divider.dart';
import '../../../widgets/shared_widget/custom_elevated_button.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';
import '../../../widgets/shared_widget/tags_input_field.dart';

class AddProductScreen extends StatefulWidget {
  final ProductMultiLangModel? productMultiLangModel;

  const AddProductScreen({super.key, this.productMultiLangModel});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late final ProductsCubit cubit;
  final formKey = GlobalKey<FormState>();
  String? selectedCurrency = '1';

  @override
  void initState() {
    super.initState();
    cubit = ProductsCubit.get(context);
    
    if (widget.productMultiLangModel != null) {
      // تعيين بيانات المنتج عند التعديل
      cubit.productNameAr.text = widget.productMultiLangModel!.name!['ar'] ?? "";
      cubit.locationAr.text = widget.productMultiLangModel!.location!['ar'] ?? "";
      cubit.productPrice.text = widget.productMultiLangModel!.salePrice?.toString() ?? "";
      cubit.productDescriptionAr.text = widget.productMultiLangModel!.description!['ar'] ?? "";
      cubit.productProsAr.text = widget.productMultiLangModel!.advantages!['ar'] ?? "";
      cubit.productConsAr.text = widget.productMultiLangModel!.defects!['ar'] ?? "";
      cubit.youtubeLink.text = widget.productMultiLangModel!.youtubeLink ?? "";
      cubit.mapLocation = widget.productMultiLangModel!.mapLocation ?? "";
      cubit.productCurrency.text = widget.productMultiLangModel!.productCurrency ?? "5";
      cubit.priceType.text = widget.productMultiLangModel!.priceType ?? "";
      // تعيين التاجات
      if (widget.productMultiLangModel!.tags != null && widget.productMultiLangModel!.tags!.isNotEmpty) {
        cubit.tags.text = widget.productMultiLangModel!.tags!.join(', ');
      } else {
        cubit.tags.clear();
      }
      // تعيين بيانات الهاتف والدولة
      cubit.countryId.text = widget.productMultiLangModel!.countryId?.toString() ?? "";
      cubit.phoneNumber.text = widget.productMultiLangModel!.phoneNumber ?? "";
      cubit.phoneCode.text = widget.productMultiLangModel!.phoneCode ?? "";
      print("widget.productMultiLangModel!.phoneCode");
      print(widget.productMultiLangModel!.phoneCode);
      // ...existing code to set category and sub-category...
      if (widget.productMultiLangModel!.categoryId != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cubit.categoriesList.isNotEmpty) {
            final category = cubit.categoriesList.firstWhere(
              (cat) => cat.id == widget.productMultiLangModel!.categoryId,
              orElse: () => cubit.categoriesList.first,
            );
            cubit.chooseCategory(category);
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (widget.productMultiLangModel!.subCategoryId != null &&
                  cubit.showCategoryModel?.subCategories != null) {
                final subCategory = cubit.showCategoryModel!.subCategories!.firstWhere(
                  (subCat) => subCat.id == widget.productMultiLangModel!.subCategoryId,
                  orElse: () => cubit.showCategoryModel!.subCategories!.first,
                );
                cubit.chooseSubCategory(subCategory);
              }
            });
          }
        });
      }
    } else {
      // Clear all fields when adding a new product and reset persistent fields
      cubit.productNameAr.clear();
      cubit.locationAr.clear();
      cubit.productPrice.clear();
      cubit.productDescriptionAr.clear();
      cubit.productProsAr.clear();
      cubit.productConsAr.clear();
      cubit.youtubeLink.clear();
      cubit.tags.clear();
      cubit.mapLocation = null;
      cubit.countryId.clear();
      cubit.phoneCode.clear();
      cubit.coverImage = null;
    }
    // Load categories only (do not clear fields if editing)
    cubit.getAllCategories();
  }

  @override
  void dispose() {
    cubit.resetCategorySelection(); // Clear category selections
    super.dispose();
  }

  // Add this helper method:
  String _buildImageUrl(String imagePath) {
    final base = EndPoints.siteUrl;
    if (base.endsWith('/')) {
      return '$base${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
    } else {
      return '$base/${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {
            if (state is UploadProductLoadingState) {
              showProgressIndicator(context);
            }
            if (state is DeleteProductImagesSuccessState) {
              Navigator.pop(context);
              // Remove the image from the local model
              widget.productMultiLangModel!.images!
                  .removeWhere((element) => element.id == state.imageId);
              // Clear the cached image using its URL
              String imageUrl = "${EndPoints.imagesBaseUrl}/${state.imageId}";
              CachedNetworkImage.evictFromCache(imageUrl);
              showToast(errorType: 0, message: "حذف");
            }
            if (state is DeleteProductImagesErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: "خطاء");
            }
            if (state is UploadProductSuccessState) {
              Navigator.pop(context);
              Navigator.pop(context);
              cubit.productNameAr.clear();
              cubit.locationAr.clear();
              cubit.productPrice.clear();
              cubit.productDescriptionAr.clear();
              cubit.productProsAr.clear();
              cubit.productConsAr.clear();
              cubit.youtubeLink.clear();
              cubit.mapLocation = null;
              cubit.productImages.clear();
              cubit.tags.clear();
            }
            if (state is UploadProductErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
            if (state is UpdateProductLoadingState) {
              showProgressIndicator(context);
            }
            if (state is UpdateProductSuccessState) {
              Navigator.pop(context);
              Navigator.pop(context);
              cubit.productNameAr.clear();
              cubit.locationAr.clear();
              cubit.productPrice.clear();
              cubit.productDescriptionAr.clear();
              cubit.productProsAr.clear();
              cubit.productConsAr.clear();
              cubit.youtubeLink.clear();
              cubit.mapLocation = null;
              cubit.productImages.clear();
            }
            if (state is UpdateProductErrorState) {
              Navigator.pop(context);
              showToast(errorType: 1, message: state.error);
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 20.r,
                            color: AppColors.greyColor34,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          LocaleKeys.addProduct.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontSize: 20.sp),
                        ),
                      ],
                    ),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    const CustomDivider(),
                    const CustomSizedBox(
                      height: 17,
                    ),
                    cubit.getAllCategoriesLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : CustomDropDownButton<CategoriesModel>(
                            height: 45,
                            onChanged: cubit.chooseCategory,
                            hint: LocaleKeys.mainClassification.tr(),
                            items: cubit.categoriesList
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(fontSize: 14.sp)),
                                    ))
                                .toList(),
                            value: cubit.productCategory,
                          ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    cubit.showCategoryModel == null
                        ? const SizedBox.shrink()
                        : cubit.getCategory
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : CustomDropDownButton<SubCategoriesModel>(
                                height: 45,
                                onChanged: cubit.chooseSubCategory,
                                hint: LocaleKeys.subCategory.tr(),
                                items: cubit.showCategoryModel!.subCategories!
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.name!),
                                        ))
                                    .toList(),
                                value: cubit.productSubCategory,
                              ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.productNameAr.tr(),
                      controller: cubit.productNameAr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.locationAr.tr(),
                      controller: cubit.locationAr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.price.tr(),
                      controller: cubit.productPrice,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomDropDownButton<String>(
                      height: 45,
                      onChanged: (value) {
                        setState(() {
                          cubit.productCurrency.text = value!;
                        });
                      },
                      hint: LocaleKeys.productCurrency.tr(),
                      items: [
                        DropdownMenuItem(
                            value: '1', child: Text('ريال سعودي (ر.س)')),
                        DropdownMenuItem(
                            value: '2', child: Text('درهم إماراتي (د.إ)')),
                        DropdownMenuItem(
                            value: '3', child: Text('دينار كويتي (د.ك)')),
                        DropdownMenuItem(
                            value: '4', child: Text('ريال قطري (ر.ق)')),
                        DropdownMenuItem(
                            value: '5', child: Text('ريال عماني (ر.ع)')),
                        DropdownMenuItem(
                            value: '6', child: Text('دينار بحريني (د.ب)')),
                      ],
                      value: cubit.productCurrency.text.isNotEmpty ? cubit.productCurrency.text : null,
                    ),
                    const CustomSizedBox(height: 11),
                    // Replace the current priceType CustomTextField:
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
                      value: cubit.priceType.text.isNotEmpty ? cubit.priceType.text : null,
                    ),
                    const CustomSizedBox(height: 11),
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
                    // Update phoneNumber input to use just keyboardType for numeric input
                    CustomTextField(
                      hintText: LocaleKeys.phoneNumber.tr(),
                      controller: cubit.phoneNumber,
                      height: 45,
                      keyboardType: TextInputType.number,
                    ),
                    const CustomSizedBox(height: 11),
                    CustomTextField(
                      hintText: LocaleKeys.productDescriptionAr.tr(),
                      maxLines: 8,
                      controller: cubit.productDescriptionAr,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    InkWell(
                      onTap: () async {
                        Map<String, dynamic> result = await Navigator.push(
                            context, MaterialPageRoute(builder: (_) {
                          return const MapScreen();
                        }));
                        cubit.getLocation(
                            locationName: result["name"],
                            coordinates: result['coordinates']);
                      },
                      child: CustomTextField(
                        prefix: Icon(
                          Icons.location_on_outlined,
                          size: 20.r,
                          color: AppColors.authBorderColor,
                        ),
                        hintText: cubit.mapLocation ?? "اختر الموقع",
                        enabled: false,
                        height: 45,
                      ),
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    // Cover image input (big input without preview)
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
                    // Show cover image preview with same size as additional images
                    if (cubit.coverImage != null)
                      Stack(
                        children: [
                          // local file preview
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
                      )
                    else if (widget.productMultiLangModel != null &&
                             widget.productMultiLangModel!.mainImage != null &&
                             widget.productMultiLangModel!.mainImage!['ar'] != null)
                      CachedNetworkImage(
                        height: 36.h,
                        width: 50.w,
                        imageUrl: _buildImageUrl(widget.productMultiLangModel!.mainImage!['ar']!),
                        // changed: force unwrapped the image path using '!'
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[300]!,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    const CustomSizedBox(height: 11),
                    InkWell(
                      onTap: () {
                        cubit.getImagePick();
                      },
                      child: CustomTextField(
                        prefix: Icon(
                          Icons.camera_alt,
                          size: 20.r,
                          color: AppColors.authBorderColor,
                        ),
                        hintText: LocaleKeys.uploadImages.tr(),
                        enabled: false,
                        height: 45,
                      ),
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    // Updated additional images list builder with delete option
                    CustomSizedBox(
                      height: cubit.productImages.isEmpty ? 0 : 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cubit.productImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Container(
                                height: 36.h,
                                width: 50.w,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Image.file(
                                  cubit.productImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    // Remove the selected image
                                    setState(() {
                                      cubit.productImages.removeAt(index);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).onlyDirectionalPadding(end: 5);
                        },
                      ),
                    ),
                    const CustomSizedBox(height: 11),
                    if (widget.productMultiLangModel != null &&
                        widget.productMultiLangModel!.images != null &&
                        widget.productMultiLangModel!.images!.isNotEmpty)
                      Text(
                        LocaleKeys.attachedImages.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontSize: 16.sp),
                      ),
                    if (widget.productMultiLangModel != null &&
                        widget.productMultiLangModel!.images != null &&
                        widget.productMultiLangModel!.images!.isNotEmpty)
                      const CustomSizedBox(
                        height: 11,
                      ),
                    if (widget.productMultiLangModel != null &&
                        widget.productMultiLangModel!.images != null &&
                        widget.productMultiLangModel!.images!.isNotEmpty)
                      CustomSizedBox(
                        height: widget.productMultiLangModel!.images!.isEmpty
                            ? 0
                            : 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              widget.productMultiLangModel!.images!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 60.h,
                              width: 60.w,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CachedNetworkImage(
                                    height: double.infinity,
                                    width: double.infinity,
                                    imageUrl: _buildImageUrl(widget.productMultiLangModel!.images![index].imageAr!),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[200]!,
                                        highlightColor: Colors.grey[300]!,
                                        child: Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    color:
                                        AppColors.blackColor.withOpacity(0.1),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cubit.deleteProductImages(
                                          id: widget.productMultiLangModel!
                                              .images![index].id!);
                                      showProgressIndicator(context);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: AppColors.whiteColor,
                                      size: 22.sp,
                                    ),
                                  ),
                                ],
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
                      controller: cubit.youtubeLink,
                      hintText: LocaleKeys.youtubeLink.tr(),
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
                      hintText: LocaleKeys.productProsAr.tr(),
                      maxLines: 8,
                      controller: cubit.productProsAr,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.dataMustBeEntered.tr();
                        }
                        return null;
                      },
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomTextField(
                      hintText: LocaleKeys.productConsAr.tr(),
                      maxLines: 8,
                      controller: cubit.productConsAr,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                    const CustomSizedBox(
                      height: 11,
                    ),
                    CustomElevatedButton(
                      title: LocaleKeys.uploadYourProduct.tr(),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Ensure cover image is selected
                          if (cubit.coverImage == null) {
                            showToast(
                              errorType: 1,
                              message: "من فضلك إختر صورة الغلاف",
                            );
                            return;
                          }
                          if (widget.productMultiLangModel == null) {
                            cubit.tags.clear();
                            if (cubit.productImages.isEmpty) {
                              showToast(
                                errorType: 1,
                                message: LocaleKeys.imagesMustBeSelected.tr(),
                              );
                            } else if (cubit.productCategory == null) {
                              showToast(
                                errorType: 1,
                                message: LocaleKeys.categoriesMustBeSelected.tr(),
                              );
                            } else if (cubit.mapLocation == null) {
                              showToast(
                                errorType: 1,
                                message: LocaleKeys.locationMustBeSelected.tr(),
                              );
                            } else {
                              cubit.uploadProduct(
                                productParameters: ProductParameters(
                                  catId: cubit.productCategory!.id!.toString(),
                                  subCatId: cubit.productSubCategory != null
                                      ? cubit.productSubCategory!.id!.toString()
                                      : null,
                                  nameAr: cubit.productNameAr.text,
                                  salePrice: cubit.productPrice.text,
                                  mainImage: cubit.coverImage, // using cover image
                                  locationAr: cubit.locationAr.text,
                                  descriptionAr: cubit.productDescriptionAr.text,
                                  coordinates: cubit.mapCoordinates,
                                  mapLocation: cubit.mapLocation,
                                  youtubeLink: cubit.youtubeLink.text,
                                  advantagesAr: cubit.productProsAr.text,
                                  defectsAr: cubit.productConsAr.text,
                                  images: cubit.productImages,
                                // New extra parameters if needed:
                                  priceType: cubit.priceType.text,
                                  countryId: int.tryParse(cubit.countryId.text),
                                  phoneNumber: cubit.phoneNumber.text,
                                  phoneCode: cubit.phoneCode.text,
                                ),
                              );
                            }
                          } else {
                            cubit.updateProduct(
                              productParameters: ProductParameters(
                                catId: cubit.productCategory != null
                                    ? cubit.productCategory!.id.toString()
                                    : widget.productMultiLangModel!.categoryId!.toString(),
                                subCatId: cubit.productSubCategory?.id?.toString() ?? "",
                                nameAr: cubit.productNameAr.text,
                                productId: widget.productMultiLangModel!.id.toString(),
                                salePrice: cubit.productPrice.text,
                                locationAr: cubit.locationAr.text,
                                method: "PUT",
                                descriptionAr: cubit.productDescriptionAr.text,
                                coordinates: cubit.mapCoordinates ?? widget.productMultiLangModel!.coordinates,
                                mapLocation: cubit.mapLocation,
                                youtubeLink: cubit.youtubeLink.text,
                                advantagesAr: cubit.productProsAr.text,
                                defectsAr: cubit.productConsAr.text,
                                mainImage: cubit.coverImage, // using cover image
                                images: cubit.productImages,
                                // New extra parameters if needed:
                                priceType: cubit.priceType.text,
                                countryId: int.tryParse(cubit.countryId.text),
                                phoneNumber: cubit.phoneNumber.text,
                                phoneCode: cubit.phoneCode.text,
                              ),
                            );
                          }
                        }
                      },
                      buttonSize: Size(double.infinity, 48.h),
                    ),
                  ],
                ).symmetricPadding(horizontal: 26, vertical: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}
