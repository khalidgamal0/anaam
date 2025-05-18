class UserReviewModel {
  final int id;
  final String name;
  final String? image;

  UserReviewModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory UserReviewModel.fromJson(Map<String, dynamic> json) {
    return UserReviewModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class VendorReviewModel {
  final int id;
  final String name;
  final String email;
  final int rate;
  final String review;
  final String age;
  final String address;
  final UserReviewModel user;
  final String createdAt;
  final String updatedAt;

  VendorReviewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.rate,
    required this.review,
    required this.age,
    required this.address,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorReviewModel.fromJson(Map<String, dynamic> json) {
    return VendorReviewModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rate: json['rate'] as int? ?? 0,
      review: json['review'] as String? ?? '',
      age: json['age'] as String? ?? '',
      address: json['address'] as String? ?? '',
      user: UserReviewModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rate': rate,
      'review': review,
      'age': age,
      'address': address,
      'user': user.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}