import 'dart:io';
import 'package:an3am/data/datasources/remote_datasource/multi_lang_remote_data_source.dart';
import 'package:an3am/data/datasources/remote_datasource/profile_remote_datasource.dart';
import 'package:an3am/data/models/laborers_models/laborers_multi_lang.dart';
import 'package:an3am/data/models/multi_lang_models/store_multi_lang_model.dart';
import 'package:an3am/data/models/multi_lang_models/veterian_multi_lang_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/error_message_model.dart';
import '../../../core/parameters/store_parameters.dart';
import '../../../core/services/services_locator.dart';
import '../../../data/models/categories/categories_model.dart';
import '../../../data/models/categories/show_category_model.dart';
import '../../../data/models/categories/sub_categories_model.dart';
import '../../../data/models/laborers_models/laborer_model.dart';
import '../../../core/parameters/laborer_parameters.dart';
import '../../../core/parameters/vet_parameters.dart';
import '../../../data/datasources/remote_datasource/categories_remote_datasource.dart';
import '../../../data/datasources/remote_datasource/cities_and_countries_remote_datasource.dart';
import '../../../data/datasources/remote_datasource/laborers_services_remote_datasource.dart';
import '../../../data/datasources/remote_datasource/services_remote_data_source.dart';
import '../../../data/datasources/remote_datasource/stores_services_datasource.dart';
import '../../../data/datasources/remote_datasource/vet_services_remote_datasource.dart';
import '../../../data/models/city_model/city_model.dart';
import '../../../data/models/multi_lang_models/image_multi_lang_model.dart';
import '../../../data/models/services/services_model.dart';
import '../../../data/models/stores_models/store_data_model.dart';
import '../../../data/models/vet_models/vet_model.dart';
import 'services_state.dart';
import 'package:an3am/data/models/country_model/country_model.dart';

