import 'package:an3am/domain/controllers/services_cubit/services_cubit.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/controllers/map_cubit/service_map_cubit/service_map_cubit.dart';

class ServiceMapWidget extends StatefulWidget {
  const ServiceMapWidget({super.key});

  @override
  State<ServiceMapWidget> createState() => _ServiceMapWidgetState();
}

class _ServiceMapWidgetState extends State<ServiceMapWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceMapCubit, ServiceMapState>(
      builder: (context, state) {
        var cubit=ServiceMapCubit.get(context);
        return state is  UpdateStateMarker// You can replace this with state checks if needed
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target:cubit. calculateCenter(),
                zoom: 5.0,
              ),
              onMapCreated: (controller) async {
                if (!cubit.googleMapController.isCompleted) {
                  cubit.googleMapController.complete(controller);
                }
                cubit.mapController = controller;
                cubit.customInfoWindowController.googleMapController = controller;

                cubit.lastKnownBounds = await cubit.mapController!.getVisibleRegion();
                setState(() => cubit.isMapReady = true);
                Future.delayed(
                  const Duration(milliseconds: 500),
                      () => cubit.getVisibleMarkers(),
                );
              },
              onTap: (latLng) {
                cubit.customInfoWindowController.hideInfoWindow?.call();
                // collapseAllClusters();
              },
              onCameraMove: (CameraPosition position) {
                // _debouncedGetVisibleMarkers();
              },
              onCameraIdle: () {
                // getVisibleMarkers();
                // autoExpandClusters();
              },
              compassEnabled: true,
              mapToolbarEnabled: true,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())
              },
              markers:cubit. markers,
              // polylines: _polylines,
            ),
            CustomInfoWindow(
              controller: cubit.customInfoWindowController,
              width: 255.w,
              height: 230.h,
              offset: 30.h,
            ),
            if (1==1)
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  'تم تحميل ${cubit.localProductsList.length} منتج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (kDebugMode)
              Positioned(
                top: 20.h,
                left: 20.w,
                child: FloatingActionButton(
                  heroTag: 'clearCacheMap',
                  mini: true,
                  backgroundColor: Colors.orange,
                  onPressed: () async {
                    // await ProductsCubit.get(context).clearMapCacheAndReset();
                    // loadFreshProducts();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Map cache cleared. Reloading products...'),
                        ),
                      );
                    }
                  },
                  tooltip: 'Clear Map Cache & Reload',
                  child: const Icon(Icons.delete_sweep, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}
