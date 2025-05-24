import 'dart:async';
import 'dart:developer' as print;
import 'dart:math';
import 'dart:typed_data';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/assets_path/images_path.dart';
import '../../../../data/models/stores_models/store_data_model.dart';
import '../../../../presentation/widgets/maps_widgets/home_google_map_view.dart';
import '../../../../presentation/widgets/maps_widgets/info_on_service_map.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
part 'service_map_state.dart';

class ServiceMapCubit extends Cubit<ServiceMapState> {
  ServiceMapCubit() : super(ServiceMapInitial());

  static ServiceMapCubit get(context) => BlocProvider.of(context);

  final CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  final Completer<GoogleMapController> googleMapController =
  Completer<GoogleMapController>();
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;

  Future<void> getCurrentMarker() async {
    final Uint8List markerIcon =
    await getBytesFromAsset(ImagesPath.mapMarkerIcon, 100.w.toInt());
    currentIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  Set<Marker> markers = {};
  final Set<Marker> expandedMarkers = {};
  Set<Polyline> polylines = {};
  Set<String> autoExpandedClusters = {};
  final double autoExpandZoomThreshold = 17;

  void autoExpandClusters() async {
    if (mapController == null) return;
    double zoom = await mapController!.getZoomLevel();
    if (zoom > autoExpandZoomThreshold) {
      Map<String, List<MapItem>> grouped = {};
      for (var element in localProductsList) {
        if (element.coordinates != null && element.coordinates!.isNotEmpty) {
          String key = element.coordinates!.trim();
          grouped.putIfAbsent(key, () => []).add(element);
        }
      }
      grouped.forEach((key, products) {
        if (products.length > 1 && !autoExpandedClusters.contains(key)) {
          List<String> parts = key.split(",");
          LatLng center = LatLng(double.parse(parts.first.trim()),
              double.parse(parts.last.trim()));
          expandClusterMarkers(center, products);
          autoExpandedClusters.add(key);
        }
      });
    } else {
      collapseAllClusters();
      autoExpandedClusters.clear();
      polylines.clear();
    }
  }

  void expandClusterMarkers(LatLng center, List<MapItem> products) async {
    // Remove the cluster marker at the tapped cluster position
    markers.removeWhere((marker) => marker.markerId.value == "cluster_${getClusterKey(center.latitude, center.longitude)}");

    // Remove any previous expanded markers for this cluster (optional)
    expandedMarkers.removeWhere((m) => m.markerId.value.endsWith("_expanded"));

    // Clear polylines for this cluster (optional)
    polylines.removeWhere((line) => line.polylineId.value.contains(center.toString()));

    // Create and add individual markers around the center
    final double radius = 0.00015;
    for (int i = 0; i < products.length; i++) {
      double angle = (2 * pi * i) / products.length;
      double offsetLat = radius * cos(angle);
      double offsetLng = radius * sin(angle);
      LatLng newPosition = LatLng(center.latitude + offsetLat, center.longitude + offsetLng);

      final expandedMarker = Marker(
        markerId: MarkerId("${products[i].id}_expanded"),
        icon: currentIcon,
        position: newPosition,
        onTap: () {
          customInfoWindowController.addInfoWindow!(
            InfoOnServiceMap(
              img: products[i].image ?? '',
              name: products[i].name ?? '',
              mapLocation: products[i].mapLocation ?? '',
            ),
            newPosition,
          );
        },
      );

      expandedMarkers.add(expandedMarker);

      // Add a polyline connecting center to expanded marker (optional)
      polylines.add(
        Polyline(
          polylineId: PolylineId("${products[i].id}_line_${center.toString()}"),
          visible: true,
          points: [center, newPosition],
          color: Colors.grey,
          width: 2,
        ),
      );
    }

    // Remove cluster marker and add expanded markers
    markers.removeWhere((m) => m.markerId.value == "cluster_${getClusterKey(center.latitude, center.longitude)}");
    markers.addAll(expandedMarkers);

    emit(ServiceMapMarkersUpdated());

    // Animate camera to cluster center + zoom in
    if (mapController != null) {
      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(center, 18));
    }
  }

