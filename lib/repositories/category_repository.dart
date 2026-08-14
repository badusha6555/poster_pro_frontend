import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._dio);

  final Dio _dio;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      return (response.data as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
