import 'dart:developer';

import 'package:an3am/core/constants/extensions.dart';
import 'package:an3am/domain/controllers/products_cubit/products_cubit.dart';
import 'package:an3am/presentation/widgets/home_screen_widgets/search_bar_and_services_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache_helper/cache_keys.dart';
import '../../../../core/cache_helper/shared_pref_methods.dart';
import '../../../../domain/controllers/map_cubit/service_map_cubit/service_map_cubit.dart';
import '../../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../../domain/controllers/services_cubit/services_state.dart';
import '../../../widgets/home_screen_widgets/all_products_list_view_widget.dart';
import '../../../widgets/home_screen_widgets/categories_and_subcategories_tab_bars_widgets/product_categories_tab_bar_widget.dart';
import '../../../widgets/home_screen_widgets/following_and_followers_tab_bar.dart';
import '../../../widgets/home_screen_widgets/products_following_list_view_widget.dart';
import '../../../widgets/home_screen_widgets/services_categories_tab_bar.dart';
import '../../../widgets/home_screen_widgets/show_map_button.dart';
import '../../../widgets/home_screen_widgets/tab_bar_widget.dart';
import '../../../widgets/maps_widgets/home_google_map_view.dart';
import '../../../widgets/maps_widgets/service_map_widget.dart';
import '../../../widgets/services_widgets/services_all_products_list.dart';
import '../../../widgets/services_widgets/services_following_list.dart';
import '../../../widgets/shared_widget/custom_sized_box.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:an3am/domain/controllers/profile_cubit/profile_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _itemsTypeTabController;
  late TabController _followersTabController;
  late TabController _followersServicesTabController;
  late AnimationController expandController;
  late Animation<double> animation;
  int servicseSelectedIndex = 0;
  ProductsCubit? cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<ProductsCubit>();
    ServicesCubit.get(context).addNewCategory(); // Add the new category
    _itemsTypeTabController = TabController(
      length: 2,
      vsync: this,
    );
    _followersTabController = TabController(
      length: CacheHelper.getData(key: CacheKeys.token) != null ? 2 : 1,
      vsync: this,
    );
    _followersServicesTabController = TabController(
      length: CacheHelper.getData(key: CacheKeys.token) != null
          ? isMap
              ? 1
              : 2
          : 1,
      vsync: this,
    );

    prepareAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      expandController.forward();
    });

    if (CacheHelper.getData(key: CacheKeys.userType) != null) {
      ProductsCubit.get(context).userFollowingProductsPageNumber = 1;
      ProductsCubit.get(context).getUserFollowingProducts();
    }
    ProductsCubit.get(context).allProductsPageNumber = 1;
    ProductsCubit.get(context).getAllProducts();

    var cubit_ProfileCubit = ProfileCubit.get(context);
    if (cubit_ProfileCubit.profileModel != null &&
        CacheHelper.getData(key: CacheKeys.token) != null) {
      cubit_ProfileCubit.firstNameController.text =
          cubit_ProfileCubit.profileModel!.firstName ?? "";
      cubit_ProfileCubit.secondNameController.text =
          cubit_ProfileCubit.profileModel!.lastName ?? "";
      cubit_ProfileCubit.emailController.text =
          cubit_ProfileCubit.profileModel!.email ?? "";
      cubit_ProfileCubit.phoneController.text =
          cubit_ProfileCubit.profileModel!.phone ?? "";
    }
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _itemsTypeTabController.dispose();
    _followersTabController.dispose();
    _followersServicesTabController.dispose();
    expandController.dispose();
    super.dispose();
  }

  bool isMap = false;
  bool appearMapButton = true;
  bool isFollowingTap = false;
  bool isServicesFollowingTap = false;

  String visibleProductIds = ''; // Store visible IDs

  void updateVisibleProductIds(String ids) {
    setState(() {
      visibleProductIds = ids;
    });
    if (isMap && visibleProductIds.isNotEmpty) {
      ProductsCubit.get(context).allProductsPageNumber = 1;
      ProductsCubit.get(context).productsList.clear();
      ProductsCubit.get(context)
          .getAllProducts(mapids: visibleProductIds); // Use dynamic IDs
      setState(() {});
    }
  }

  // String? mapServiceIds;

  void updateVisibleService() {

    ServicesCubit.get(context).allLaborerPageNumber = 1;
    ServicesCubit.get(context).allStorePageNumber = 1;
    ServicesCubit.get(context).allVetPageNumber = 1;
    ServicesCubit.get(context).laborersList.clear();
    ServicesCubit.get(context).storesList.clear();
    ServicesCubit.get(context).vetsList.clear();
    setState(() {});

    ServicesCubit.get(context).getAllLaborer();
    ServicesCubit.get(context).getAllStore();
    ServicesCubit.get(context).getAllVet();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var cubit_ProfileCubit = ProfileCubit.get(context);
    final token = CacheHelper.getData(key: CacheKeys.token);
    var cubitServicesCubit = context.read<ServicesCubit>();

    return BlocProvider(
      create: (context) => ServiceMapCubit()
        ..updateLocalProducts([
          ...cubitServicesCubit.laborersList,
          ...cubitServicesCubit.vetsList,
          ...cubitServicesCubit.storesList,
        ]),
  child: Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, isScrolled) => [
            SliverToBoxAdapter(
              child: HomeTabBarWidget(
                tabController: _itemsTypeTabController,
                onTap: (index) {
                  setState(() {
                    isMap = false;
                  });
                  // if (index == 0) {
                  //   // Show map button when on the first tab  (products)
                  //   setState(() {
                  //     appearMapButton = true;
                  //   });
                  // } else {
                  //   // Show map button when on the second tab (services)
                  //   // setState(() {
                  //   //   appearMapButton = true;
                  //   // });
                  //   // Hide map button when on the second tab (services)
                  //   setState(() {
                  //     appearMapButton = false;
                  //   });
                  // }
                },
              ).onlyDirectionalPadding(
                start: 16,
                end: 16,
                top: 16,
              ),
            ),
            SliverToBoxAdapter(
              child: SearchBarAndServicesButtonsWidget(
                  mapButton: appearMapButton),
            )
          ],
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _itemsTypeTabController,
                children: [
                  Column(
                    children: [
                      SizeTransition(
                        axisAlignment: 1.0,
                        sizeFactor: animation,
                        child: const Column(
                          children: [
                            ProductCategoriesTabBarWidget(),
                          ],
                        ),
                      ),
                      FollowingAndFollowersTabBar(
                        tabController: _followersTabController,
                        onTap: (index) {
                          if (token != null) {
                            if (index == 0) {
                              isFollowingTap = false;
                              expandController.forward();
                            } else {
                              isFollowingTap = true;
                              expandController.reverse();
                            }
                            setState(() {});
                          }
                        },
                      ),
                      const CustomSizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: isMap
                            ? HomeGoogleMapsView(
                                productsList: ProductsCubit.get(context)
                                    .getFilteredProducts(),
                                onVisibleIdsChanged:
                                    updateVisibleProductIds, // Pass callback
                              )
                            : isFollowingTap &&
                                    CacheHelper.getData(
                                            key: CacheKeys.userType) !=
                                        null
                                ? ProductsFollowingListViewWidget(
                                    isGetAll: isFollowingTap,
                                  )
                                : AllProductsListViewWidget(
                                    isGetAll: !isFollowingTap,
                                  ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      if (!isServicesFollowingTap)
                        ServicesCategoriesTabBarWidget(
                            isServicesFollowingTap: isServicesFollowingTap,isMap: isMap,),
                      FollowingAndFollowersTabBar(
                        tabController: _followersServicesTabController,
                        onTap: (index) {
                          if (index == 0) {
                            isServicesFollowingTap = false;
                          } else {
                            isServicesFollowingTap = true;
                          }
                          setState(() {});
                        },
                      ),
                      const CustomSizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: BlocConsumer<ServicesCubit, ServicesState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            var cubit = ServicesCubit.get(context);
                            return TabBarView(
                              controller: _followersServicesTabController,
                              physics:
                                  CacheHelper.getData(key: CacheKeys.token) !=
                                          null
                                      ? const AlwaysScrollableScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                              children: [
                                // First tab content
                                isMap
                                    ? ServiceMapWidget(
                                       )
                                    : (cubit.selectedServicesValue != null
                                        ? ServicesAllProductsList()
                                        : const Center(
                                            child: CircularProgressIndicator
                                                .adaptive())),

                                // Second tab content (Following tab)
                                if (CacheHelper.getData(
                                        key: CacheKeys.token) !=
                                    null)
                                  isMap
                                      ? ServiceMapWidget()
                                      : ServicesFollowingList(),
                                if (CacheHelper.getData(
                                        key: CacheKeys.token) ==
                                    null)
                                  Container(),

                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Visibility(
                child: ShowMapButton(
                  isMap: isMap,
                  onPressed: () async {
                    setState(() {
                      isMap = !isMap;
                    });
                    // Initial fetch when switching to map view

                    if (!isMap) {
                      ProductsCubit.get(context).allProductsPageNumber = 1;
                      ProductsCubit.get(context).productsList.clear();
                      ProductsCubit.get(context).getAllProducts(
                          mapids: visibleProductIds.isEmpty
                              ? null
                              : visibleProductIds);
                      // updateVisibleService(mapServiceIds);
                    } else {
                      {
                        ProductsCubit.get(context).allProductsPageNumber =
                            1;
                        ProductsCubit.get(context).productsList.clear();
                        ProductsCubit.get(context).getAllProducts();
                      }
                      updateVisibleService();
                      ServiceMapCubit()
                        .updateLocalProducts([
                          ...cubitServicesCubit.laborersList,
                          ...cubitServicesCubit.vetsList,
                          ...cubitServicesCubit.storesList,
                        ]);
                    }

                    setState(() {});
                  },
                ).onlyDirectionalPadding(bottom: 22),
                visible: appearMapButton,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned(
            bottom: 5,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text("الدردشة المباشرة")),
                      body: Tawk(
                        directChatLink:
                            'https://tawk.to/chat/67db39bce170cd190fa578b2/1imo5j2rt',
                        visitor: (cubit_ProfileCubit.profileModel != null &&
                                CacheHelper.getData(key: CacheKeys.token) !=
                                    null)
                            ? TawkVisitor(
                                name:
                                    '${cubit_ProfileCubit.firstNameController.text} ${cubit_ProfileCubit.secondNameController.text}',
                                email: cubit_ProfileCubit.emailController.text,
                              )
                            : null,
                        onLoad: () {
                          // print('Tawk Loaded!');
                        },
                        onLinkTap: (String url) {
                          // print(url);
                        },
                        placeholder: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Icon(Icons.chat, color: Colors.white),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    ),
);
  }
}
