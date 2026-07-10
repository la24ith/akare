import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/property_type_entity.dart';
import '../repositories/properties_repository.dart';

class GetPropertyTypesUseCase
    implements UseCase<List<PropertyTypeEntity>, NoParams> {
  final PropertiesRepository repository;
  GetPropertyTypesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PropertyTypeEntity>>> call(NoParams params) {
    return repository.getPropertyTypes();
  }
}
