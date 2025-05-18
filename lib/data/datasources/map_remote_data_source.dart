import 'package:an3am/core/network/dio_helper.dart';


abstract class BaseMapRemoteDataSource {
}

class MapRemoteDataSource extends BaseMapRemoteDataSource {
  final DioHelper dioHelper;

  MapRemoteDataSource({required this.dioHelper});


}
 