bool isFirstFetch=true;
class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit() : super(ServicesInitial());

  static ServicesCubit get(context) => BlocProvider.of(context);

  final LaborersRemoteDatasource _laborerRemoteDatasource = sl();
  final MultiLangRemoteDataSource _multiLangRemoteDataSource = sl();
  final CitiesAndCountriesRemoteDatasource _citiesAndCountriesRemoteDatasource =
      sl();
  final VetServicesRemoteDatasource _vetServicesRemoteDatasource = sl();
  final StoresServicesRemoteDatasource _storesServicesRemoteDatasource = sl();
  final ServicesRemoteDataSource _servicesRemoteDataSource = sl();
  final CategoriesRemoteDatasource _categoriesRemoteDatasource = sl();
  final ProfileRemoteDatasource _profileRemoteDatasource = sl();

  BaseErrorModel? baseErrorModel;
  List<LaborerModel> laborersList = [];
  List<LaborerModel> laborersListFilterdMap = [];
  // List<LaborerModel> laborersList = [];
  List<LaborerModel> userFollowingLaborersList = [];
  LaborerModel? showLaborerModel;
  int allLaborerPageNumber = 1;
  int userFollowingLaborerPageNumber = 1;
  List<VetModel> vetsList = [];
  List<VetModel> vetsListFilterdMap = [];
  List<VetModel> userFollowingVetList = [];
  VetModel? showVetModel;
  int allVetPageNumber = 1;
  int allCategoriesPageNumber = 1;
  int userFollowingVetPageNumber = 1;
  List<StoreDataModel> storesList = [];
  List<StoreDataModel> storesListFilterdMap = [];
  List<StoreDataModel> userFollowingStoreList = [];
  StoreDataModel? showStoreModel;
  int allStorePageNumber = 1;
  int userFollowingStorePageNumber = 1;
  int allServicesPageNumber = 1;
  List<ServiceModel> allServicesList = [];
  List<CategoriesModel> categoriesList = [];
  List<CityModel> citiesList = [];
  List<CountryModel> countriesList = [];
  final TextEditingController laborerNameAr = TextEditingController();
  final TextEditingController vetNameAr = TextEditingController();
  final TextEditingController storeNameAr = TextEditingController();
  final TextEditingController nationalityAr = TextEditingController();
  final TextEditingController professionAr = TextEditingController();
  final TextEditingController laborerAddressAr = TextEditingController();
  final TextEditingController vetAddressAr = TextEditingController();
  final TextEditingController qualificationsAr = TextEditingController();
  final TextEditingController trunkTypeAr = TextEditingController();
  final TextEditingController laborerPhone = TextEditingController();
  final TextEditingController vetPhone = TextEditingController();
  final TextEditingController vetEmail = TextEditingController();
  final TextEditingController laborerEmail = TextEditingController();
  final TextEditingController storePhone = TextEditingController();
  final TextEditingController storeEmail = TextEditingController();
  String? mapLocation;
  String? mapCoordinates;
  File? laborerImage;
  File? vetImage;
  File? storeImage;

  Map<String, dynamic> followedVendors = {};
  final _picker = ImagePicker();

  Future<void> getImagePick() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      emit(GetPickedImageSuccessState(pickedImage: File(pickedFile.path)));
    } else {
      emit(GetPickedImageErrorState());
    }
  }

  List<File> storeImages = [];

  Future<void> getMultiImagePick() async {
    final pickedFile = await _picker.pickMultiImage();
    final List<File> storeImages = pickedFile.map((e) => File(e.path)).toList();
    this.storeImages = storeImages;
    emit(GetPickedMultiImageSuccessState());
  }

  void getLocation({
    required String locationName,
    required String coordinates,
  }) {
    mapLocation = locationName;
    mapCoordinates = coordinates;
    emit(GetLocationNameAndCoordinates());
  }

  /// --------------------------------------> Laborer Logic Methods <--------------------------------------

  LaborerModel? getLaborerById(int id) {
    try {
      return laborersList.firstWhere((laborer) => laborer.id == id);
    } catch (e) {
      return null;
    }
  }

  void getAllLaborer({
    String? mapIds,
  }) async {
    emit(GetAllLaborerLoadingState());

    bool hasMorePages = true;

    while (hasMorePages) {
      final response = await _laborerRemoteDatasource.getAll(
        pageNumber: allLaborerPageNumber,
        mapIds: mapIds,
      );

      final shouldBreak = response.fold(
            (l) {
          baseErrorModel = l.baseErrorModel;
          emit(GetAllLaborerErrorState(error: baseErrorModel?.message ?? ""));
          return true; // Stop the loop on error
        },
            (r) {
          final paginatedModel = r.storePaginatedModel;
          final currentPage = paginatedModel?.currentPage ?? 1;
          final lastPage = paginatedModel?.lastPage ?? 1;

          if (paginatedModel?.laborerList != null) {
            laborersList.addAll(paginatedModel!.laborerList!);
            for (var element in paginatedModel.laborerList!) {
              if (element.vendor?.isFollowed != null) {
                followedVendors.putIfAbsent(
                  element.vendor!.id.toString(),
                      () => element.vendor!.isFollowed,
                );
              }
            }
          }

          allLaborerPageNumber++;

          // Stop if last page reached
          if (currentPage >= lastPage) {
            hasMorePages = false;
          }

          return false;
        },
      );

      if (shouldBreak) break;

      // Wait 500 milliseconds before next request
      await Future.delayed(const Duration(milliseconds: 500));
    }

    emit(GetAllLaborerSuccessState());
  }


  void getUserFollowingLaborer() async {
    if (userFollowingLaborerPageNumber == 1) {
      emit(GetUserFollowingLaborerLoadingState());
    }

    final response = await _laborerRemoteDatasource.getUserFollowing(
      pageNumber: userFollowingLaborerPageNumber,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetUserFollowingLaborerErrorState(
            error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.storePaginatedModel?.laborerList == null ||
            r.storePaginatedModel!.laborerList!.isEmpty) {
          emit(GetUserFollowingLaborerSuccessState());
          return;
        }

        // تحديث followedVendors لكل العناصر المتابعة
        for (var laborer in r.storePaginatedModel!.laborerList!) {
          if (laborer.vendor != null) {
            followedVendors[laborer.vendor!.id.toString()] = true;
          }
        }

        userFollowingLaborersList.addAll(r.storePaginatedModel!.laborerList!);
        userFollowingLaborerPageNumber++;
        emit(GetUserFollowingLaborerSuccessState());
      },
    );
  }

  void showLaborerDetails({required int productId}) async {
    emit(ShowLaborerDetailsLoadingState());
    final response = await _laborerRemoteDatasource.showSingle(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(ShowLaborerDetailsErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        showLaborerModel = r;
        emit(ShowLaborerDetailsSuccessState());
      },
    );
  }

  LaborerMultiLangModel? laborerMultiLangModel;
  bool? getMultiLangLaborerLoading;

  void getMultiLangLaborer({required int id}) async {
    getMultiLangLaborerLoading = true;
    emit(ShowLaborerMultiLangLoadingState());
    final response =
        await _multiLangRemoteDataSource.getLaborerMultiLang(id: id);
    response.fold(
      (l) {
        getMultiLangLaborerLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(ShowLaborerMultiLangErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getMultiLangLaborerLoading = false;
        laborerMultiLangModel = r;
        emit(ShowLaborerMultiLangSuccessState());
      },
    );
  }

  VeterinarianMultiLangModel? veterinarianMultiLangModel;
  bool getMultiLangVetLoading = false;

  void getMultiLangVeterinarian({required int id}) async {
    getMultiLangVetLoading = true;
    emit(ShowVetMultiLangLoadingState());
    final response =
        await _multiLangRemoteDataSource.geVeterinarianMultiLang(id: id);
    response.fold(
      (l) {
        getMultiLangVetLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(ShowVetMultiLangErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getMultiLangVetLoading = false;
        veterinarianMultiLangModel = r;
        emit(ShowVetMultiLangSuccessState());
      },
    );
  }

  StoreMultiLangModel? storeMultiLangModel;
  bool getMultiLangStoreLoading = false;

  void getMultiLangStore({required int id}) async {
    getMultiLangStoreLoading = true;
    emit(ShowStoreMultiLangLoadingState());
    final response = await _multiLangRemoteDataSource.geStoreMultiLang(id: id);
    response.fold(
      (l) {
        getMultiLangStoreLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(ShowStoreMultiLangErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getMultiLangStoreLoading = false;
        storeMultiLangModel = r;
        emit(ShowStoreMultiLangSuccessState());
      },
    );
  }

  bool getAllCitiesLoading = false;

  void getAllCities() async {
    getAllCitiesLoading = true;
    emit(GetCitiesLoadingState());
    final response = await _citiesAndCountriesRemoteDatasource.getAllCities();
    response.fold(
      (l) {
        getAllCitiesLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(GetCitiesErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getAllCitiesLoading = false;
        citiesList = r.citiesList!;
        emit(GetCitiesSuccessState());
      },
    );
  }

  bool getAllCountriesLoading = false;

  void getAllCountries() async {
    getAllCountriesLoading = true;
    emit(GetCitiesLoadingState());
    final response =
        await _citiesAndCountriesRemoteDatasource.getAllCountries();
    response.fold(
      (l) {
        getAllCountriesLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(GetCitiesErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getAllCountriesLoading = false;
        countriesList = r.countriesList!;
        emit(GetCitiesSuccessState());
      },
    );
  }

  void deleteLaborer({required int productId}) async {
    emit(DeleteLaborerLoadingState());
    final response = await _laborerRemoteDatasource.delete(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(DeleteLaborerErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        emit(DeleteLaborerSuccessState(baseResponseModel: r));
      },
    );
  }

  void uploadLaborer({required LaborerParameters productParameters}) async {
    emit(UploadLaborerLoadingState());
    final response = await _laborerRemoteDatasource.upload(
      parameters: productParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        // emit(UploadLaborerErrorState(error: baseErrorModel?.errors?[0] ?? ""));
        emit(UploadLaborerErrorState(
            error:
                baseErrorModel?.errors?[0] ?? baseErrorModel?.message ?? ""));
      },
      (r) {
        emit(UploadLaborerSuccessState());
      },
    );
  }

  void updateLaborer({required LaborerParameters productParameters}) async {
    emit(UpdateLaborerLoadingState());
    final response = await _laborerRemoteDatasource.update(
      parameters: productParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UpdateLaborerErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        emit(UpdateLaborerSuccessState());
      },
    );
  }

  /// --------------------------------------> Vet Logic Methods <--------------------------------------

  VetModel? getVetById(int id) {
    try {
      return vetsList.firstWhere((vet) => vet.id == id);
    } catch (e) {
      return null;
    }
  }

  void getAllVet({String? mapIds}) async {
    emit(GetAllVetLoadingState());

    bool hasMorePages = true;

    while (hasMorePages) {
      final response = await _vetServicesRemoteDatasource.getAll(
        pageNumber: allVetPageNumber,
        mapIds: mapIds,
      );

      final shouldBreak = response.fold(
            (l) {
          baseErrorModel = l.baseErrorModel;
          emit(GetAllVetErrorState(error: baseErrorModel?.message ?? ""));
          return true; // Stop the loop on error
        },
            (r) {
          final paginatedModel = r.storePaginatedModel;
          final currentPage = paginatedModel?.currentPage ?? 1;
          final lastPage = paginatedModel?.lastPage ?? 1;

          if (paginatedModel?.vetList != null) {
            vetsList.addAll(paginatedModel!.vetList!);
            for (var element in paginatedModel.vetList!) {
              if (element.vendor?.isFollowed != null) {
                followedVendors.putIfAbsent(
                  element.vendor!.id.toString(),
                      () => element.vendor!.isFollowed,
                );
              }
            }
          }

          allVetPageNumber++;

          // Stop if last page is reached
          if (currentPage >= lastPage) {
            hasMorePages = false;
          }

          return false;
        },
      );

      if (shouldBreak) break;

      // Add a delay between each request (optional: adjust duration)
      await Future.delayed(const Duration(milliseconds: 500));
    }

    emit(GetAllVetSuccessState());
  }

  void getUserFollowingVet() async {
    if (userFollowingVetPageNumber == 1) {
      emit(GetUserFollowingVetLoadingState());
    }

    final response = await _vetServicesRemoteDatasource.getUserFollowing(
      pageNumber: userFollowingVetPageNumber,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetUserFollowingVetErrorState(
            error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.storePaginatedModel?.vetList == null ||
            r.storePaginatedModel!.vetList!.isEmpty) {
          emit(GetUserFollowingVetSuccessState());
          return;
        }

        // تحديث followedVendors لكل العناصر المتابعة
        for (var vet in r.storePaginatedModel!.vetList!) {
          if (vet.vendor != null) {
            followedVendors[vet.vendor!.id.toString()] = true;
          }
        }

        userFollowingVetList.addAll(r.storePaginatedModel!.vetList!);
        userFollowingVetPageNumber++;
        emit(GetUserFollowingVetSuccessState());
      },
    );
  }

  void showVetDetails({required int productId}) async {
    emit(ShowVetDetailsLoadingState());
    final response =
        await _vetServicesRemoteDatasource.showSingle(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(ShowVetDetailsErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        showVetModel = r;
        emit(ShowVetDetailsSuccessState());
      },
    );
  }

  void deleteVet({required int productId}) async {
    emit(DeleteVetLoadingState());
    final response = await _vetServicesRemoteDatasource.delete(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(DeleteVetErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        emit(DeleteVetSuccessState(baseResponseModel: r));
      },
    );
  }

  void uploadVet({required VetParameters vetParameters}) async {
    emit(UploadVetLoadingState());
    final response = await _vetServicesRemoteDatasource.upload(
      parameters: vetParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        // emit(UploadVetErrorState(error: baseErrorModel?.errors?[0] ?? ""));
        emit(UploadVetErrorState(
            error:
                baseErrorModel?.errors?[0] ?? baseErrorModel?.message ?? ""));
      },
      (r) {
        emit(UploadVetSuccessState());
      },
    );
  }

  void updateVet({required VetParameters vetParameters}) async {
    emit(UpdateVetLoadingState());
    final response = await _vetServicesRemoteDatasource.update(
      parameters: vetParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UpdateVetErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        emit(UpdateVetSuccessState());
      },
    );
  }

  /// --------------------------------------> Store Logic Methods <--------------------------------------

  StoreDataModel? getStoreById(int id) {
    try {
      return storesList.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  void getAllStore({
    String? mapIds,
  }) async {
    emit(GetAllStoreLoadingState());

    bool hasMorePages = true;

    while (hasMorePages) {
      final response = await _storesServicesRemoteDatasource.getAll(
        pageNumber: allStorePageNumber,
        mapIds: mapIds,
      );

      final shouldBreak = response.fold(
            (l) {
          baseErrorModel = l.baseErrorModel;
          emit(GetAllStoreErrorState(error: baseErrorModel?.message ?? ""));
          return true; // Stop the loop on error
        },
            (r) {
          final model = r.storePaginatedModel;

          if (model?.storeList == null || model!.storeList!.isEmpty) {
            hasMorePages = false;
            return false; // Don't break, just stop loop normally
          }

          final currentPage = model.currentPage ?? 1;
          final lastPage = model.lastPage ?? 1;

          if (allStorePageNumber <= lastPage && currentPage <= lastPage) {
            storesList.addAll(model.storeList!);
            for (var element in model.storeList!) {
              if (element.vendor?.isFollowed != null) {
                followedVendors[element.id.toString()] =
                    element.vendor!.isFollowed;
              }
            }
            allStorePageNumber++;

            // Check if we've reached the last page
            if (currentPage >= lastPage) {
              hasMorePages = false;
            }
          } else {
            hasMorePages = false;
          }

          return false;
        },
      );

      if (shouldBreak) break;

      // Wait 500ms before next request
      await Future.delayed(const Duration(milliseconds: 500));
    }

    emit(GetAllStoreSuccessState());
  }


  void getUserFollowingStore() async {
    if (userFollowingStorePageNumber == 1) {
      emit(GetUserFollowingStoreLoadingState());
    }

    final response = await _storesServicesRemoteDatasource.getUserFollowing(
      pageNumber: userFollowingStorePageNumber,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetUserFollowingStoreErrorState(
            error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.storePaginatedModel?.storeList == null ||
            r.storePaginatedModel!.storeList!.isEmpty) {
          emit(GetUserFollowingStoreSuccessState());
          return;
        }

        // تحديث followedVendors لكل العناصر المتابعة
        for (var store in r.storePaginatedModel!.storeList!) {
          if (store.vendor != null) {
            followedVendors[store.vendor!.id.toString()] = true;
          }
        }

        userFollowingStoreList.addAll(r.storePaginatedModel!.storeList!);
        userFollowingStorePageNumber++;
        emit(GetUserFollowingStoreSuccessState());
      },
    );
  }

  void showStoreDetails({required int productId}) async {
    emit(ShowStoreDetailsLoadingState());
    final response =
        await _storesServicesRemoteDatasource.showSingle(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(ShowStoreDetailsErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        showStoreModel = r;
        emit(ShowStoreDetailsSuccessState());
      },
    );
  }

  void followVendor({required int vendorId}) async {
    if (followedVendors[vendorId.toString()] ?? false) return;

    followedVendors[vendorId.toString()] = true;
    emit(FollowVendorLoadingState());

    final response = await _profileRemoteDatasource.followVendor(id: vendorId);

    response.fold(
      (l) {
        followedVendors[vendorId.toString()] = false;
        baseErrorModel = l.baseErrorModel;
        emit(FollowVendorErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        // Reset pages
        userFollowingVetPageNumber = 1;
        userFollowingLaborerPageNumber = 1;
        userFollowingStorePageNumber = 1;

        // Clear lists
        userFollowingVetList = [];
        userFollowingLaborersList = [];
        userFollowingStoreList = [];

        // Reload all following lists
        getUserFollowingVet();
        getUserFollowingLaborer();
        getUserFollowingStore();

        emit(FollowVendorSuccessState());
      },
    );
  }

  void unfollowVendor({required int vendorId}) async {
    if (!(followedVendors[vendorId.toString()] ?? false)) return;

    followedVendors[vendorId.toString()] = false;
    emit(UnfollowLoadingState());

    final response =
        await _profileRemoteDatasource.unfollowVendor(id: vendorId);

    response.fold(
      (l) {
        followedVendors[vendorId.toString()] = true;
        baseErrorModel = l.baseErrorModel;
        emit(UnfollowErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        // Reset pages
        userFollowingVetPageNumber = 1;
        userFollowingLaborerPageNumber = 1;
        userFollowingStorePageNumber = 1;

        // Clear lists
        userFollowingVetList = [];
        userFollowingLaborersList = [];
        userFollowingStoreList = [];

        // Reload all following lists
        getUserFollowingVet();
        getUserFollowingLaborer();
        getUserFollowingStore();

        emit(UnfollowSuccessState());
      },
    );
  }

  void deleteStore({required int productId}) async {
    emit(DeleteStoreLoadingState());
    final response =
        await _storesServicesRemoteDatasource.delete(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(DeleteStoreErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        emit(DeleteStoreSuccessState(baseResponseModel: r));
      },
    );
  }

  void uploadStore({required StoreParameters storeParameters}) async {
    emit(UploadStoreLoadingState());
    final response = await _storesServicesRemoteDatasource.upload(
      parameters: storeParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UploadStoreErrorState(
            error:
                baseErrorModel?.errors?[0] ?? baseErrorModel?.message ?? ""));
      },
      (r) {
        emit(UploadStoreSuccessState());
      },
    );
  }

  void updateStore({
    required StoreParameters vetParameters,
  }) async {
    emit(UpdateStoreLoadingState());
    final response = await _storesServicesRemoteDatasource.update(
      parameters: vetParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UpdateStoreErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        emit(UpdateStoreSuccessState());
      },
    );
  }

  bool getAllServicesLoading = false;
  ServiceModel? selectedServicesValue;
  Map<int, bool> favoriteServices = {};

  void toggleFavorite(int serviceId) {
    favoriteServices[serviceId] = !(favoriteServices[serviceId] ?? false);
    emit(ChangeFavoriteState());
  }

  void getAllServices() async {
    getAllServicesLoading = true;
    emit(GetAllServicesLoadingState());
    final response = await _servicesRemoteDataSource.getAllServices(
      pageNumber: allServicesPageNumber,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getAllServicesLoading = false;
        emit(GetAllServicesErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (allServicesPageNumber <= r.servicesPaginatedModel!.lastPage!) {
          if (r.servicesPaginatedModel!.currentPage! <=
              r.servicesPaginatedModel!.lastPage!) {
            allServicesList.addAll(r.servicesPaginatedModel!.allServicesList!
                .where((element) => element.type != null));
            allServicesPageNumber++;
          }
          getAllServicesLoading = false;
          selectedServicesValue = allServicesList[0];
          selectedServicesCategoryIndex = 0;
          for (var service in allServicesList) {
            favoriteServices[service.id!] = service.isFavorite ?? false;
          }
          emit(GetAllServicesSuccessState());
        }
      },
    );
  }

  void addNewCategory() {
    // Check if the "All" category already exists
    if (allServicesList.any((service) => service.type == "all")) {
      return; // Do not add the "All" category again
    }

    allServicesList.insert(
        0,
        ServiceModel(
          id: -1, // Unique ID for the new category
          name: "الكل", // Name of the new category
          type: "all", // Type identifier for the new category
          image: "https://ban3am.com/storage/initializing/all.png",
        ));
    emit(GetAllServicesSuccessState());
  }

  late int selectedServicesCategoryIndex;

  void changeServicesCategoriesTabBarWidget(
    int index,
  ) {
    if (index != selectedServicesCategoryIndex) {
      selectedServicesCategoryIndex = index;
      selectedServicesValue = allServicesList[selectedServicesCategoryIndex];
      emit(ChangeServicesCategoriesTabBarWidgetState());
    }
  }

  //  @override
  void clearFollowingLists() {
    userFollowingVetList = [];
    userFollowingLaborersList = [];
    userFollowingStoreList = [];
    userFollowingVetPageNumber = 1;
    userFollowingLaborerPageNumber = 1;
    userFollowingStorePageNumber = 1;
    emit(ClearFollowingListsState());
  }

  // @override
  void handleLogout() {
    userFollowingVetList = [];
    userFollowingLaborersList = [];
    userFollowingStoreList = [];
    storesList = [];
    vetsList = [];
    laborersList = [];
    emit(ServicesInitial());
  }

  bool getCategory = false;

  void showCategoryDetails({required int categoryId}) async {
    emit(ShowCategoryDetailsLoadingState());
    getCategory = true;
    final response = await _categoriesRemoteDatasource.showCategory(
      id: categoryId,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;

        getCategory = false;
        emit(ShowCategoryDetailsErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        showCategoryModel = r.showCategoryDataModel;

        getCategory = false;
        emit(ShowCategoryDetailsSuccessState());
      },
    );
  }

  ShowCategoryDataModel? showCategoryModel;

  bool getAllCategoriesLoading = false;

  void chooseCategory(CategoriesModel? value) {
    productCategory = value;
    showCategoryModel = null;
    showCategoryDetails(categoryId: productCategory!.id!);
    emit(ChangeCategoryState());
  }

  CityModel? chosenCity;
  List<MultiLangImageModel> storeUploadedImages = [];

  void chooseCity(CityModel? value) {
    chosenCity = value;
    emit(ChangeCategoryState());
  }

  CountryModel? chosenCountry;
  CountryModel? selectedPhoneCountry;

  void selectPhoneCountry(CountryModel? country) {
    selectedPhoneCountry = country;
    emit(ChangeCategoryState());
  }

  String getCountryCode() {
    return selectedPhoneCountry?.code ?? '';
  }

  SubCategoriesModel? productSubCategory;

  void chooseSubCategory(SubCategoriesModel? value) {
    productSubCategory = value;
    emit(ChangeCategoryState());
  }

  CategoriesModel? productCategory;

  void getAllCategories() async {
    getAllCategoriesLoading = true;
    emit(GetAllCategoriesLoadingState());
    final response = await _categoriesRemoteDatasource.getAllCategories(
      pageNumber: allCategoriesPageNumber,
    );
    response.fold(
      (l) {
        getAllCategoriesLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(GetAllCategoriesErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (allCategoriesPageNumber <=
            r.getPaginatedCategoriesResultModel!.lastPage!) {
          if (r.getPaginatedCategoriesResultModel!.currentPage! <=
              r.getPaginatedCategoriesResultModel!.lastPage!) {
            categoriesList
                .addAll(r.getPaginatedCategoriesResultModel!.categories!);
            allCategoriesPageNumber++;
          }
          getAllCategoriesLoading = false;
          emit(GetAllCategoriesSuccessState());
        }
      },
    );
  }

  @override
  Future<void> close() {
    laborerNameAr.dispose();
    storeNameAr.dispose();
    nationalityAr.dispose();
    professionAr.dispose();
    laborerAddressAr.dispose();
    laborerPhone.dispose();
    laborerEmail.dispose();
    storePhone.dispose();
    storeEmail.dispose();
    handleLogout();
    return super.close();
  }
}

class ChangeFavoriteState extends ServicesState {}

class ClearFollowingListsState extends ServicesState {}
