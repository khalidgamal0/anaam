import 'package:an3am/domain/controllers/map_cubit/service_map_cubit/service_map_cubit.dart';
import 'package:an3am/presentation/widgets/home_screen_widgets/categories_and_subcategories_tab_bars_widgets/categories_tab_bar_item_widget.dart';
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../domain/controllers/services_cubit/services_state.dart';
import 'categories_shimmer_effect.dart';

class ServicesCategoriesTabBarWidget extends StatefulWidget {
  const ServicesCategoriesTabBarWidget(
      {super.key, required this.isServicesFollowingTap, this.onCategorySelected, required this.isMap});

  final bool isServicesFollowingTap;
  final bool isMap;

  final Function(int)? onCategorySelected;

  @override
  State<ServicesCategoriesTabBarWidget> createState() =>
      _ServicesCategoriesTabBarWidgetState();
}

class _ServicesCategoriesTabBarWidgetState
    extends State<ServicesCategoriesTabBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesCubit, ServicesState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = ServicesCubit.get(context);
        return Container(
          height: 90.h,
          padding: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 4.r,
                offset: Offset(0, 4.h),
              )
            ],
          ),
          child: cubit.getAllServicesLoading
              ? const CategoriesShimmerEffectList()
              : BlocBuilder<ServiceMapCubit, ServiceMapState>(
                  builder: (context, state) {
                    var cubitServiceMapCubit = ServiceMapCubit.get(context);
                    return ListView.separated(
                      separatorBuilder: (_, index) => const CustomSizedBox(
                        width: 4,
                      ),
                      itemCount: cubit.allServicesList.length,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemBuilder: (BuildContext context, int index) {
                        return CategoriesTabBarItem(
                          onTap: () {
                            if(widget.isMap) {
                              cubitServiceMapCubit.getVisibleMarkers(context);
                            }
                            cubitServiceMapCubit.updateLocalProducts(
                              index == 0
                                  ? (widget.isServicesFollowingTap
                                      ? [
                                          ...cubit.userFollowingLaborersList,
                                          ...cubit.userFollowingVetList,
                                          ...cubit.userFollowingStoreList,
                                        ]
                                      : [
                                          ...cubit.laborersList,
                                          ...cubit.vetsList,
                                          ...cubit.storesList,
                                        ])
                                  : index == 1
                                      ? (widget.isServicesFollowingTap?cubit.userFollowingVetList:cubit.vetsList)
                                      : index == 2
                                          ? (widget.isServicesFollowingTap?cubit.userFollowingStoreList:cubit.storesList)
                                          : (widget.isServicesFollowingTap?cubit.userFollowingLaborersList:cubit.laborersList)

                            );

                            cubit.changeServicesCategoriesTabBarWidget(index);
                            widget.onCategorySelected?.call(index);

                          },
                          isSelected:
                              index == cubit.selectedServicesCategoryIndex,
                          imagePath: cubit.allServicesList[index].image!,
                          title: cubit.allServicesList[index].name!,
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
