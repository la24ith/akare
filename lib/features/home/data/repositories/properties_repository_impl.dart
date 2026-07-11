import 'package:akare/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/property_entity.dart';
import '../../domain/entities/property_type_entity.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_datasource.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesRemoteDataSource remoteDataSource;
  PropertiesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PropertyTypeEntity>>> getPropertyTypes() =>
      _guard(() => remoteDataSource.getPropertyTypes());

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties() =>
      _guard(() => remoteDataSource.getFeaturedProperties());

  @override
  Future<Either<Failure, List<PropertyEntity>>> getLatestProperties({
    required int page,
    int limit = 10,
  }) => _guard(
    () => remoteDataSource.getLatestProperties(page: page, limit: limit),
  );

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String propertyId) =>
      _guard(() async {
        await remoteDataSource.toggleFavorite(propertyId);
        return unit;
      });

  /// Centralised try/catch so every call site above stays a one-liner.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(
          e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء تحميل البيانات',
        ),
      );
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('تحقق من اتصالك بالإنترنت وحاول مرة أخرى'),
      );
    }
  }
}
