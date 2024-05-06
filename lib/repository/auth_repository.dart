import 'package:godus/data/network/network_api_services.dart';
import 'package:godus/res/widgets/app_urls.dart';

class AuthRepository {
  final NetworkApiServices _network = NetworkApiServices();
  Future<dynamic> apiLogin(dynamic data) async {
    try {
      final response =
          await _network.getPostApiResponse(AppUrls.loginEndPoint, data);
      return response;
    } catch (e) {
      rethrow; //Big Brain
    }
  }

  Future<dynamic> signUp(dynamic data) async {
    try {
      final response =
          await _network.getPostApiResponse(AppUrls.registerEndPoint, data);
      return response;
    } catch (e) {
      rethrow; //Big Brain
    }
  }
}
