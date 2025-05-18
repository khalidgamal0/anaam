import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? email;
  final String? phone;
  final String? location;
  final String? address;
  final String? birth_date;
  final String? createdAt;
  final String? updatedAt;
  final String? countryId;
  final String? cityId;
  final String? stateId;

  const ProfileModel({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.email,
    this.phone,
    this.location,
    this.address,
    this.birth_date,
    this.createdAt,
    this.updatedAt,
    this.countryId,
    this.cityId,
    this.stateId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      image: json['image'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      address: json['address'],
      birth_date: json['birth_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      countryId: json['country_id'] != null ? json['country_id'].toString() : null,
      cityId: json['city_id'] != null ? json['city_id'].toString() : null,
      stateId: json['state_id'] != null ? json['state_id'].toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['image'] = image;
    data['email'] = email;
    data['phone'] = phone;
    data['location'] = location;
    data['address'] = address;
    data['birth_date'] = birth_date;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['country_id'] = countryId;
    data['city_id'] = cityId;
    data['state_id'] = stateId;
    return data;
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    image,
    email,
    phone,
    location,
    address,
    birth_date,
    createdAt,
    updatedAt,
    countryId,
    cityId,
    stateId,
  ];
}
