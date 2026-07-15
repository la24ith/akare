import "package:dartz/dartz.dart";
import "package:akare/core/error/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "../entities/property_form_lookups_entity.dart";
import "../repositories/property_form_repository.dart";

class GetFormLookupsUseCase
    implements UseCase<PropertyFormLookupsEntity, NoParams> {
  final PropertyFormRepository repository;
  GetFormLookupsUseCase(this.repository);

  @override
  Future<Either<Failure, PropertyFormLookupsEntity>> call(NoParams params) {
    return repository.getLookups();
  }
}
