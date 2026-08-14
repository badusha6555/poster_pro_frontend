import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/page_response.dart';
import '../models/template.dart';

class FavoriteRepository {
  FavoriteRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<TemplateSummary>> getFavorites({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/favorites',
        queryParameters: {'page': page, 'size': size},
      );
      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        TemplateSummary.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> addFavorite(int templateId) async {
    try {
      await _dio.post('/favorites/$templateId');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> removeFavorite(int templateId) async {
    try {
      await _dio.delete('/favorites/$templateId');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
