import 'package:an3am/presentation/widgets/home_screen_widgets/categories_and_subcategories_tab_bars_widgets/categories_tab_bar_item_widget.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/controllers/map_cubit/map_cubit.dart';
import '../../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../../domain/controllers/products_cubit/products_state.dart';

class ProductCategoriesTabBarWidget extends StatefulWidget {
  const ProductCategoriesTabBarWidget({super.key});

  @override
  State<ProductCategoriesTabBarWidget> createState() =>
      _ProductCategoriesTabBarWidgetState();
}

class _ProductCategoriesTabBarWidgetState
    extends State<ProductCategoriesTabBarWidget> {
  ScrollController scrollController = ScrollController();

  void scrollLeft() {
    scrollController.animateTo(
      scrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollRight() {
    scrollController.animateTo(
      scrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    var cubit = ProductsCubit.get(context);
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent == scrollController.offset) {
        cubit.getAllCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = ProductsCubit.get(context);
        return Container(
          height: 93.h,
          padding: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 4.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: scrollLeft,
                icon: Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  separatorBuilder: (_, index) => const CustomSizedBox(width: 4),
                  itemCount: cubit.categoriesList.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  itemBuilder: (BuildContext context, int index) {
                    return CategoriesTabBarItem(
                      onTap: () {
                        // التحقق مما إذا كان هذا التصنيف محدد بالفعل
                        if (index == cubit.selectedCategoryIndex) {
                          // إلغاء تحديد التصنيف
                          cubit.changeCategoriesTabBarWidget(
                            -1,  // قيمة خارج نطاق التصنيفات
                            categoryId: -1,
                          );
                          
                          // إعادة تعيين قائمة المنتجات للقائمة الكاملة
                          cubit.resetProductsList();
                          
                          // عرض جميع المنتجات على الخريطة
                          final mapCubit = context.read<MapCubit>();
                          mapCubit.mapProducts = cubit.mapProductsList;
                          mapCubit.filterProductsByCategory(null);
                        } else {
                          // تحديد تصنيف جديد
                          cubit.changeCategoriesTabBarWidget(
                            index,
                            categoryId: cubit.categoriesList[index].id!,
                          );

                          // تصفية المنتجات حسب التصنيف المحدد
                          final mapCubit = context.read<MapCubit>();
                          mapCubit.mapProducts = cubit.mapProductsList;
                          mapCubit.filterProductsByCategory(
                            cubit.categoriesList[index].id,
                          );
                        }
                      },
                      isSelected: index == cubit.selectedCategoryIndex,
                      imagePath: cubit.categoriesList[index].image!,
                      title: cubit.categoriesList[index].name!,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: scrollRight,
                icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}
