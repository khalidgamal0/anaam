import 'dart:async';
import 'dart:ui' as ui;
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:an3am/domain/controllers/products_cubit/products_cubit.dart';
import 'package:an3am/domain/controllers/products_cubit/products_state.dart';
import 'package:an3am/domain/controllers/map_cubit/map_cubit.dart';
import 'package:an3am/domain/controllers/map_cubit/map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math'; // Added to support cos() and sin()
import '../../../core/assets_path/images_path.dart';
import '../../../data/models/products_model/product_model.dart';
import 'info_window_widget.dart';

class HomeGoogleMapsView extends StatefulWidget {
  final List<ProductDataModel> productsList;
  final Function(String) onVisibleIdsChanged;

  const HomeGoogleMapsView({
    super.key,
    required this.productsList,
    required this.onVisibleIdsChanged,
  });

  static final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  @override
  State<HomeGoogleMapsView> createState() => _HomeGoogleMapsViewState();
}

class _HomeGoogleMapsViewState extends State<HomeGoogleMapsView> {
  Set<Marker> markers = {};
  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  bool isLoading = false;
  bool isMapReady = false;
  bool isLoadingMore = false;
  bool _isInitialLoadDone = false;
  bool _preventAutoZoom = false;
  int _totalLoadedProducts = 0;
  List<ProductDataModel> localProductsList = [];
  GoogleMapController? _mapController;
  LatLngBounds? _lastKnownBounds;
  Timer? _debounceTimer;
  Timer? _loadMoreTimer;
  final ScrollController _scrollController = ScrollController();
  final Set<Marker> expandedMarkers = {};
  Set<Polyline> _polylines = {};
  Set<String> _autoExpandedClusters = {};
  final double autoExpandZoomThreshold = 17;

