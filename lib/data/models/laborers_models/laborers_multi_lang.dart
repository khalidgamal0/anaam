import 'package:equatable/equatable.dart';

class LaborerMultiLangModel extends Equatable {
  final int? id;
  final Map<String, String>? name;
  final Map<String, String>? nationality;
  final Map<String, String>? profession;
  final Map<String, String>? address;
  final String? phone;
  final String? email;
  final String? image;
  final String? coordinates;
  final String? mapLocation;
  final int? isApproved;
  final int? vendorId;
  final int? serviceId;
  final int? statusId;
  final String? createdAt;
  final String? updatedAt;

  const LaborerMultiLangModel({
    this.id,
    this.name,
    this.nationality,
    this.profession,
    this.address,
    this.phone,
    this.email,
    this.image,
    this.coordinates,
    this.mapLocation,
    this.isApproved,
    this.vendorId,
    this.serviceId,
    this.statusId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    nationality,
    profession,
    address,
    phone,
    email,
    image,
    coordinates,
    mapLocation,
    isApproved,
    vendorId,
    serviceId,
    statusId,
    createdAt,
    updatedAt,
  ];

  factory LaborerMultiLangModel.fromJson(Map<String, dynamic> json) {
    return LaborerMultiLangModel(
      id: json['id'],
      name: json['name'] != null ? Map<String, String>.from(json['name']) : null,
      nationality: json['nationality'] != null ? Map<String, String>.from(json['nationality']) : null,
      profession: json['profession'] != null ? Map<String, String>.from(json['profession']) : null,
      address: json['address'] != null ? Map<String, String>.from(json['address']) : null,
      phone: json['phone'],
      email: json['email'],
      image: json['image'],
      coordinates: json['coordinates'],
      mapLocation: json['map_location'],
      isApproved: json['is_approved'],
      vendorId: json['vendor_id'],
      serviceId: json['service_id'],
      statusId: json['status_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nationality': nationality,
      'profession': profession,
      'address': address,
      'phone': phone,
      'email': email,
      'image': image,
      'coordinates': coordinates,
      'map_location': mapLocation,
      'is_approved': isApproved,
      'vendor_id': vendorId,
      'service_id': serviceId,
      'status_id': statusId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
