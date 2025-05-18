import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui'; // لاستخدام ImageFiltered وBackdropFilter
import '../../../core/app_theme/app_colors.dart';
import '../../../core/assets_path/svg_path.dart';
import '../../../core/cache_helper/cache_keys.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';
import '../../../data/models/products_model/product_model.dart';
import '../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../domain/controllers/products_cubit/products_state.dart';
import '../shared_widget/custom_circle_button.dart';
import '../../../core/network/api_end_points.dart';

class ProductDetailsImagesWidget extends StatefulWidget {
  final List<Images> imagesList;
  final int? id;

  const ProductDetailsImagesWidget({
    super.key,
    required this.imagesList,
    this.id,
  });

  @override
  State<ProductDetailsImagesWidget> createState() =>
      _ProductDetailsImagesWidgetState();
}

class _ProductDetailsImagesWidgetState
    extends State<ProductDetailsImagesWidget> {
  PageController controller = PageController();

  void openZoomViewer(int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        PageController dialogController = PageController(initialPage: initialIndex);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 400.h,
                child: PageView.builder(
                  controller: dialogController,
                  itemCount: widget.imagesList.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.imagesList[index].image!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.imagesList.length > 1) ...[
                Positioned(
                  left: 10.w,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    onPressed: () {
                      dialogController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 10.w,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    onPressed: () {
                      dialogController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
              if (widget.imagesList.length > 1)
                Positioned(
                  bottom: 10.h,
                  child: SmoothPageIndicator(
                    controller: dialogController,
                    count: widget.imagesList.length,
                    effect: SlideEffect(
                      spacing: 8.w,
                      radius: 4.0,
                      dotWidth: 8.w,
                      dotHeight: 8.h,
                      paintStyle: PaintingStyle.fill,
                      dotColor: Colors.white.withOpacity(0.5),
                      activeDotColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية الضبابية
        SizedBox(
          height: 254.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // الصورة الخلفية
              PageView.builder(
                controller: controller,
                itemCount: widget.imagesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.network(
                    widget.imagesList[index].image!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50.sp,
                    ),
                  );
                },
              ),
              // تأثير الضباب
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2), // تعزيز الضباب
                ),
              ),
            ],
          ),
        ),
        // الصورة الأساسية (واضحة)
        Container(
          height: 230.h, // أصغر قليلاً لإظهار الخلفية الضبابية
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: PageView.builder(
            controller: controller,
            itemCount: widget.imagesList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => openZoomViewer(index),
                child: Image.network(
                  widget.imagesList[index].image!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50.sp,
                  ),
                ),
              );
            },
          ),
        ),
        // العناصر الأخرى (كما هي)
        PositionedDirectional(
          end: 28.w,
          top: 20.h,
          child: Row(
            children: [
              CustomCircleButton(
                iconPath: Icons.ios_share,
                onPressed: () {
                  final productLink = '${EndPoints.siteUrl}products/${widget.id}';
                  Share.share(productLink);
                },
                backgroundColor: AppColors.whiteColor,
                iconSize: 14.r,
                elevation: 0,
                width: 25.w,
                height: 25.h,
              ),
              const CustomSizedBox(width: 10),
              if (CacheHelper.getData(key: CacheKeys.token) != null)
                BlocConsumer<ProductsCubit, ProductsState>(
                  listener: (context, state) {
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    var cubit = ProductsCubit.get(context);
                    bool isFavorite =
                        cubit.favoriteProduct[widget.id.toString()] ?? false;
                    return IconButton(
                      onPressed: () {
                        cubit.changeFavorite(id: widget.id!);
                      },
                      padding: EdgeInsets.zero,
                      icon: SvgPicture.asset(
                        isFavorite ? SvgPath.redLike : SvgPath.like,
                        width: 18.w,
                        height: 18.h,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        if (widget.imagesList.isNotEmpty)
          Positioned.fill(
            bottom: 14.h,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: controller,
                count: widget.imagesList.length,
                effect: SlideEffect(
                  spacing: 6.9.w,
                  radius: 4.0,
                  dotWidth: 6.w,
                  dotHeight: 6.h,
                  paintStyle: PaintingStyle.fill,
                  dotColor: Colors.white.withOpacity(.7),
                  activeDotColor: Colors.white,
                ),
              ),
            ),
          ),
        PositionedDirectional(
          start: 30.w,
          top: 20.h,
          child: CustomCircleButton(
            isSvgChild: true,
            onPressed: () {
              Navigator.pop(context);
            },
            width: 25.w,
            elevation: 0,
            height: 25.h,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}