  void collapseClusterMarkers(LatLng center) {
    // Remove all expanded markers
    markers.removeWhere((m) => m.markerId.value.endsWith("_expanded"));

    // Add back the cluster marker
    final String key = getClusterKey(center.latitude, center.longitude);
    final group = localProductsList.where((item) {
      if (item.coordinates == null) return false;
      try {
        final parts = item.coordinates!.split(",");
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return getClusterKey(lat, lng) == key;
      } catch (_) {
        return false;
      }
    }).toList();

    if (group.length > 1) {
      getClusterBitmapDescriptor(group.length).then((clusterIcon) {
        markers.add(
          Marker(
            markerId: MarkerId("cluster_$key"),
            position: center,
            icon: clusterIcon,
            onTap: () {
              expandClusterMarkers(center, group);
            },
            // infoWindow: InfoWindow(title: "${group.length} items"),
          ),
        );
        emit(ServiceMapMarkersUpdated());
      });
    }
  }

  void collapseAllClusters() {
    buildMarkers();
    polylines.clear();
  }

  bool isMapReady = false;
  List<MapItem> localProductsList = [];

  String getClusterKey(double lat, double lng) {
    return "${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}";
  }

  Future<BitmapDescriptor> getClusterBitmapDescriptor(int count) async {
    final int size = 80;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint);
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: "$count",
            style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            (size - textPainter.width) / 2, (size - textPainter.height) / 2));
    final ui.Image img = await recorder.endRecording().toImage(size, size);
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> buildMarkers() async {
    await getCurrentMarker();

    Map<String, List<MapItem>> clusterMap = {};

    for (var item in localProductsList) {
      if (item.coordinates == null || item.coordinates!.isEmpty) continue;

      try {
        final parts = item.coordinates!.split(",");
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());

        String key = getClusterKey(lat, lng);
        clusterMap.putIfAbsent(key, () => []).add(item);
      } catch (e) {
        // Ignore parse errors
      }
    }

    Set<Marker> newMarkers = {};

    for (var entry in clusterMap.entries) {
      final key = entry.key;
      final group = entry.value;
      final parts = key.split(",");
      final center = LatLng(double.parse(parts[0]), double.parse(parts[1]));

      if (group.length == 1) {
        final item = group.first;
        newMarkers.add(
          Marker(
            markerId: MarkerId(item.id.toString()),
            icon: currentIcon,
            position: center,
            onTap: () {
              customInfoWindowController.addInfoWindow!(
                InfoOnServiceMap(
                  img: item.image ?? '',
                  name: item.name ?? '',
                  mapLocation: item.mapLocation ?? '',
                ),
                center,
              );
            },
          ),
        );
      } else {
        final BitmapDescriptor clusterIcon = await getClusterBitmapDescriptor(group.length);

        newMarkers.add(
          Marker(
            markerId: MarkerId("cluster_$key"),
            position: center,
            icon: clusterIcon,
            onTap: () {
              expandClusterMarkers(center, group);
            },
            infoWindow: InfoWindow(title: "${group.length} items"),
          ),
        );
      }
    }

    markers = newMarkers;
    expandedMarkers.clear();
    polylines.clear();
    autoExpandedClusters.clear();

    emit(ServiceMapMarkersUpdated());
  }

  void updateLocalProducts(List<MapItem> newList) {
    localProductsList = newList;
    buildMarkers();
  }
setStat(){
    emit(newState());
}
  LatLng calculateCenter() {
    if (markers.isEmpty) {
      return const LatLng(24.7136, 46.6753); // Riyadh default
    }

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

  GoogleMapController? mapController;
  LatLngBounds? lastKnownBounds;

  Future<List<dynamic>> getVisibleMarkers() async {
    if (mapController == null) return [];

    final LatLngBounds visibleRegion = await mapController!.getVisibleRegion();

    lastKnownBounds = visibleRegion;

    return markers.where((m) {
      return visibleRegion.contains(m.position);
    }).toList();
  }
}
