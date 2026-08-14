import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/gold_rate_profile.dart';

class GoldRateRepository {
  GoldRateRepository(this._dio);

  final Dio _dio;

  Future<GoldRateProfile> getProfile() async {
    try {
      final response = await _dio.get('/gold-rates');
      return GoldRateProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<GoldRateProfile> updateProfile(GoldRateProfile profile) async {
    try {
      final response = await _dio.put('/gold-rates', data: profile.toJson());
      return GoldRateProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
