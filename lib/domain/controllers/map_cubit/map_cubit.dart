import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import '../../../core/assets_path/images_path.dart';
import '../../../core/cache_helper/shared_pref_methods.dart';
import '../../../core/services/services_locator.dart';
import '../../../data/datasources/remote_datasource/products_remote_datasource.dart';
import '../../../data/models/products_model/product_model.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  static MapCubit get(context) => BlocProvider.of(context);

  final ProductsRemoteDatasource _productsRemoteDatasource = sl();

  Set<Marker> markers = {};
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  List<ProductDataModel> mapProducts = [];
  List<ProductDataModel> filteredMapProducts = []; // القائمة المفلترة للمنتجات
  int? selectedCategoryId; // معرف الفئة المحددة
  int mapProductsPageNumber = 1;
  bool isLoadingMore = false;
  int? lastPage;
  bool hasReachedLastPage = false;

  // المفتاح المستخدم لتخزين المنتجات في الكاش
  static const String cacheKey = 'map_products_cache';
  // المفتاح المستخدم لتخزين معلومات الصفحات
  static const String cachePaginationKey = 'map_products_pagination';

  // تصفية المنتجات حسب الفئة المحددة
  void filterProductsByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    if (categoryId == null) {
      // إذا لم يتم تحديد فئة، اعرض جميع المنتجات
      filteredMapProducts = List.from(mapProducts);
    } else {
      // تصفية المنتجات حسب الفئة المحددة
      filteredMapProducts = mapProducts
          .where((product) => product.category?.id == categoryId)
          .toList();
    }
    // تحديث الماركرز بعد التصفية
    updateMapMarkers();
    emit(FilterProductsByCategory());
  }

  // تحديث العلامات على الخريطة
  void updateMapMarkers() {
    markers.clear();
    for (var product in filteredMapProducts) {
      if (product.coordinates != null) {
        // تحويل نص الإحداثيات إلى قائمة من الأرقام
        final coords = product.coordinates!.split(',').map((e) => double.tryParse(e.trim())).toList();
        if (coords.length == 2 && coords[0] != null && coords[1] != null) {
          markers.add(
            Marker(
              markerId: MarkerId(product.id.toString()),
              position: LatLng(coords[0]!, coords[1]!),
              icon: currentIcon,
              infoWindow: InfoWindow(
                title: product.name ?? '',
                snippet: product.description ?? '',
              ),
            ),
          );
        }
      }
    }
    emit(MarkerGenerationDone());
  }

  // استدعاء البيانات المخزنة في الكاش عند بدء التطبيق
  Future<void> loadCachedData() async {
    try {
      final cachedPagination = CacheHelper.getData(key: cachePaginationKey);
      if (cachedPagination != null) {
        final paginationData = json.decode(cachedPagination);
        mapProductsPageNumber = paginationData['currentPage'] ?? 1;
        lastPage = paginationData['lastPage'];
        hasReachedLastPage = paginationData['hasReachedLastPage'] ?? false;
      }

      final cachedData = CacheHelper.getData(key: cacheKey);
      if (cachedData != null) {
        final List<dynamic> productsJson = json.decode(cachedData);
        mapProducts = productsJson
            .map((json) => ProductDataModel.fromJson(json))
            .toList();

        emit(GetDataMapSuccess());
      }
    } catch (e) {
      // في حالة حدوث خطأ، نستمر بدون استخدام الكاش
      mapProductsPageNumber = 1;
      mapProducts = [];
      hasReachedLastPage = false;
    }
  }

  // حفظ البيانات في الكاش
  Future<void> _saveDataToCache() async {
    try {
      final List<Map<String, dynamic>> productsJson =
          mapProducts.map((product) => product.toJson()).toList();

      await CacheHelper.saveData(
        key: cacheKey,
        value: json.encode(productsJson),
      );

      final paginationData = {
        'currentPage': mapProductsPageNumber,
        'lastPage': lastPage,
        'hasReachedLastPage': hasReachedLastPage,
      };

      await CacheHelper.saveData(
        key: cachePaginationKey,
        value: json.encode(paginationData),
      );
    } catch (e) {
      // تجاهل أخطاء الكاش
    }
  }

  void getDataOnMap() async {
    // تحقق من إمكانية تحميل المزيد من المنتجات
    if (hasReachedLastPage) {
      emit(GetDataMapSuccess());
      return;
    }

    if (mapProductsPageNumber == 1) {
      emit(GetDataMapLoading());
      mapProducts.clear();
    } else {
      isLoadingMore = true;
    }

    final response = await _productsRemoteDatasource.getAllProducts(
      pageNumber: mapProductsPageNumber,
    );

    response.fold(
      (l) {
        isLoadingMore = false;
        emit(GetDataMapError());
      },
      (r) {
        if (r.getPaginatedProductResultModel != null) {
          final currentPage =
              r.getPaginatedProductResultModel!.currentPage ?? 1;
          lastPage = r.getPaginatedProductResultModel!.lastPage;

          // تحقق مما إذا وصلنا إلى آخر صفحة
          if (currentPage >= (lastPage ?? 1)) {
            hasReachedLastPage = true;
          }

          if (mapProductsPageNumber <= (lastPage ?? 1)) {
            final products = r.getPaginatedProductResultModel!.products
                    ?.where((element) =>
                        element.inStock == true &&
                        element.isApproved == true &&
                        element.coordinates != null &&
                        element.coordinates!.isNotEmpty)
                    .toList() ??
                [];

            for (var product in products) {
              if (!mapProducts.any((p) => p.id == product.id)) {
                mapProducts.add(product);

                // إضافة الصورة الرئيسية إلى بداية قائمة الصور
                final index = mapProducts.indexWhere((p) => p.id == product.id);
                if (index != -1 && product.mainImage != null) {
                  mapProducts[index]
                      .images
                      ?.insert(0, Images(image: product.mainImage));
                }
              }
            }

            // زيادة رقم الصفحة فقط إذا لم نصل إلى آخر صفحة
            if (!hasReachedLastPage) {
              mapProductsPageNumber++;
            }

            // حفظ البيانات في الكاش بعد كل تحميل ناجح
            _saveDataToCache();
          }
        }

        isLoadingMore = false;
        emit(GetDataMapSuccess());
      },
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void getCurrentMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset(ImagesPath.mapMarkerIcon, 100.w.toInt());
    currentIcon = BitmapDescriptor.fromBytes(markerIcon);
    emit(MarkerGenerationDone());
    getMarkers();
  }

  double addedPosition = 0.0105;

  void getMarkers() {
    markers.clear();

    for (var product in mapProducts) {
      if (product.coordinates != null && product.coordinates!.isNotEmpty) {
        try {
          final latLng = product.coordinates!.split(',');
          final latitude = double.parse(latLng[0].trim());
          final longitude = double.parse(latLng[1].trim());

          markers.add(
            Marker(
              markerId: MarkerId('${product.id}'),
              position: LatLng(latitude, longitude),
              icon: currentIcon,
            ),
          );
        } catch (e) {
          // Handle error parsing coordinates
        }
      }
    }

    emit(GetMarkersPositionDone());
  }

  // دالة للتحقق من إمكانية تحميل المزيد من المنتجات
  bool canLoadMoreProducts() {
    return !hasReachedLastPage;
  }

  // دالة لإعادة ضبط حالة التحميل عند الحاجة
  void resetPagination() {
    mapProductsPageNumber = 1;
    hasReachedLastPage = false;
    mapProducts.clear();

    // مسح التخزين المؤقت عند إعادة التهيئة
    CacheHelper.removeData(key: cacheKey);
    CacheHelper.removeData(key: cachePaginationKey);

    emit(MapInitial());
  }

  void handleLogout() {
    mapProducts.clear();
    markers.clear();
    mapProductsPageNumber = 1;
    lastPage = null;
    emit(MapInitial());
  }

  @override
  Future<void> close() {
    handleLogout();
    return super.close();
  }
}
