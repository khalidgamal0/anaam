class ExchangeRateModel {
  final bool success;
  final double rate;

  ExchangeRateModel({required this.success, required this.rate});

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      success: json['success'],
      rate: json['rate'],
    );
  }
}
