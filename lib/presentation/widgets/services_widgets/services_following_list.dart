import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:an3am/data/models/vet_models/vet_model.dart';
import 'package:an3am/data/models/laborers_models/laborer_model.dart';
import 'package:an3am/data/models/stores_models/store_data_model.dart';
import 'package:an3am/presentation/widgets/services_widgets/vet_services_item_widget.dart';
import 'package:an3am/presentation/widgets/services_widgets/laborer_item_widget.dart';
import 'package:an3am/presentation/widgets/services_widgets/store_item_widget.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/vet_service_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/laborers_details_screen.dart';
import 'package:an3am/presentation/screens/main_layout_screens/services_screens/store_services_details_screen.dart';
import '../../../domain/controllers/services_cubit/services_cubit.dart';
import '../../../domain/controllers/services_cubit/services_state.dart';
import 'services_type_list_widget/laborers_services_list_item.dart';
import 'services_type_list_widget/stores_services_list_component.dart';
import 'services_type_list_widget/vet_services_list_component.dart';

class ServicesFollowingList extends StatefulWidget {
  const ServicesFollowingList({super.key});

  @override
  State<ServicesFollowingList> createState() => _ServicesFollowingListState();
}

class _ServicesFollowingListState extends State<ServicesFollowingList> {
  final _vetListKey = GlobalKey();
  final _laborerListKey = GlobalKey();
  final _storeListKey = GlobalKey();
  final _allListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final cubit = ServicesCubit.get(context);
    cubit.getUserFollowingVet();
    cubit.getUserFollowingLaborer();
    cubit.getUserFollowingStore();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesCubit, ServicesState>(
      listener: (context, state) {},
      buildWhen: (previous, current) {
        return current is GetUserFollowingVetLoadingState ||
            current is GetUserFollowingVetSuccessState ||
            current is GetUserFollowingLaborerLoadingState ||
            current is GetUserFollowingLaborerSuccessState ||
            current is GetUserFollowingStoreLoadingState ||
            current is GetUserFollowingStoreSuccessState;
      },
      builder: (context, state) {
        final cubit = ServicesCubit.get(context);

        if (state is GetUserFollowingVetLoadingState ||
            state is GetUserFollowingLaborerLoadingState ||
            state is GetUserFollowingStoreLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        final noFollowing = cubit.userFollowingVetList.isEmpty &&
            cubit.userFollowingLaborersList.isEmpty &&
            cubit.userFollowingStoreList.isEmpty;

        if (noFollowing) {
          return const Center(
            child: Text(
              'لا يوجد عناصر في قائمة المتابعة',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        if (cubit.selectedServicesValue == null) {
          return const Center(child: Text('الرجاء اختيار نوع الخدمة'));
        }

        Widget content;

        switch (cubit.selectedServicesValue!.type) {
          case 'veterinary':
            content = VetServicesList(
              key: _vetListKey,
              vetsList: cubit.userFollowingVetList,
              isFollowing: true,
            );
            break;
          case 'laborers':
            content = LaborersServicesList(
              key: _laborerListKey,
              laborersList: cubit.userFollowingLaborersList,
              isFollowing: true,
            );
            break;
          case 'store':
          case 'livestock_transportation':
            content = StoreServicesList(
              key: _storeListKey,
              storeList: cubit.userFollowingStoreList,
              isFollowing: true,
            );
            break;
          case 'all':
            final allFollowed = [
              ...cubit.userFollowingVetList,
              ...cubit.userFollowingLaborersList,
              ...cubit.userFollowingStoreList,
            ];
            content = ListView.separated(
              key: _allListKey,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              separatorBuilder: (_, index) => const SizedBox(height: 32),
              itemCount: allFollowed.length,
              itemBuilder: (context, index) {
                final service = allFollowed[index];
                Widget serviceWidget;

                if (service is VetModel) {
                  serviceWidget = VetServicesWidget(vetModel: service);
                } else if (service is LaborerModel) {
                  serviceWidget = LaborerServicesWidget(laborerModel: service);
                } else if (service is StoreDataModel) {
                  serviceWidget = StoreServicesWidget(storeDataModel: service);
                } else {
                  return const SizedBox.shrink();
                }

                return InkWell(
                  onTap: () {
                    if (service is VetModel) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VetServiceDetailsScreen(vetModel: service),
                        ),
                      );
                    } else if (service is LaborerModel) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LaborersServiceDetailsScreen(
                              laborerModel: service),
                        ),
                      );
                    } else if (service is StoreDataModel) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreServiceDetailsScreen(
                              storeDataModel: service),
                        ),
                      );
                    }
                  },
                  child: serviceWidget,
                );
              },
            );
            break;
          default:
            content = const SizedBox.shrink();
        }

        return content;
      },
    );
  }
}
