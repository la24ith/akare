import "package:dartz/dartz.dart";
import "package:akare/core/errors/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "../entities/property_edit_data_entity.dart";
import "../repositories/property_form_repository.dart";

class GetPropertyForEditUseCase
    implements UseCase<PropertyEditDataEntity, String> {
  final PropertyFormRepository repository;
  GetPropertyForEditUseCase(this.repository);

  @override
  Future<Either<Failure, PropertyEditDataEntity>> call(String propertyId) {
    return repository.getPropertyForEdit(propertyId);
  }
}
