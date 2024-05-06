import 'package:godus/data/network/base_api_services.dart';
import 'package:godus/data/network/network_api_services.dart';
import 'package:godus/models/movies_model.dart';
import 'package:godus/res/widgets/app_urls.dart';

class HomeRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  Future<MovieListModel> fetchMoviesList() async {
    try {
      // print("first line fetchMoviesList function");
      dynamic response =
          await _apiServices.getGetApiResponse(AppUrls.moviesListEndPoint);
      return response = MovieListModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
