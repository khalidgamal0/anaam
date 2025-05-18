import 'package:an3am/core/app_router/screens_name.dart';
import 'package:an3am/core/assets_path/svg_path.dart';
import 'package:an3am/core/constants/constants.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/products_model/product_model.dart';
import 'package:an3am/domain/controllers/products_cubit/products_cubit.dart';
import 'package:an3am/domain/controllers/products_cubit/products_state.dart';
import 'package:an3am/presentation/screens/main_layout_screens/profile_screens/add_product_screen.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_switch_button.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import '../../../../core/app_theme/app_colors.dart';
import '../../../../core/app_theme/custom_themes.dart';
import '../../../widgets/shared_widget/custom_outlined_button.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isTimedOut = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _loadingTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
        });
      }
    });

    ProductsCubit.get(context).showVendorProfile(id: int.parse(userId!.toString()));
  }

  @override
  void dispose() {
    final productsCubit = ProductsCubit.get(context);
    productsCubit.allProductsPageNumber = 1;
    productsCubit.productsList.clear();
    productsCubit.searchedProductsList.clear();
    productsCubit.selectedCategoryIndex = null;
    productsCubit.selectedSubCategoryIndex = null;
    productsCubit.showCategoryModel = null;
    productsCubit.searchValue.clear();
    productsCubit.getAllProducts();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomSizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      LocaleKeys.productList.tr(),
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: 20.sp,
                          ),
                    ),
                  ],
                ),
                BlocBuilder<ProductsCubit, ProductsState>(
                  builder: (context, state) {
                    ProductsCubit cubit = ProductsCubit.get(context);
                    return CustomOutlinedButton(
                      height: 40.h,
                      radius: 8.r,
                      onPressed: () {
                        // مسح جميع البيانات عند إضافة منتج جديد
                        cubit.productNameAr.clear();
                        cubit.locationAr.clear();
                        cubit.productPrice.clear();
                        cubit.productDescriptionAr.clear();
                        cubit.productProsAr.clear();
                        cubit.productConsAr.clear();
                        cubit.youtubeLink.clear();
                        cubit.tags.clear(); // إضافة مسح التاجات
                        cubit.mapLocation = null;
                        cubit.productImages.clear();
                        Navigator.pushNamed(context, ScreenName.addProductScreen);
                      },
                      borderColor: AppColors.greyColor9D,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.greyColor71,
                            size: 18.r,
                          ),
                          const CustomSizedBox(
                            width: 8,
                          ),
                          Text(
                            LocaleKeys.addProduct.tr(),
                            style: CustomThemes.grey7DColorTextTheme(context)
                                .copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ).symmetricPadding(horizontal: 16),
            const CustomSizedBox(
              height: 8,
            ),
            BlocConsumer<ProductsCubit, ProductsState>(
              listener: (context, state) {
                ProductsCubit cubit = ProductsCubit.get(context);
                if (state is DeleteProductSuccessState) {
                  Navigator.pop(context);
                  ProductsCubit.get(context)
                      .showVendorProfile(id: int.parse(userId!.toString()));
                  showToast(errorType: 1, message: "تم الحذف بنجاح");
                }
                if (state is DeleteProductErrorState) {
                  Navigator.pop(context);
                  ProductsCubit.get(context)
                      .showVendorProfile(id: int.parse(userId!.toString()));
                  showToast(errorType: 0, message: "تم الحذف بنجاح");
                }
                if (state is ShowProductMultiLangErrorState) {
                  Navigator.pop(context);
                }
                if (state is ShowProductMultiLangSuccessState) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductScreen(
                        productMultiLangModel: cubit.productMultiLangModel,
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                ProductsCubit cubit = ProductsCubit.get(context);

                if (cubit.getVendorProfileData && !_isTimedOut) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }

                if (_isTimedOut && cubit.getVendorProfileData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.r,
                          color: AppColors.greyColor9D,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "ليس لديك اي منتجات حالياً.",
                          style: CustomThemes.grey7DColorTextTheme(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isTimedOut = false;
                            });
                            _initData();
                          },
                          child: Text(
                            "إعادة المحاولة",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final hasProducts =
                    cubit.vendorProfileModel?.productsList?.isNotEmpty ?? false;

                if (!hasProducts) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.r,
                            color: AppColors.greyColor9D,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            LocaleKeys.noProducts.tr(),
                            style: CustomThemes.grey7DColorTextTheme(context)
                                .copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    itemBuilder: (_, index) {
                      return ProductElement(
                        productDataModel:
                            cubit.vendorProfileModel!.productsList![index],
                      );
                    },
                    separatorBuilder: (_, index) {
                      return SizedBox(height: 16.h);
                    },
                    itemCount:
                        cubit.vendorProfileModel!.productsList!.length,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ProductElement extends StatelessWidget {
  final ProductDataModel productDataModel;

  const ProductElement({
    super.key,
    required this.productDataModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        // ProductsCubit cubit = ProductsCubit.get(context);
      },
      builder: (context, state) {
        ProductsCubit cubit = ProductsCubit.get(context);
        return Container(
          height: 54.h,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor9D, width: 1.2.w),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              CustomSwitchButton(
                productDataModel: productDataModel,
              ),
              const CustomSizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productDataModel.name!,
                      style:
                          CustomThemes.greyColor34TextTheme(context).copyWith(
                        fontSize: 14.sp,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const CustomSizedBox(
                      height: 4,
                    ),
                    Text(
                      "${productDataModel.category!.name} ",
                      style:
                          CustomThemes.grey7DColorTextTheme(context).copyWith(
                        fontSize: 14.sp,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  cubit.getMultiLangProduct(id: productDataModel.id!);
                  showProgressIndicator(context);
                },
                child: SvgPicture.asset(
                  SvgPath.editIcon,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              const CustomSizedBox(
                width: 16,
              ),
              InkWell(
                onTap: () {
                  cubit.deleteProduct(productId: productDataModel.id!);
                  showProgressIndicator(context);
                },
                child: SvgPicture.asset(
                  SvgPath.trash,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              const CustomSizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                productDataModel.isApproved! == false
                    ? SvgPath.notConfirmed
                    : SvgPath.accepted,
                width: 24.w,
                height: 24.h,
              ),
            ],
          ),
        );
      },
    );
  }
}
