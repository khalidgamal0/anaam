import 'dart:io';
import 'dart:convert';

import 'package:an3am/core/network/error_message_model.dart';
import 'package:an3am/core/parameters/review_product_parameters.dart';
import 'package:an3am/core/parameters/upload_product_parameters.dart';
import 'package:an3am/data/datasources/remote_datasource/categories_remote_datasource.dart';
import 'package:an3am/data/datasources/remote_datasource/multi_lang_remote_data_source.dart';
import 'package:an3am/data/datasources/remote_datasource/products_remote_datasource.dart';
import 'package:an3am/data/models/base_model.dart';
import 'package:an3am/data/models/categories/categories_model.dart';
import 'package:an3am/data/models/categories/show_category_model.dart';
import 'package:an3am/data/models/multi_lang_models/product_multi_lang_model.dart';
import 'package:an3am/data/models/reviews_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/services_locator.dart';
import '../../../data/datasources/remote_datasource/profile_remote_datasource.dart';
import '../../../data/models/categories/sub_categories_model.dart';
import '../../../data/models/products_model/product_model.dart';
import '../../../data/models/vendor_data_model.dart';
import 'products_state.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';
import '../map_cubit/map_cubit.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  static ProductsCubit get(context) => BlocProvider.of<ProductsCubit>(context);

  // الحصول على المنتجات المفلترة حسب التصنيف المحدد
  List<ProductDataModel> getFilteredProducts() {
    if (selectedCategoryIndex == null) {
      return productsList;
    } else {
      final selectedCategory = categoriesList[selectedCategoryIndex!];
      return productsList
          .where((product) => product.category?.id == selectedCategory.id)
          .toList();
    }
  }

  final CategoriesRemoteDatasource _categoriesRemoteDatasource = sl();
  final ProductsRemoteDatasource _productsRemoteDatasource = sl();
  final ProfileRemoteDatasource _profileRemoteDatasource = sl();
  final MultiLangRemoteDataSource _multiLangRemoteDataSource = sl();
  BaseErrorModel? baseErrorModel;
  ProductDataModel? showProductDetailsModel;
  ShowCategoryDataModel? showCategoryModel;
  List<ReviewModel> reviewsList = [];
  List<ProductDataModel> productsList = [];
  List<ProductDataModel> searchedProductsList = [];
  List<ProductDataModel> favoriteProductsList = [];
  List<ProductDataModel> userFollowingProductsList = [];
  List<CategoriesModel> categoriesList = [];
  int allProductsPageNumber = 1;
  int allSearchedProductsPageNumber = 1;
  int allFavoriteProductsPageNumber = 1;
  int allCategoriesPageNumber = 1;
  int userFollowingProductsPageNumber = 1;
  VendorProfileModel? vendorProfileModel;
  bool getAllProductsLoading = false;
  Map<String, dynamic> vendorProducts =
      {}; // Keep as dynamic since it might have mixed types
  Map<String, bool> followedVendors = {}; // This should be non-nullable bool
  Map<String, bool> favoriteProduct = {}; // This should be non-nullable bool
  ImagePicker picker = ImagePicker();
  String? mapLocation;
  String? mapCoordinates;

  List<ProductDataModel> mapProductsList = [];
  int mapProductsPageNumber = 1;
  bool isLastMapPage = false;

  // مفاتيح التخزين المؤقت
  static const String mapProductsCacheKey = 'map_products_cache';
  static const String mapProductsPaginationKey = 'map_products_pagination';

  final TextEditingController addProductReviewName = TextEditingController();
  final TextEditingController addProductReviewEmail = TextEditingController();
  final TextEditingController addProductReviewDescription =
      TextEditingController();
  final TextEditingController addProductReviewAge = TextEditingController();
  final TextEditingController addProductReviewLocation =
      TextEditingController();
  final TextEditingController productNameAr = TextEditingController();
  final TextEditingController locationAr = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productDescriptionAr = TextEditingController();
  final TextEditingController productProsAr = TextEditingController();
  final TextEditingController productConsAr = TextEditingController();
  final TextEditingController youtubeLink = TextEditingController();
  final TextEditingController searchValue = TextEditingController();
  final TextEditingController productCurrency = TextEditingController();
  final TextEditingController tags = TextEditingController();
  final TextEditingController priceType = TextEditingController();
  final TextEditingController countryId = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController phoneCode = TextEditingController();
  int addProductReviewRate = 0;

  List<File> productImages = [];
  File? coverImage; // new cover image variable

  Future<void> getImagePick() async {
    final pickedFile = await picker.pickMultiImage();
    final List<File> productImages =
        pickedFile.map((e) => File(e.path)).toList();
    this.productImages = productImages;
    emit(GetPickedImageSuccessState());
  }

  Future<void> getCoverImagePick() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      emit(GetPickedImageSuccessState());
    }
  }

  void changeProductReviewRate(double value) {
    addProductReviewRate = value.round();
    emit(ChangeProductReviewRate());
  }

  Future<void> loadCachedMapProducts() async {
    try {
      // قراءة معلومات الصفحات
      final String? paginationData =
          CacheHelper.getData(key: mapProductsPaginationKey);
      if (paginationData != null) {
        final Map<String, dynamic> pagination = json.decode(paginationData);
        mapProductsPageNumber = pagination['currentPage'] ?? 1;
        isLastMapPage = pagination['isLastPage'] ?? false;
      }

      // قراءة بيانات المنتجات
      final String? productsData =
          CacheHelper.getData(key: mapProductsCacheKey);
      if (productsData != null) {
        final List<dynamic> productsJson = json.decode(productsData);
        mapProductsList = productsJson
            .map((json) => ProductDataModel.fromJson(json))
            .toList();

        emit(GetMapProductsSuccessState());
      }
    } catch (e) {
      // في حالة الخطأ، نستمر بدون استخدام الكاش
      mapProductsPageNumber = 1;
      isLastMapPage = false;
      mapProductsList = [];
    }
  }

  Future<void> _cacheMapProducts() async {
    try {
      // حفظ معلومات الصفحات
      final Map<String, dynamic> pagination = {
        'currentPage': mapProductsPageNumber,
        'isLastPage': isLastMapPage,
      };
      await CacheHelper.saveData(
        key: mapProductsPaginationKey,
        value: json.encode(pagination),
      );

      // حفظ المنتجات
      final List<Map<String, dynamic>> productsJson =
          mapProductsList.map((product) => product.toJson()).toList();
      await CacheHelper.saveData(
        key: mapProductsCacheKey,
        value: json.encode(productsJson),
      );
    } catch (e) {
      // تجاهل أخطاء التخزين المؤقت
    }
  }



  Future<void> clearMapCacheAndReset() async {
    mapProductsList.clear();
    resetMapProductsPagination(); // Resets page number and isLastMapPage
    await CacheHelper.removeData(key: mapProductsCacheKey);
    await CacheHelper.removeData(key: mapProductsPaginationKey);
    // Emit a state if needed, e.g., emit(MapCacheClearedState()); 
    // For now, we'll rely on the subsequent loading states from loadFreshProducts.
    print("Map cache cleared and pagination reset.");
  }

  // إعادة تعيين قائمة المنتجات للقائمة الكاملة عند إلغاء تحديد التصنيف
  void resetProductsList() {
    // إعادة تعيين حالة التصنيف
    selectedCategoryIndex = null;
    selectedSubCategoryIndex = null;
    showCategoryModel = null;
    getCategory = false;
    
    // إعادة تعيين قائمة المنتجات
    allProductsPageNumber = 1;
    productsList.clear();
    emit(GetAllProductsLoadingState());
    getAllProducts(); // جلب كل المنتجات بدون تصنيف
  }

  Future<void> getProductsForMap() async {
    // إذا وصلنا لآخر صفحة، نخرج من الدالة مباشرة
    if (isLastMapPage) {
      emit(GetMapProductsSuccessState());
      return;
    }

    if (mapProductsPageNumber == 1) {
      emit(GetMapProductsLoadingState());
    }
    final response = await _productsRemoteDatasource.getAllProducts(
      pageNumber: mapProductsPageNumber,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetMapProductsErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.getPaginatedProductResultModel != null) {
          final currentPage =
              r.getPaginatedProductResultModel!.currentPage ?? 1;
          final lastPage = r.getPaginatedProductResultModel!.lastPage ?? 1;

          // تحديث حالة الوصول لآخر صفحة
          isLastMapPage = currentPage >= lastPage;

          if (mapProductsPageNumber <= lastPage) {
            // تصفية المنتجات: في المخزون + معتمدة فقط
            (r.getPaginatedProductResultModel?.products ?? [])
                .where((element) =>
                    element.inStock == true && element.isApproved == true)
                .forEach((element) {
              if (!mapProductsList.any((e) => e.id == element.id)) {
                mapProductsList.add(element);
                mapProductsList[
                        mapProductsList.indexWhere((e) => element.id == e.id)]
                    .images
                    ?.insert(0, Images(image: element.mainImage));
              }
            });

            // زيادة رقم الصفحة فقط إذا لم نصل لآخر صفحة بعد
            if (!isLastMapPage) {
              mapProductsPageNumber++;
            }

            // حفظ البيانات في الكاش بعد كل تحميل ناجح
            _cacheMapProducts();
          }
          emit(GetMapProductsSuccessState());
        } else {
          emit(GetMapProductsSuccessState());
        }
      },
    );
  }

  // دالة للتحقق من إمكانية تحميل المزيد من المنتجات على الخريطة
  bool canLoadMoreMapProducts() {
    if (baseErrorModel != null) return false;
    return !isLastMapPage;
  }

  // إعادة ضبط حالة منتجات الخريطة
  void resetMapProductsPagination() {
    mapProductsPageNumber = 1;
    isLastMapPage = false;
    mapProductsList.clear();

    // مسح الكاش
    CacheHelper.removeData(key: mapProductsCacheKey);
    CacheHelper.removeData(key: mapProductsPaginationKey);
  }

  void getAllProducts({
    String? mapids,
  }) async {
    if (allProductsPageNumber == 1) {
      getAllProductsLoading = true;
      productsList.clear(); // مسح القائمة عند بدء التحميل من الصفحة الأولى
      emit(GetAllProductsLoadingState());
    }
    final response = await _productsRemoteDatasource.getAllProducts(
      pageNumber: allProductsPageNumber,
      mapids: mapids,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getAllProductsLoading = false;
        emit(GetAllProductsErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (allProductsPageNumber <=
            r.getPaginatedProductResultModel!.lastPage!) {
          if (r.getPaginatedProductResultModel!.currentPage! <=
              r.getPaginatedProductResultModel!.lastPage!) {
            if ((r.getPaginatedProductResultModel?.products ?? []).isNotEmpty) {
              (r.getPaginatedProductResultModel?.products ?? [])
                  .where((element) =>
                      element.inStock == true && element.isApproved == true)
                  .forEach((element) {
                if (!productsList.any((e) => e.id == element.id)) {
                  productsList.add(element);
                  productsList[
                          productsList.indexWhere((e) => element.id == e.id)]
                      .images
                      ?.insert(0, Images(image: element.mainImage));
                }
              });
              for (var element in productsList) {
                if (element.uploadedBy?.isFollowed != null) {
                  if (!followedVendors
                      .containsKey((element.id ?? 0).toString())) {
                    followedVendors[(element.uploadedBy?.id ?? 0).toString()] =
                        element.uploadedBy!.isFollowed ?? false;
                  }
                }
                if (element.isFavorite != null) {
                  if (!favoriteProduct.containsKey(element.id!.toString())) {
                    favoriteProduct[element.id.toString()] =
                        element.isFavorite ?? false;
                  }
                }
              }
              for (var element in productsList) {
                if (element.isFavorite != null) {
                  favoriteProduct[element.id.toString()] = element.isFavorite!;
                }
              }
              allProductsPageNumber++;
            }
          }
          getAllProductsLoading = false;
          emit(GetAllProductsSuccessState());
        }
      },
    );
  }

  bool getSearchedProductsLoading = false;

  void getAllSearchedProducts({
    String? value,
    int? categoryId,
  }) async {
    // 🔄 إعادة تعيين الصفحة عند تنفيذ بحث جديد
    if (allSearchedProductsPageNumber == 1) {
      getSearchedProductsLoading = true;
      searchedProductsList.clear(); // ✅ تفريغ القائمة لبدء البحث الجديد
      emit(GetAllProductsLoadingState());
    }

    final response = await _productsRemoteDatasource.getAllSearchedProducts(
      pageNumber: allSearchedProductsPageNumber,
      value: value ?? searchValue.text,
      categoryId: categoryId,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getSearchedProductsLoading = false;
        emit(GetAllProductsErrorState(error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.getPaginatedProductResultModel != null &&
            allSearchedProductsPageNumber <=
                r.getPaginatedProductResultModel!.lastPage!) {
          if (r.getPaginatedProductResultModel!.products!.isNotEmpty) {
            // ✅ إعادة تعيين القائمة عند البحث الجديد
            if (allSearchedProductsPageNumber == 1) {
              searchedProductsList.clear();
            }

            (r.getPaginatedProductResultModel!.products ?? [])
                .where((element) =>
                    element.inStock == true && element.isApproved == true)
                .forEach((element) {
              if (!searchedProductsList.any((e) => e.id == element.id)) {
                searchedProductsList.add(element);
                searchedProductsList[searchedProductsList
                        .indexWhere((e) => element.id == e.id)]
                    .images
                    ?.insert(0, Images(image: element.mainImage));
              }
            });

            allSearchedProductsPageNumber++; // 🔄 تحديث الصفحة فقط عند استلام بيانات جديدة
          }

          getSearchedProductsLoading = false;
          emit(
              GetAllProductsSuccessState()); // ✅ إجبار الواجهة على إعادة التحديث
        }
      },
    );
  }

  void getLocation({
    required String locationName,
    required String coordinates,
  }) {
    mapLocation = locationName;
    mapCoordinates = coordinates;
    emit(GetLocationNameAndCoordinates());
  }

  void getFavoriteProducts() async {
    favoriteProductsList.clear();
    allFavoriteProductsPageNumber = 1;
    emit(GetFavoriteProductsLoadingState());

    final response = await _productsRemoteDatasource.getFavoriteProducts(
      pageNumber: allFavoriteProductsPageNumber,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(GetFavoriteProductsErrorState(
            error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (r.getPaginatedProductResultModel?.products?.isNotEmpty ?? false) {
          // تحديث قائمة المنتجات المفضلة
          final newProducts = r.getPaginatedProductResultModel!.products!.where(
              (element) =>
                  element.inStock == true && element.isApproved == true);

          for (var product in newProducts) {
            // إضافة المنتج للقائمة
            favoriteProductsList.add(product);

            // تحديث حالة المفضلة
            favoriteProduct[product.id.toString()] = true;

            // إضافة الصورة الرئيسية
            product.images?.insert(0, Images(image: product.mainImage));

            // تحديث حالة متابعة البائع إذا وجدت
            if (product.uploadedBy?.isFollowed != null) {
              followedVendors[product.uploadedBy!.id.toString()] =
                  product.uploadedBy!.isFollowed!;
            }
          }

          allFavoriteProductsPageNumber++;
          emit(GetFavoriteProductsSuccessState());
        } else {
          emit(GetFavoriteProductsSuccessState());
        }
      },
    );
  }

  bool getUserFollowingList = false;

  void getUserFollowingProducts() async {
    if (userFollowingProductsPageNumber == 1) {
      getUserFollowingList = true;
      emit(GetUserFollowingProductsLoadingState());
    }

    final response = await _productsRemoteDatasource.getUserFollowingProducts(
      pageNumber: userFollowingProductsPageNumber,
    );

    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        getUserFollowingList = false;
        emit(GetUserFollowingProductsErrorState(
            error: baseErrorModel?.message ?? ""));
      },
      (r) {
        if (userFollowingProductsPageNumber <=
            r.getPaginatedProductResultModel!.lastPage!) {
          if (r.getPaginatedProductResultModel!.currentPage! <=
              r.getPaginatedProductResultModel!.lastPage!) {
            final newProducts =
                (r.getPaginatedProductResultModel!.products ?? [])
                    .where((element) =>
                        element.inStock == true && element.isApproved == true)
                    .toList();

            for (var element in newProducts) {
              if (!userFollowingProductsList.any((e) => e.id == element.id)) {
                element.images?.insert(0, Images(image: element.mainImage));
                userFollowingProductsList.add(element);
              }
            }

            for (var element in userFollowingProductsList) {
              if (element.uploadedBy?.isFollowed != null) {
                followedVendors[element.uploadedBy!.id.toString()] =
                    element.uploadedBy!.isFollowed!;
              }
              if (element.isFavorite != null) {
                favoriteProduct[element.id.toString()] = element.isFavorite!;
              }
            }

            // ✅ زيادة رقم الصفحة فقط عند وجود بيانات جديدة
            if (newProducts.isNotEmpty) {
              userFollowingProductsPageNumber++;
            }
          }

          getUserFollowingList = false;
          emit(GetUserFollowingProductsSuccessState());
        }
      },
    );
  }

  void showProductDetails({required int productId}) async {
    emit(ShowProductDetailsLoadingState());
    final response = await _productsRemoteDatasource.showProduct(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(ShowProductDetailsErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        showProductDetailsModel = r;
        if (showProductDetailsModel != null &&
            showProductDetailsModel!.isFavorite != null) {
          favoriteProduct[productId.toString()] =
              showProductDetailsModel!.isFavorite!;
        }
        emit(ShowProductDetailsSuccessState());
      },
    );
  }

  BaseResponseModel? productStatusModel;

  void changeProductStatus({
    required int productId,
    required String status,
    required bool productStatus,
  }) async {
    final oldStatus = vendorProducts[productId.toString()] ?? false;

    vendorProducts[productId.toString()] = productStatus;
    emit(ChangeProductStatusLoadingState());

    final response = await _productsRemoteDatasource.changeProductStatus(
      id: productId,
      status: status,
      productStatus: productStatus, // إضافة هذا المتغير للطلب
    );

    response.fold(
      (l) {
        // في حالة الخطأ نرجع للحالة القديمة
        vendorProducts[productId.toString()] = oldStatus;
        baseErrorModel = l.baseErrorModel;
        emit(ChangeProductStatusErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) {
        // تحديث الواجهة
        emit(ChangeProductStatusSuccessState());
      },
    );
  }

  // void addServicesProviderToFavorite({required int id}) async {
  //   favorites[id] = !favorites[id]!;
  //   emit(AddServiceToFavLoading());
  //   final response =
  //   await ServicesProvidersRepository.addServiceToFavorite(id: id);
  //   mainResponse = MainResponse.fromJson(response.data);
  //   if (mainResponse.errorCode == 0) {
  //     emit(AddServiceToFavSuccess());
  //     getFavoritesServices();
  //   } else {
  //     emit(AddServiceToFavError(error: mainResponse.errorMessage.toString()));
  //   }
  // }
  bool getVendorProfileData = false;

  Future showVendorProfile({required int id}) async {
    getVendorProfileData = true;
    vendorProfileModel = null;
    emit(ShowVendorProfileLoadingState());
    final response = await _profileRemoteDatasource.showVendorDetails(id: id);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;

        getVendorProfileData = false;
        emit(ShowVendorProfileErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) async {
        vendorProfileModel = r.vendorProfileModel;
        for (var element in r.vendorProfileModel.productsList!) {
          if (!vendorProducts.containsKey(element.id!.toString())) {
            vendorProducts.addAll({element.id!.toString(): element.inStock!});
          }
        }
        getVendorProfileData = false;
        emit(ShowVendorProfileSuccessState());
      },
    );
  }

  bool getProductReviewLoading = false;

  void getProductReview({required String productId}) async {
    reviewsList = [];
    getProductReviewLoading = true;
    emit(ShowProductDetailsLoadingState());
    final response =
        await _productsRemoteDatasource.getAllProductReviews(id: productId);
    response.fold(
      (l) {
        getProductReviewLoading = false;
        baseErrorModel = l.baseErrorModel;
        emit(ShowProductDetailsErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        getProductReviewLoading = false;
        if (r.reviewModel != null) {
          reviewsList.addAll(r.reviewModel!);
        }
        emit(ShowProductDetailsSuccessState());
      },
    );
  }

  ProductMultiLangModel? productMultiLangModel;
  bool? getMultiLangLaborerLoading;

  // دالة getMultiLangProduct تستدعي الـ API للحصول على تفاصيل المنتج متعدد اللغات
  void getMultiLangProduct({required int id}) async {
    emit(ShowProductMultiLangLoadingState());
    final response =
        await _multiLangRemoteDataSource.geProductMultiLang(id: id);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        tags.clear(); // مسح التاجات القديمة
        emit(ShowProductMultiLangErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        productMultiLangModel = r;
        if (productMultiLangModel?.tags != null &&
            productMultiLangModel!.tags!.isNotEmpty) {
          tags.text = productMultiLangModel!.tags!.join(', ');
        } else {
          tags.clear(); // إذا لم توجد تاجات، تأكد من مسح الحقل
        }
        emit(ShowProductMultiLangSuccessState());
      },
    );
  }

  void deleteProduct({required int productId}) async {
    emit(DeleteProductLoadingState());
    final response =
        await _productsRemoteDatasource.deleteProduct(id: productId);
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(DeleteProductErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) async {
        showVendorProfile(id: int.parse(userId!.toString()));
        emit(DeleteProductSuccessState(baseResponseModel: r));
      },
    );
  }

  void uploadProduct({required ProductParameters productParameters}) async {
    emit(UploadProductLoadingState());

    // معالجة التاجات
    List<String> tagsList = [];
    if (tags.text.isNotEmpty) {
      tagsList = tags.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (tagsList.isNotEmpty) {
        productParameters.tags = tagsList;
      }
    }

    // productParameters.productCurrency = productCurrency.text;

    // final Map<String, dynamic> requestData = await productParameters.toMap();

    final response = await _productsRemoteDatasource.uploadProduct(
      productParameters: productParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UploadProductErrorState(
            error:
                baseErrorModel?.errors?[0] ?? baseErrorModel?.message ?? ""));
      },
      (r) {
        tags.clear(); // مسح التاجات بعد نجاح الإضافة
        emit(UploadProductSuccessState(updateProductModel: r));
      },
    );
  }

  void addProductReview({
    required ReviewProductParameters reviewProductParameters,
    required String id,
  }) async {
    emit(UploadReviewProductLoadingState());
    final response = await _productsRemoteDatasource.addProductReview(
      id: id,
      reviewProductParameters: reviewProductParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UploadReviewProductErrorState(
            error: baseErrorModel?.errors?[0] ?? baseErrorModel!.message));
      },
      (r) {
        emit(UploadReviewProductSuccessState(baseResponseModel: r));
      },
    );
  }

  void updateProduct({required ProductParameters productParameters}) async {
    emit(UpdateProductLoadingState());

    // Handle tags for update
    if (tags.text.isNotEmpty) {
      productParameters.tags = tags.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    } else {
      productParameters.tags = [];
    }

    // تأكد من إرسال العملة الصحيحة
    productParameters.productCurrency = productCurrency.text;

    //productParameters.priceType = priceType.text;
    //productParameters.countryId = int.tryParse(countryId.text);
    //productParameters.phoneNumber = phoneNumber.text;
    //productParameters.phoneCode = phoneCode.text;

    final response = await _productsRemoteDatasource.updateProduct(
      productParameters: productParameters,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(UpdateProductErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        emit(UpdateProductSuccessState(updateProductModel: r));
      },
    );
  }

  void changeFavorite({required int id}) async {
    final currentStatus = favoriteProduct[id.toString()] ?? false;
    favoriteProduct[id.toString()] = !currentStatus;

    emit(WishProductLoadingState());

    final response = await _productsRemoteDatasource.addToFavorite(id: id);

    response.fold(
      (l) {
        favoriteProduct[id.toString()] =
            currentStatus; // Revert to original status
        baseErrorModel = l.baseErrorModel;
        emit(WishProductErrorState(error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        if (!favoriteProduct[id.toString()]!) {
          favoriteProductsList.removeWhere((product) => product.id == id);
        }
        emit(WishProductSuccessState());

        // Check message safely
        final message = r.message;
        if (message != null && message.contains("removed")) {
          getFavoriteProducts();
        }
      },
    );
  }

  void deleteProductImages({required int id}) async {
    emit(DeleteProductImagesLoadingState());
    final response = await _productsRemoteDatasource.deleteProductImages(
      id: id,
    );
    response.fold(
      (l) {
        baseErrorModel = l.baseErrorModel;
        emit(DeleteProductImagesErrorState(
            error: baseErrorModel?.errors?[0] ?? ""));
      },
      (r) {
        emit(DeleteProductImagesSuccessState(imageId: id));
      },
    );
  }

  bool getCategory = false;

  void chooseCategory(CategoriesModel? value) {
    productCategory = value;
    showCategoryModel = null;
    productSubCategory =
        null; // إعادة تعيين التصنيف الفرعي عند تغيير التصنيف الرئيسي

    if (value != null) {
      showCategoryDetails(categoryId: value.id);
    }

    emit(ChangeCategoryState());
  }

  void chooseSubCategory(SubCategoriesModel? value) {
    productSubCategory = value;
    emit(ChangeCategoryState());
  }

  void getAllCategories() async {
    if (allCategoriesPageNumber == 1) {
      getAllCategoriesLoading = true;
      categoriesList.clear(); // مسح القائمة قبل إعادة التحميل
      emit(GetAllCategoriesLoadingState());
    }

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
        if (r.getPaginatedCategoriesResultModel != null) {
          if (allCategoriesPageNumber <=
              r.getPaginatedCategoriesResultModel!.lastPage!) {
            categoriesList
                .addAll(r.getPaginatedCategoriesResultModel!.categories!);
            allCategoriesPageNumber++;
            getAllCategoriesLoading = false;
            emit(GetAllCategoriesSuccessState());
          }
        }
      },
    );
  }

  void showCategoryDetails({int? categoryId}) async {
    emit(ShowCategoryDetailsLoadingState());
    getCategory = true;

    if (categoryId == null) {
      getCategory = false;
      showCategoryModel = null;
      emit(ShowCategoryDetailsSuccessState());
      return;
    }

    final response =
        await _categoriesRemoteDatasource.showCategory(id: categoryId);
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

  bool getAllCategoriesLoading = false;

  CategoriesModel? productCategory;
  SubCategoriesModel? productSubCategory;

  int? selectedServicesCategoryIndex;
  int? selectedCategoryIndex;
  int? selectedSubCategoryIndex;

  void changeCategoriesTabBarWidget(int index,
      {bool isCategories = true, int? categoryId}) {
    if (isCategories) {
      if (index != selectedCategoryIndex) {
        // تحديد تصنيف جديد
        selectedCategoryIndex = index;
        selectedSubCategoryIndex = null;
        showCategoryModel = null;
        getCategory = true;
        emit(ShowCategoryDetailsLoadingState());
        if (categoryId != null) {
          showCategoryDetails(categoryId: categoryId);
        }
      } else {
        // إلغاء تحديد التصنيف
        selectedCategoryIndex = null;
        selectedSubCategoryIndex = null;
        showCategoryModel = null;
        getCategory = false;
        // إعادة تعيين الصفحة وجلب جميع المنتجات
        allProductsPageNumber = 1;
        productsList.clear();
        emit(GetAllProductsLoadingState());
        getAllProducts();
      }
    } else {
      if (index != selectedSubCategoryIndex) {
        selectedSubCategoryIndex = index;
        emit(ChangeCategoriesTabBarWidgetState());
      } else {
        selectedSubCategoryIndex = null;
        emit(ChangeCategoriesTabBarWidgetState());
      }
    }
    emit(ChangeCategoriesTabBarWidgetState());
  }

  void changeServicesCategoriesTabBarWidget(
    int index,
  ) {
    if (index != selectedServicesCategoryIndex) {
      selectedServicesCategoryIndex = index;
    } else {
      selectedServicesCategoryIndex = null;
    }
    emit(ChangeServicesCategoriesTabBarWidgetState());
  }

  // دالة مساعدة للتحقق من حالة المفضلة
  bool isProductFavorite(int productId) {
    return favoriteProduct[productId.toString()] ?? false;
  }

  // دالة مساعدة للتحقق من متابعة البائع
  bool isVendorFollowed(int vendorId) {
    return followedVendors[vendorId.toString()] ?? false;
  }

  // Add helper method to safely get vendor status
  bool getVendorStatus(String vendorId) {
    return followedVendors[vendorId] ?? false;
  }

  // Add helper method to safely get product status
  bool getFavoriteStatus(String productId) {
    return favoriteProduct[productId] ?? false;
  }

  // Add helper method to safely add to followedVendors
  void setVendorFollowStatus(String vendorId, bool? isFollowed) {
    followedVendors[vendorId] = isFollowed ?? false;
  }

  // Add helper method to safely add to favoriteProduct
  void setProductFavoriteStatus(String productId, bool? isFavorite) {
    favoriteProduct[productId] = isFavorite ?? false;
  }

  void resetCategorySelection() {
    productCategory = null;
    productSubCategory = null;
    showCategoryModel = null;
    emit(ChangeCategoryState());
  }

  void handleLogout() {
    vendorProducts.clear();
    followedVendors.clear();
    favoriteProduct.clear();
    favoriteProductsList.clear();
    tags.clear(); // إضافة مسح التاجات
    emit(ProductsInitial());
  }

  @override
  Future<void> close() {
    handleLogout();
    return super.close();
  }
}
