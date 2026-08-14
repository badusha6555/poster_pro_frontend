import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/page_response.dart';
import '../models/poster_result.dart';
import '../models/template.dart';

class TemplateRepository {
  TemplateRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<TemplateSummary>> getTemplates({
    int? categoryId,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/templates',
        queryParameters: {
          // ignore: use_null_aware_elements
          if (categoryId != null) 'categoryId': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'size': size,
        },
      );
      return PageResponse.fromJson(
        response.data as Map<String, dynamic>,
        TemplateSummary.fromJson,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<TemplateDetail> getTemplate(int id) async {
    try {
      final response = await _dio.get('/templates/$id');
      return TemplateDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Rate overrides left null fall back to the shop's saved GoldRateProfile
  /// on the backend (see `PosterGenerateRequest`).
  Future<PosterResult> generatePoster(
    int templateId, {
    double? rate22k916,
    double? rate18k,
    double? rate14k,
    double? rate9k,
    String format = 'PNG',
  }) async {
    try {
      final response = await _dio.post(
        '/templates/$templateId/generate',
        queryParameters: {'format': format},
        data: {
          // ignore: use_null_aware_elements
          if (rate22k916 != null) 'rate22k916': rate22k916,
          if (rate18k != null) 'rate18k': rate18k,
          if (rate14k != null) 'rate14k': rate14k,
          if (rate9k != null) 'rate9k': rate9k,
        },
      );
      return PosterResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
