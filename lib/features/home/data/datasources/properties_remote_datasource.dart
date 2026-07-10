import 'package:dio/dio.dart';

import '../models/property_model.dart';
import '../models/property_type_model.dart';

abstract class PropertiesRemoteDataSource {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertyModel>> getFeaturedProperties();
  Future<List<PropertyModel>> getLatestProperties({required int page, required int limit});
  Future<void> toggleFavorite(String propertyId);
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  final Dio dio;
  PropertiesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    final response = await dio.get('/api/property-types');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => PropertyTypeModel.fromJson(e)).toList();
  }

  @override
  Future<List<PropertyModel>> getFeaturedProperties() async {
    final response = await dio.get('/api/properties/featured');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => PropertyModel.fromJson(e)).toList();
  }

  @override
  Future<List<PropertyModel>> getLatestProperties({
    required int page,
    required int limit,
  }) async {
    final response = await dio.get(
      '/api/properties',
      queryParameters: {'sort': 'newest', 'page': page, 'limit': limit},
    );
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => PropertyModel.fromJson(e)).toList();
  }

  @override
  Future<void> toggleFavorite(String propertyId) async {
    await dio.post('/api/favorites/toggle', data: {'property_id': propertyId});
  }
}
