import 'package:equatable/equatable.dart';
import '../city_model/city_model.dart';

class StateModel extends Equatable {
  final int? id;
  final String? name;
  final CityModel? city;
  final String? createdAt;
  final String? updatedAt;

  const StateModel({
    this.id,
    this.name,
    this.city,
    this.createdAt,
    this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [id, name, city, createdAt, updatedAt];
}
