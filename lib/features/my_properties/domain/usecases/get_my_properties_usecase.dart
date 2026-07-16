import "package:akare/core/error/failures.dart";
import "package:akare/core/usecase/usecase.dart";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";

import "../entities/my_property_entity.dart";
import "../repositories/my_properties_repository.dart";

class GetMyPropertiesParams extends Equatable {
  final PropertyStatusFilter filter;
  final int page;
  const GetMyPropertiesParams({required this.filter, required this.page});

  @override
  List<Object?> get props => [filter, page];
}

class GetMyPropertiesUseCase
    implements UseCase<List<MyPropertyEntity>, GetMyPropertiesParams> {
  final MyPropertiesRepository repository;
  GetMyPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MyPropertyEntity>>> call(
    GetMyPropertiesParams params,
  ) {
    return repository.getMyProperties(filter: params.filter, page: params.page);
  }
}
