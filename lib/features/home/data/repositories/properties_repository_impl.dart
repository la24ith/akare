// lib/features/home/data/repositories/properties_repository_impl.dart
import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/local_cache_service.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/entities/property_type_entity.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_datasource.dart';
import '../models/property_model.dart';
import '../models/property_type_model.dart';

const _kFeaturedKey = 'cache_featured_properties';
const _kLatestPage1Key = 'cache_latest_properties_p1';
const _kTypesKey = 'cache_property_types';

class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesRemoteDataSource remoteDataSource;
  PropertiesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PropertyTypeEntity>>> getPropertyTypes() async {
    try {
      final result = await remoteDataSource.getPropertyTypes();
      await LocalCacheService.set(
        _kTypesKey,
        result.map((e) => e.toJson()).toList(),
      );
      return Right(result);
    } catch (e) {
      return _fallback<List<PropertyTypeEntity>>(
        _kTypesKey,
        (data) => (data as List)
            .map((e) => PropertyTypeModel.fromCacheJson(e))
            .toList(),
        _failureFor(e),
      );
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties() async {
    try {
      final result = await remoteDataSource.getFeaturedProperties();
      await LocalCacheService.set(
        _kFeaturedKey,
        result.map((e) => e.toJson()).toList(),
      );
      return Right(result);
    } catch (e) {
      return _fallback<List<PropertyEntity>>(
        _kFeaturedKey,
        (data) =>
            (data as List).map((e) => PropertyModel.fromCacheJson(e)).toList(),
        _failureFor(e),
      );
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getLatestProperties({
    required int page,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getLatestProperties(
        page: page,
        limit: limit,
      );
      // نكاش الصفحة الأولى بس — صفحات "تحميل المزيد" بدون كاش (منطقي: لو
      // مقطوع نت أصلًا ما رح يقدر يحمّل صفحات إضافية سواء بكاش أو بدونه).
      if (page == 1) {
        await LocalCacheService.set(
          _kLatestPage1Key,
          result.map((e) => e.toJson()).toList(),
        );
      }
      return Right(result);
    } catch (e) {
      if (page != 1) return Left(_failureFor(e));
      return _fallback<List<PropertyEntity>>(
        _kLatestPage1Key,
        (data) =>
            (data as List).map((e) => PropertyModel.fromCacheJson(e)).toList(),
        _failureFor(e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String propertyId) async {
    try {
      await remoteDataSource.toggleFavorite(propertyId);
      return const Right(unit);
    } catch (e) {
      return Left(_failureFor(e)); // المفضلة عملية كتابة — ما إلها معنى Offline
    }
  }

  Either<Failure, T> _fallback<T>(
    String key,
    T Function(dynamic) fromJson,
    Failure failure,
  ) {
    final cached = LocalCacheService.get<T>(key, fromJson);
    if (cached != null) return Right(cached);
    return Left(failure);
  }

  Failure _failureFor(Object e) {
    if (e is PostgrestException) {
      return ServerFailure(
        e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء تحميل البيانات',
      );
    }
    if (e is AuthException) return ServerFailure(e.message);
    return const ServerFailure('تحقق من اتصالك بالإنترنت');
  }
}
