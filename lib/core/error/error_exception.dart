import 'package:equatable/equatable.dart';

import '../network/error_message_model.dart';

class ErrorException extends Equatable implements Exception{
  final BaseErrorModel baseErrorModel;

  const ErrorException({required this.baseErrorModel});
  @override
  List<Object?> get props => [
    baseErrorModel,
  ];

}