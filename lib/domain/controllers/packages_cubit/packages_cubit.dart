import 'package:an3am/core/network/error_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/services_locator.dart';
import '../../../data/datasources/remote_datasource/packages_remote_data_source.dart';
import '../../../data/models/packages_model/packages_model.dart';

part 'packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit() : super(PackagesInitial());

  static PackagesCubit get(context) => BlocProvider.of(context);
  final PackagesRemoteDataSource _packagesRemoteDataSource = sl();
  BaseErrorModel? baseErrorModel;
  List<MonthlyPackage>? monthlyPackage = [];

  void getAllPackages() async {
    emit(GetAllPackagesLoadingState());
    final response = await _packagesRemoteDataSource.getAllPackages();
    response.fold((l) {
      baseErrorModel = l.baseErrorModel;
      emit(GetAllPackagesErrorState(error: baseErrorModel?.message ?? ""));
    }, (r) {
      monthlyPackage = r.monthlyPackage;
      emit(GetAllPackagesSuccessState());
    });
  }

  void subscribeAPackage({
    required String? tranRef,
    required String? packageId,
  }) async {
    emit(SubscribePackageLoadingState());

    final response = await _packagesRemoteDataSource.subscribeAPackage(
      tranRef: tranRef,
      packageId: packageId,
    );
    response.fold((l) {
      baseErrorModel = l.baseErrorModel;
      emit(SubscribePackageErrorState(error: baseErrorModel?.message ?? ""));
    }, (r) {
      emit(SubscribePackageSuccessState());
    });
  }
}
