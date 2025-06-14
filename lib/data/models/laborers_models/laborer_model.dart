import 'package:equatable/equatable.dart';

import '../city_model/city_model.dart';
import '../country_model/country_model.dart';
import '../services/services_model.dart';
import '../status_moddel.dart';
import '../stores_models/store_data_model.dart';
import '../vendor_info_model.dart';

class LaborerModel extends Equatable implements MapItem {
  final int? id;
  final String? name;
  final String? nationality;
  final String? profession;
  final String? address;
  final String? phone;
  final String? phone_code;
  final String? email;
  final CityModel? city;
  final CountryModel? country;
  final String? image;
  final String? coordinates;
  final String? mapLocation;
  final bool? isApproved;
  final VendorInfoModel? vendor;
  final ServiceModel? service;
  final StatusModel? status;
  final String? createdAt;
  final String? updatedAt;

  const LaborerModel({
    this.id,
    this.name,
    this.nationality,
    this.profession,
    this.address,
    this.phone,
    this.phone_code,
    this.email,
    this.image,
    this.coordinates,
    this.mapLocation,
    this.isApproved,
    this.vendor,
    this.service,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.country,
    this.city,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    nationality,
    profession,
    address,
    phone,
    phone_code,
    email,
    image,
    coordinates,
    mapLocation,
    isApproved,
    vendor,
    service,
    status,
    createdAt,
    updatedAt,
    country,
    city,
  ];

  factory LaborerModel.fromJson(Map<String, dynamic> json) {
    return LaborerModel(
      id: json['id'],
      name: json['name'],
      nationality: json['nationality'],
      profession: json['profession'],
      address: json['address'],
      phone: json['phone'],
      phone_code: json['phone_code'],
      email: json['email'],
      image: json['image'],
      coordinates: json['coordinates'],
      mapLocation: json['map_location'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      country: json['country'] != null ? CountryModel.fromJson(json['country']) : null,
      isApproved: json['is_approved'],
      vendor: json['vendor'] != null ? VendorInfoModel.fromJson(json['vendor']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      status: json['status'] != null ? StatusModel.fromJson(json['status']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
