import "package:akare/core/error/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "package:dartz/dartz.dart";

import "../repositories/property_form_repository.dart";

class DeletePropertyImageUseCase implements UseCase<void, String> {
  final PropertyFormRepository repository;
  DeletePropertyImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String imageId) {
    return repository.deleteImage(imageId);
  }
}
