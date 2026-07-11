import "package:akare/core/errors/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "package:dartz/dartz.dart";

import "../repositories/my_properties_repository.dart";

class DeletePropertyUseCase implements UseCase<void, String> {
  final MyPropertiesRepository repository;
  DeletePropertyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String propertyId) {
    return repository.deleteProperty(propertyId);
  }
}
