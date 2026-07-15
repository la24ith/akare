import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:akare/core/error/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "../entities/property_submit_data.dart";
import "../repositories/property_form_repository.dart";

class SubmitPropertyParams extends Equatable {
  final PropertySubmitData data;
  final String? editingPropertyId;
  const SubmitPropertyParams({required this.data, this.editingPropertyId});

  @override
  List<Object?> get props => [data, editingPropertyId];
}

class SubmitPropertyUseCase implements UseCase<String, SubmitPropertyParams> {
  final PropertyFormRepository repository;
  SubmitPropertyUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SubmitPropertyParams params) {
    return repository.submitProperty(
      data: params.data,
      editingPropertyId: params.editingPropertyId,
    );
  }
}
