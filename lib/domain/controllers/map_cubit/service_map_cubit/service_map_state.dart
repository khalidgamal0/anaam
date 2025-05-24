part of 'service_map_cubit.dart';

sealed class ServiceMapState {}

final class ServiceMapInitial extends ServiceMapState {}
final class ServiceMapMarkersUpdated extends ServiceMapState {}
final class UpdateStateMarker extends ServiceMapState {}
final class newState extends ServiceMapState {}
