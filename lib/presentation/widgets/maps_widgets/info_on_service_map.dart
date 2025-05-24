import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';


class InfoOnServiceMap extends StatelessWidget {
  const InfoOnServiceMap({super.key, required this.img, required this.name, this.mapLocation});

  final String img;
  final String name;
  final String? mapLocation;

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
                height: 160.h,
                width: 200.w,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: img,
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
                )),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: SmoothPageIndicator(
            //     controller: controller,
            //     count: DummyData.camelsDummyImages.length,
            //     effect: SlideEffect(
            //       spacing: 3.9.w,
            //       radius: 4.0,
            //       dotWidth: 4.6.w,
            //       dotHeight: 4.6.h,
            //       paintStyle: PaintingStyle.fill,
            //       dotColor: Colors.white.withOpacity(.7),
            //       activeDotColor: Colors.white,
            //     ),
            //   ),
            // ).symmetricPadding(vertical: 9.38),
            // if (CacheHelper.getData(key: CacheKeys.token) != null)
            //   PositionedDirectional(
            //     start: 4.w,
            //     top: 4.h,
            //     child: BlocBuilder<ProductsCubit, ProductsState>(
            //       builder: (context, state) {
            //         var cubit = ProductsCubit.get(context);
            //         return IconButton(
            //           onPressed: () {
            //             cubit.changeFavorite(id: widget.productDataModel.id!);
            //           },
            //           padding: EdgeInsets.zero,
            //           icon: SvgPicture.asset(
            //             (cubit.favoriteProduct[widget.productDataModel.id.toString()] ?? false)
            //                 ? SvgPath.redLike
            //                 : SvgPath.like,
            //             width: 18.w,
            //             height: 18.h,
            //           ),
            //         );
            //       },
            //     ),
            //   ),
          ],
        ),

        Container(
          width: 200.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.r),bottomRight: Radius.circular(10.r)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontSize: 16.sp,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}
