import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final bool? isFavorite; // Add isFavorite field

  const ServiceModel({
    this.id,
    this.name,
    this.image,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.isFavorite, // Initialize isFavorite
  });

  @override
  List<Object?> get props => [id, name, image, type, createdAt, updatedAt, isFavorite]; // Add isFavorite to props

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isFavorite: json['is_favorite'], // Parse isFavorite from JSON
    );
  }
}
