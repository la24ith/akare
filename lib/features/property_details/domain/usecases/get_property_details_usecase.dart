import 'package:dartz/dartz.dart';

import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import '../entities/property_details_entity.dart';
import '../repositories/property_details_repository.dart';

class GetPropertyDetailsUseCase
    implements UseCase<PropertyDetailsEntity, String> {
  final PropertyDetailsRepository repository;
  GetPropertyDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, PropertyDetailsEntity>> call(String propertyId) {
    return repository.getPropertyDetails(propertyId);
  }
}
