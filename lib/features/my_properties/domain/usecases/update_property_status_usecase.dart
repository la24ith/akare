import "package:akare/core/error/failures.dart";
import "package:akare/core/usecase/usecase.dart";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";

import "../repositories/my_properties_repository.dart";

class UpdatePropertyStatusParams extends Equatable {
  final String propertyId;
  final String newStatus;
  const UpdatePropertyStatusParams({
    required this.propertyId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [propertyId, newStatus];
}

class UpdatePropertyStatusUseCase
    implements UseCase<void, UpdatePropertyStatusParams> {
  final MyPropertiesRepository repository;
  UpdatePropertyStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePropertyStatusParams params) {
    return repository.updatePropertyStatus(
      propertyId: params.propertyId,
      newStatus: params.newStatus,
    );
  }
}
