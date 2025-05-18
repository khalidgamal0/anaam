import 'dart:convert';

class LocalizedText {
  final String? ar;
  final String? en;

  LocalizedText({
    this.ar,
    this.en,
  });

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'],
      en: json['en'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }
}

class Company {
  final int id;
  final LocalizedText title;
  final LocalizedText description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title.toJson(),
      'description': description.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Expression {
  final int id;
  final LocalizedText title;
  final LocalizedText description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expression({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'],
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title.toJson(),
      'description': description.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AboutUsResponse {
  final Company company;
  final List<Expression> expressions;

  AboutUsResponse({
    required this.company,
    required this.expressions,
  });

  factory AboutUsResponse.fromJson(Map<String, dynamic> json) {
    var expressionsList = json['expressions'] as List;
    List<Expression> expressions =
        expressionsList.map((i) => Expression.fromJson(i)).toList();

    return AboutUsResponse(
      company: Company.fromJson(json['company']),
      expressions: expressions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company.toJson(),
      'expressions': expressions.map((e) => e.toJson()).toList(),
    };
  }

  static AboutUsResponse fromString(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return AboutUsResponse.fromJson(data);
  }
}
