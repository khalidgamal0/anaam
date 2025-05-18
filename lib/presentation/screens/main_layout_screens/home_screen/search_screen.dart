import 'dart:async';
import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/data/models/categories/categories_model.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:an3am/presentation/widgets/shared_widget/product_item_component.dart';
import '../../../widgets/auth_widgets/custom_drop_down_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_router/screens_name.dart';
import '../../../../domain/controllers/products_cubit/products_cubit.dart';
import '../../../../domain/controllers/products_cubit/products_state.dart';
import '../../../widgets/shared_widget/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchController;
  Timer? _debounce;
  ProductsCubit? cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<ProductsCubit>();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _performSearch);
  }

  void _performSearch() {
    if (cubit == null) return;
    cubit!.allSearchedProductsPageNumber = 1;
    cubit!.searchedProductsList.clear();
    cubit!.getAllSearchedProducts(
      value: searchController.text.trim(),
      categoryId: cubit!.productCategory?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {},
          builder: (context, state) {
            cubit = context.watch<ProductsCubit>();

            return Column(
              children: [
                // حقل البحث
                Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: "searchField",
                    child: Material(
                      color: Colors.transparent,
                      child: SearchBarWidget(
                        controller: searchController,
                        onSearchClicked: _performSearch,
                        onSubmitted: (_) => _performSearch(),
                        autofocus: true,
                        enabled: true,
                      ),
                    ),
                  ),
                ),

                // تصفية حسب التصنيفات
                (cubit?.getAllCategoriesLoading ?? false)
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: CustomDropDownButton<CategoriesModel>(
                                height: 45,
                                onChanged: (category) {
                                  // if (category == null) {
                                  //   cubit?.chooseCategory(null);
                                  // } else {
                                  //   cubit?.chooseCategory(category);
                                  // }
                                  cubit?.chooseCategory(category);
                                  _performSearch(); // البحث بالكلمة والتصنيف معًا
                                },
                                hint: "اختر التصنيف الرئيسي",
                                items: [
                                  DropdownMenuItem<CategoriesModel>(
                                    value: null, // تأكد من أن هذه القيمة `null`
                                    child: Text(
                                      "كل التصنيفات",
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14),
                                    ),
                                  ),
                                  ...?cubit?.categoriesList.map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e.name!,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                                value: cubit?.productCategory,
                              ),
                      ),

                // عرض النتائج
                Expanded(
                  child: (cubit?.getSearchedProductsLoading ?? false)
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : ListView.separated(
                          itemBuilder: (_, index) {
                            final product = cubit?.searchedProductsList[index];
                            if (product == null) return const SizedBox.shrink();

                            return ProductItemComponent(
                              isFavorite: product.isFavorite ?? false,
                              onPressed: () {
                                cubit?.getProductReview(
                                  productId: product.id.toString(),
                                );
                                Navigator.pushNamed(
                                  context,
                                  ScreenName.productDetailsScreen,
                                  arguments: product,
                                );
                              },
                              productDataModel: product,
                            );
                          },
                          separatorBuilder: (_, index) => const CustomSizedBox(),
                          itemCount: cubit?.searchedProductsList.length ?? 0,
                        ),
                ),
              ],
            );
          },
        ).symmetricPadding(horizontal: 16, vertical: 24),
      ),
    );
  }
}
