import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/stores_models/store_data_model.dart';
part 'service_map_state.dart';

class ServiceMapCubit extends Cubit<ServiceMapState> {
  ServiceMapCubit() : super(ServiceMapInitial());
  static ServiceMapCubit get(context) => BlocProvider.of(context);

  final CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
   final Completer<GoogleMapController> googleMapController = Completer<GoogleMapController>();
  Set<Marker> markers = {};
  Set<String> autoExpandedClusters = {};

  bool isMapReady = false;
  List<MapItem> localProductsList = [];
  void buildMarkers() {
    Set<Marker> newMarkers = {};

    for (var item in localProductsList) {
      if (item.coordinates == null || item.coordinates!.isEmpty) continue;

      try {
        final parts = item.coordinates!.split(",");
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        final position = LatLng(lat, lng);

        newMarkers.add(
          Marker(
            markerId: MarkerId(item.id.toString()),
            position: position,
            infoWindow: InfoWindow(
              title: item.name ?? 'No name',
              // optionally add snippet or other data here
            ),
            onTap: () {
              // Show your custom info window if needed
              customInfoWindowController.addInfoWindow!(
                Text(item.name ?? ''),
                position,
              );
            },
          ),
        );
      } catch (e) {
        // handle parse error if coordinates are invalid
      }
    }

    markers = newMarkers;
    emit(ServiceMapMarkersUpdated()); // you can add a new state for this if you want
  }
  void updateLocalProducts(List<MapItem> newList) {
    localProductsList = newList;
    buildMarkers();
  }

  GoogleMapController? mapController;
  LatLngBounds? lastKnownBounds;
  LatLng calculateCenter() {
    if (markers.isEmpty) return const LatLng(24.7136, 46.6753); // Default to Riyadh

    double totalLat = 0, totalLng = 0;

    for (Marker marker in markers) {
      totalLat += marker.position.latitude;
      totalLng += marker.position.longitude;
    }

    return LatLng(
      totalLat / markers.length,
      totalLng / markers.length,
    );
  }

  Future<List<dynamic>> getVisibleMarkers() async {
    if (!isMapReady || mapController == null) return [];

    try {
      lastKnownBounds = await mapController!.getVisibleRegion();
      List<dynamic> visibleProducts = [];

      for (var product in localProductsList) {
        if (product.coordinates != null && product.coordinates!.isNotEmpty) {
          try {
            LatLng position = LatLng(
              double.parse(product.coordinates!.split(",").first.trim()),
              double.parse(product.coordinates!.split(",").last.trim()),
            );
            if (lastKnownBounds!.contains(position)) {
              visibleProducts.add(product);
            }
          } catch (e) {
            // print("خطأ في إحداثيات المنتج ${product.id}: $e");
          }
        }
      }

      String visibleIds = visibleProducts.map((p) => p.id.toString()).join(",");
      // widget.onVisibleIdsChanged(visibleIds);

      return visibleProducts;
    } catch (e) {
      // print("خطأ أثناء جلب المنطقة المرئية: $e");
      return [];
    }
  }

}
