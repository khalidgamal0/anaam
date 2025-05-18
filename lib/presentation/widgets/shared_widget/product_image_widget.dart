import 'package:an3am/core/app_router/screens_name.dart';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/products_model/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:an3am/core/assets_path/svg_path.dart';
import 'dart:ui'; // لاستخدام ImageFiltered وBackdropFilter
import '../../../domain/controllers/profile_cubit/profile_cubit.dart';
import '../../../../core/cache_helper/cache_keys.dart';
import '../../../../core/cache_helper/shared_pref_methods.dart';
import '../../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../../domain/controllers/products_cubit/products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemImageWidget extends StatefulWidget {
  final ProductDataModel productDataModel;
  final bool isFavorite;

  const ItemImageWidget({
    super.key,
    required this.productDataModel,
    this.isFavorite = true,
  });

  @override
  State<ItemImageWidget> createState() => _ItemImageWidgetState();
}

class _ItemImageWidgetState extends State<ItemImageWidget> {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل المنتج
        Navigator.pushNamed(
          context,
          ScreenName.productDetailsScreen,
          arguments: widget.productDataModel,
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // الخلفية الضبابية
          Container(
            height: 314.h,
            width: double.infinity,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // الصورة الخلفية
                PageView.builder(
                  itemCount: widget.productDataModel.images!.length,
                  controller: controller,
                  itemBuilder: (BuildContext context, int index) {
                    return CachedNetworkImage(
                      imageUrl: widget.productDataModel.images![index].image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[300]!,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    );
                  },
                ),
                // تأثير الضباب
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.2), // خفيف لتعزيز الضباب
                  ),
                ),
              ],
            ),
          ),
          // الصورة الأساسية (واضحة)
          Container(
            height: 280.h, // أصغر قليلاً من الخلفية لإظهار الضباب
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: PageView.builder(
              itemCount: widget.productDataModel.images!.length,
              controller: controller,
              itemBuilder: (BuildContext context, int index) {
                return CachedNetworkImage(
                  imageUrl: widget.productDataModel.images![index].image!,
                  fit: BoxFit.contain, // عرض الصورة بشكلها الطبيعي
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[300]!,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              },
            ),
          ),
          // النقاط
          if (widget.productDataModel.images != null &&
              widget.productDataModel.images!.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: controller,
                count: widget.productDataModel.images!.length,
                effect: SlideEffect(
                  spacing: 8.w,
                  radius: 4.0,
                  dotWidth: 8.w,
                  dotHeight: 8.h,
                  paintStyle: PaintingStyle.fill,
                  dotColor: Colors.grey.withOpacity(0.5),
                  activeDotColor: Colors.white,
                ),
              ),
            ).symmetricPadding(vertical: 12.h),
          // صورة الملف الشخصي
          PositionedDirectional(
            start: 28.w,
            bottom: 20.h,
            child: InkWell(
              onTap: () {
                ProfileCubit.get(context)
                    .showVendorProfile(
                        id: widget.productDataModel.uploadedBy!.id!)
                    .then((value) {
                  Navigator.pushNamed(context, ScreenName.vendorDetailsScreen,
                      arguments: ProfileCubit.get(context).vendorProfileModel);
                });
              },
              child: Container(
                height: 48.h,
                width: 48.w,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.productDataModel.uploadedBy!.image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[300]!,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          // زر المفضلة
          if (CacheHelper.getData(key: CacheKeys.token) != null)
            PositionedDirectional(
              end: 28.w,
              top: 19.h,
              child: BlocConsumer<ProductsCubit, ProductsState>(
                buildWhen: (previous, current) => true,
                listenWhen: (previous, current) => true,
                listener: (context, state) {
                  // يمكن إضافة استماع للحالة هنا
                },
                builder: (context, state) {
                  var cubit = ProductsCubit.get(context);
                  bool isFavorite = cubit
                          .favoriteProduct[widget.productDataModel.id.toString()] ??
                      false;
                  return GestureDetector(
                    onTap: () {
                      cubit.changeFavorite(id: widget.productDataModel.id!);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        isFavorite ? SvgPath.redLike : SvgPath.like,
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}