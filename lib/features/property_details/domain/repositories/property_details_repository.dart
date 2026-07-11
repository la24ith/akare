import 'package:akare/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/property_details_entity.dart';

abstract class PropertyDetailsRepository {
  Future<Either<Failure, PropertyDetailsEntity>> getPropertyDetails(
    String propertyId,
  );

  Future<Either<Failure, Unit>> toggleFavorite(String propertyId);

  Future<Either<Failure, Unit>> reportProperty({
    required String propertyId,
    required String reason,
  });
}