  @override
  void initState() {
    super.initState();

    // تحميل البيانات المخزنة في بداية التطبيق
    _loadCachedProducts();

    // إعداد مستمع التمرير
    _setupScrollListener();

    // بدء التحميل التلقائي بعد التهيئة الأولية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutomaticLoading();

      if (widget.productsList.isNotEmpty) {
        setState(() {
          localProductsList = widget.productsList;
        });
        setMarkers();
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        _loadMoreProducts();
      }
    });
  }

  // تحميل البيانات من الكاش ثم تحديثها من الخادم
  void _loadCachedProducts() async {
    final cubit = ProductsCubit.get(context);

    // تحميل البيانات المخزنة
    await cubit.loadCachedMapProducts();

    if (cubit.mapProductsList.isNotEmpty) {
      if (mounted) {
        await getCurrentMarker();
        setState(() {
          localProductsList = cubit.mapProductsList;
          _totalLoadedProducts = localProductsList.length;
          _isInitialLoadDone = true;
          isLoading = false;
        });
        setMarkers();

        // تحديث البيانات في الخلفية بعد عرض البيانات المخزنة
        if (!cubit.isLastMapPage) {
          _refreshMapProducts();
        }
      }
    } else {
      // إذا لم تكن هناك بيانات مخزنة، حمّل من الخادم
      loadFreshProducts();
    }
  }

  // تحديث البيانات من الخادم مع الحفاظ على العرض الحالي
  Future<void> _refreshMapProducts() async {
    final cubit = ProductsCubit.get(context);
    // استرجاع صفحة جديدة من البيانات
    await cubit.getProductsForMap();

    if (mounted) {
      setState(() {
        localProductsList = cubit.mapProductsList;
        _totalLoadedProducts = localProductsList.length;
      });
      setMarkers(forceAdjustCamera: false);
    }
  }

  Future<void> loadFreshProducts() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await getCurrentMarker();

    final cubit = ProductsCubit.get(context);
    // إعادة ضبط حالة التصفح
    cubit.resetMapProductsPagination();

    // تحميل الصفحة الأولى من المنتجات
    await cubit.getProductsForMap();

    // تحميل المزيد من الصفحات للبداية إذا لم نصل لنهاية البيانات
    for (int i = 0; i < 2; i++) {
      if (cubit.mapProductsList.isNotEmpty && cubit.canLoadMoreMapProducts()) {
        await cubit.getProductsForMap();
      } else {
        break;
      }
    }

    _totalLoadedProducts = cubit.mapProductsList.length;

    if (!mounted) return;
    setState(() {
      localProductsList = cubit.mapProductsList;
      isLoading = false;
      _isInitialLoadDone = true;
    });

    setMarkers(forceAdjustCamera: true);
  }

  void _startAutomaticLoading() {
    _loadMoreTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!isLoading && !isLoadingMore && _isInitialLoadDone) {
        final cubit = ProductsCubit.get(context);
        if (cubit.canLoadMoreMapProducts()) {
          await _loadMoreProducts(preventZoom: true);
        } else {
          // تم الانتهاء من تحميل كل المنتجات
          timer.cancel();
          _showCompletionSnackBar();
        }
      }
    });
  }

  void _showCompletionSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحميل كل المنتجات (${localProductsList.length}) بنجاح',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(bottom: 60.h, left: 20.w, right: 20.w),
      ),
    );
  }

  Future<void> _loadMoreProducts({bool preventZoom = false}) async {
    if (!mounted || isLoadingMore) return;

    final cubit = ProductsCubit.get(context);

    // فحص إذا وصلنا لآخر صفحة
    if (!cubit.canLoadMoreMapProducts()) {
      _showCompletionSnackBar();
      return;
    }

    setState(() {
      isLoadingMore = true;
      _preventAutoZoom = preventZoom;
    });

    await cubit.getProductsForMap();

    if (!mounted) return;

    // تحقق إذا كان هناك منتجات جديدة تم تحميلها
    final newTotalProducts = cubit.mapProductsList.length;
    final productsAdded = newTotalProducts > _totalLoadedProducts;

    setState(() {
      localProductsList = cubit.mapProductsList;
      isLoadingMore = false;
      _totalLoadedProducts = newTotalProducts;
    });

    // تحديث العلامات فقط إذا تم إضافة منتجات جديدة
    if (productsAdded) {
      setMarkers(forceAdjustCamera: false);
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> getCurrentMarker() async {
    final Uint8List markerIcon = await getBytesFromAsset(ImagesPath.mapMarkerIcon, 100.w.toInt());
    currentIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  // Modified getClusterBitmapDescriptor: reduced size and font size for a better UI
  Future<BitmapDescriptor> getClusterBitmapDescriptor(int count) async {
    final int size = 80; // reduced size
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = Colors.red;
    // Draw circle background
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint);
    // Draw count text:
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: "$count",
            style: TextStyle(
                fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));
    final ui.Image img = await recorder.endRecording().toImage(size, size);
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // New helper to collapse expanded cluster markers back into an aggregated marker
  void collapseClusterMarkers(LatLng center, List<ProductDataModel> products) async {
    // Remove all expanded markers for this cluster (filter by markerId suffix)
    markers.removeWhere((marker) => marker.markerId.value.endsWith('_expanded'));
    // Create the aggregated cluster marker again
    BitmapDescriptor clusterIcon = await getClusterBitmapDescriptor(products.length);
    markers.add(
      Marker(
        markerId: MarkerId(center.toString()),
        icon: clusterIcon,
        position: center,
        onTap: () {
          // On tap, expand again if needed
          expandClusterMarkers(center, products);
        },
      ),
    );
    setState(() {});
  }

  // Remove auto-collapse Future.delayed from expandClusterMarkers
  void expandClusterMarkers(LatLng center, List<ProductDataModel> products) async {
    // Remove aggregated marker at the tapped point
    markers.removeWhere((marker) => marker.markerId.value == center.toString());
    // Clear any existing polylines for this cluster
    _polylines.removeWhere((line) => line.polylineId.value.contains(center.toString()));
    
    // Create individual markers arranged in a circular layout:
    final double radius = 0.00015; // adjust spread distance as needed
    for (int i = 0; i < products.length; i++) {
      double angle = (2 * 3.14159265 * i) / products.length;
      double offsetLat = radius * cos(angle);
      double offsetLng = radius * sin(angle);
      LatLng newPosition = LatLng(center.latitude + offsetLat, center.longitude + offsetLng);
      markers.add(
        Marker(
          markerId: MarkerId("${products[i].id}_expanded"),
          icon: currentIcon,
          position: newPosition,
          onTap: () {
            customInfoWindowController.addInfoWindow!(
              InfoWindowWidget(productDataModel: products[i]),
              newPosition,
            );
          },
        ),
      );
      // Add a polyline connecting center to this expanded marker
      _polylines.add(
        Polyline(
          polylineId: PolylineId("${products[i].id}_line_${center.toString()}"),
          visible: true,
          points: [center, newPosition],
          color: Colors.grey,
          width: 2,
        ),
      );
    }
    setState(() {}); 
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(center, 18));
    }
  }

  // New helper to auto-expand or collapse clusters based on zoom level
  void autoExpandClusters() async {
    if (_mapController == null) return;
    double zoom = await _mapController!.getZoomLevel();
    if (zoom > autoExpandZoomThreshold) {
      // Group products as in setMarkers:
      Map<String, List<ProductDataModel>> grouped = {};
      for (var element in localProductsList) {
        if (element.coordinates != null && element.coordinates!.isNotEmpty) {
          String key = element.coordinates!.trim();
          grouped.putIfAbsent(key, () => []).add(element);
        }
      }
      grouped.forEach((key, products) {
        if (products.length > 1 && !_autoExpandedClusters.contains(key)) {
          List<String> parts = key.split(",");
          LatLng center = LatLng(double.parse(parts.first.trim()), double.parse(parts.last.trim()));
          expandClusterMarkers(center, products);
          _autoExpandedClusters.add(key);
        }
      });
    } else {
      collapseAllClusters();
      _autoExpandedClusters.clear();
      _polylines.clear();
    }
  }

  // Modified collapseAllClusters to also clear polylines
  void collapseAllClusters() {
    setMarkers();
    _polylines.clear();
  }

  void setMarkers({bool forceAdjustCamera = false}) async {
    if (!mounted) return;
    markers.clear();
    _polylines.clear();
    // Group products by coordinates string
    Map<String, List<ProductDataModel>> grouped = {};
    for (var element in localProductsList) {
      if (element.coordinates != null && element.coordinates!.isNotEmpty) {
        String key = element.coordinates!.trim();
        grouped.putIfAbsent(key, () => []).add(element);
      }
    }
    // Process each group
    for (var entry in grouped.entries) {
      try {
        List<String> parts = entry.key.split(",");
        LatLng position = LatLng(
          double.parse(parts.first.trim()),
          double.parse(parts.last.trim()),
        );
        if (entry.value.length == 1) {
          // Add normal marker
          markers.add(
            Marker(
              markerId: MarkerId("${entry.value.first.id}"),
              icon: currentIcon,
              position: position,
              onTap: () {
                customInfoWindowController.addInfoWindow!(
                  InfoWindowWidget(productDataModel: entry.value.first),
                  position,
                );
              },
            ),
          );
        } else {
          // Create aggregated marker with count icon
          BitmapDescriptor clusterIcon =
              await getClusterBitmapDescriptor(entry.value.length);
          markers.add(
            Marker(
              markerId: MarkerId(position.toString()),
              icon: clusterIcon,
              position: position,
              onTap: () {
                // Expand the aggregated marker into individual markers:
                expandClusterMarkers(position, entry.value);
                _autoExpandedClusters.add(entry.key);
              },
            ),
          );
        }
      } catch (e) {
        // ...existing error handling...
      }
    }
    setState(() {});

    if (forceAdjustCamera && !_preventAutoZoom) {
      adjustCameraToFitMarkers();
    } else if (_lastKnownBounds != null) {
      getVisibleMarkers();
    }
  }

  LatLng calculateCenter() {
    if (markers.isEmpty) return const LatLng(24.7136, 46.6753);

    double totalLat = 0, totalLng = 0;
    for (Marker marker in markers) {
      totalLat += marker.position.latitude;
      totalLng += marker.position.longitude;
    }
    return LatLng(totalLat / markers.length, totalLng / markers.length);
  }

  Future<void> adjustCameraToFitMarkers() async {
    if (_mapController == null || markers.isEmpty) return;

    LatLng center = calculateCenter();
    double zoomLevel = markers.isEmpty ? 5.0 : 11.5;

    try {
      await _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(center, zoomLevel));
      _lastKnownBounds = await _mapController!.getVisibleRegion();
      Future.delayed(
          const Duration(milliseconds: 500), () => getVisibleMarkers());
    } catch (e) {
      // print("خطأ أثناء تحريك الكاميرا: $e");
    }
  }

  Future<List<ProductDataModel>> getVisibleMarkers() async {
    if (!isMapReady || _mapController == null) return [];

    try {
      _lastKnownBounds = await _mapController!.getVisibleRegion();
      List<ProductDataModel> visibleProducts = [];

      for (var product in localProductsList) {
        if (product.coordinates != null && product.coordinates!.isNotEmpty) {
          try {
            LatLng position = LatLng(
              double.parse(product.coordinates!.split(",").first.trim()),
              double.parse(product.coordinates!.split(",").last.trim()),
            );
            if (_lastKnownBounds!.contains(position))
              visibleProducts.add(product);
          } catch (e) {
            // print("خطأ في إحداثيات المنتج ${product.id}: $e");
          }
        }
      }

      String visibleIds = visibleProducts.map((p) => p.id.toString()).join(",");
      widget.onVisibleIdsChanged(visibleIds);

      return visibleProducts;
    } catch (e) {
      // print("خطأ أثناء جلب المنطقة المرئية: $e");
      return [];
    }
  }

  void _debouncedGetVisibleMarkers() {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(const Duration(milliseconds: 500), () => getVisibleMarkers());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _loadMoreTimer?.cancel();
    _mapController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is GetMapProductsSuccessState) {
          localProductsList = ProductsCubit.get(context).mapProductsList;
          // لا نحرك الكاميرا تلقائيًا عند تحديث المنتجات
        }
      },
      builder: (context, productsState) {
        return BlocListener<MapCubit, MapState>(
          listener: (context, state) {
            if (state is FilterProductsByCategory) {
              setState(() {
                localProductsList = context.read<MapCubit>().filteredMapProducts;
                setMarkers();
              });
            }
          },
          child:
            isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: calculateCenter(), zoom: 5.0),
                    onMapCreated: (controller) async {
                      if (!HomeGoogleMapsView.googleMapController.isCompleted) {
                        HomeGoogleMapsView.googleMapController
                            .complete(controller);
                      }
                      _mapController = controller;
                      customInfoWindowController.googleMapController =
                          controller;

                      _lastKnownBounds =
                          await _mapController!.getVisibleRegion();
                      setState(() => isMapReady = true);
                      Future.delayed(const Duration(milliseconds: 500),
                          () => getVisibleMarkers());
                    },
                    onTap: (latLng) {
                      customInfoWindowController.hideInfoWindow?.call();
                      collapseAllClusters();
                    },
                    onCameraMove: (CameraPosition position) =>
                        _debouncedGetVisibleMarkers(),
                    onCameraIdle: () {
                      getVisibleMarkers();
                      autoExpandClusters();
                    },
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer())
                    },
                    markers: markers,
                    polylines: _polylines,
                  ),
                  CustomInfoWindow(
                    controller: customInfoWindowController,
                    width: 255.w,
                    height: 230.h,
                    offset: 30.h,
                  ),
                  if (isLoadingMore)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'جاري تحميل المنتجات...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'تم تحميل ${localProductsList.length} منتج',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Developer button to clear cache and reload
                  if (kDebugMode)
                    Positioned(
                      top: 20.h, 
                      left: 20.w,
                      child: FloatingActionButton(
                        heroTag: 'clearCacheMap', // Added unique heroTag
                        mini: true,
                        backgroundColor: Colors.orange, // Dev button color
                        onPressed: () async {
                          await ProductsCubit.get(context).clearMapCacheAndReset();
                          // Call loadFreshProducts to re-fetch from server
                          loadFreshProducts(); 
                          if (mounted) { // Check if widget is still in tree
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Map cache cleared. Reloading products...')),
                            );
                          }
                        },
                        child: Icon(Icons.delete_sweep, color: Colors.white),
                        tooltip: 'Clear Map Cache & Reload',
                      ),
                    ),
                ],
              ),
        );
      },
    );
  }
}
