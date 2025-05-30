import 'package:an3am/data/models/laborers_models/laborer_model.dart';
import 'package:an3am/data/models/stores_models/store_data_model.dart';
import 'package:an3am/data/models/vet_models/vet_model.dart';
import 'package:an3am/presentation/widgets/services_widgets/laborer_item_widget.dart';
import 'package:an3am/presentation/widgets/services_widgets/store_item_widget.dart';
import 'package:an3am/presentation/widgets/services_widgets/vet_services_item_widget.dart';
import 'package:an3am/presentation/widgets/services_widgets/services_type_list_widget/laborers_services_list_item.dart';
import 'package:an3am/presentation/widgets/services_widgets/services_type_list_widget/stores_services_list_component.dart';
import 'package:an3am/presentation/widgets/services_widgets/services_type_list_widget/vet_services_list_component.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/laborers_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/store_services_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/vet_service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Correct the import path for CustomSizedBox
import 'package:an3am/presentation/widgets/shared_widget/custom_sized_box.dart';

import '../../../core/enums/services_type_enum.dart';
import '../../../domain/controllers/main_layout_cubit/main_layout_cubit.dart';
import '../../../domain/controllers/main_layout_cubit/main_layout_state.dart';
import '../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../domain/controllers/services_cubit/services_state.dart';

class ServicesAllProductsList extends StatefulWidget {
  const ServicesAllProductsList({super.key});

  @override
  State<ServicesAllProductsList> createState() =>
      _ServicesAllProductsListState();
}

class _ServicesAllProductsListState extends State<ServicesAllProductsList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainLayoutCubit, MainLayoutState>(
      builder: (context, state) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.maxScrollExtent ==
                notification.metrics.pixels) {
              ServicesCubit.get(context).getAllVet();
              ServicesCubit.get(context).getAllLaborer();
              ServicesCubit.get(context).getAllStore();
            }
            return true;
          },
          child: BlocConsumer<ServicesCubit, ServicesState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              ServicesCubit cubit = ServicesCubit.get(context);
              return cubit.selectedServicesValue!.type ==
                      ServicesTypeEnum.veterinary.name
                  ? VetServicesList(
                      vetsList: (isFirstFetch)
                          ? cubit.vetsList
                          : cubit.vetsListFilterdMap,
                      isFollowing: false,
                    )
                  : cubit.selectedServicesValue!.type ==
                          ServicesTypeEnum.laborers.name
                      ? LaborersServicesList(
                          laborersList: isFirstFetch
                              ? cubit.laborersList
                              : cubit.laborersListFilterdMap,
                          isFollowing: false,
                        )
                      : cubit.selectedServicesValue!.type ==
                              "all" // All category condition
                          ? ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              separatorBuilder: (_, index) {
                                return const CustomSizedBox(
                                  height: 32,
                                );
                              },
                              itemCount: isFirstFetch
                                  ? cubit.vetsList.length +
                                      cubit.laborersList.length +
                                      cubit.storesList.length
                                  : [
                                      ...cubit.storesListFilterdMap,
                                      ...cubit.laborersListFilterdMap,
                                      ...cubit.vetsListFilterdMap
                                    ].length,
                              itemBuilder: (context, index) {
                                final allServices =
                                    // (cubit.vetsListFilterdMap.isNotEmpty ||
                                    //    cubit.laborersListFilterdMap.isNotEmpty ||
                                    //    cubit.storesListFilterdMap.isNotEmpty) ?
                                    //
                                    // [
                                    //   ...cubit.vetsListFilterdMap,
                                    //   ...cubit.laborersListFilterdMap,
                                    //   ...cubit.storesListFilterdMap,
                                    // ]:
                                    isFirstFetch
                                        ? [
                                            ...cubit.vetsList,
                                            ...cubit.laborersList,
                                            ...cubit.storesList,
                                          ]
                                        : [
                                            ...cubit.storesListFilterdMap,
                                            ...cubit.laborersListFilterdMap,
                                            ...cubit.vetsListFilterdMap
                                          ];
                                final service = allServices[index];

                                return InkWell(
                                  onTap: () {
                                    if (service is VetModel) {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return VetServiceDetailsScreen(
                                            vetModel: service);
                                      }));
                                    } else if (service is LaborerModel) {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return LaborersServiceDetailsScreen(
                                            laborerModel: service);
                                      }));
                                    } else if (service is StoreDataModel) {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return StoreServiceDetailsScreen(
                                            storeDataModel: service);
                                      }));
                                    }
                                  },
                                  child: service is VetModel
                                      ? VetServicesWidget(vetModel: service)
                                      : service is LaborerModel
                                          ? LaborerServicesWidget(
                                              laborerModel: service)
                                          : service is StoreDataModel
                                              ? StoreServicesWidget(
                                                  storeDataModel: service)
                                              : const SizedBox.shrink(),
                                );
                              },
                            )
                          : StoreServicesList(
                              storeList: isFirstFetch
                                  ? cubit.storesList
                                  : cubit.storesListFilterdMap,
                              isFollowing: false,
                            );
            },
          ),
        );
      },
    );
  }
}
