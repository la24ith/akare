import 'package:dartz/dartz.dart';

import 'package:akare/core/error/failures.dart';
import '../entities/property_entity.dart';
import '../entities/property_type_entity.dart';

abstract class PropertiesRepository {
  Future<Either<Failure, List<PropertyTypeEntity>>> getPropertyTypes();

  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties();

  Future<Either<Failure, List<PropertyEntity>>> getLatestProperties({
    required int page,
    int limit = 10,
    int? propertyTypeId, // ← ج
  });

  Future<Either<Failure, Unit>> toggleFavorite(String propertyId);
  // بـ properties_repository.dart (abstract):
  Future<Either<Failure, List<PropertyEntity>>> getFavorites();
}
