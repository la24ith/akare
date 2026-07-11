import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';

import '../entities/property_entity.dart';
import '../repositories/properties_repository.dart';

class GetLatestPropertiesParams extends Equatable {
  final int page;
  final int limit;
  const GetLatestPropertiesParams({required this.page, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class GetLatestPropertiesUseCase
    implements UseCase<List<PropertyEntity>, GetLatestPropertiesParams> {
  final PropertiesRepository repository;
  GetLatestPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(
    GetLatestPropertiesParams params,
  ) {
    return repository.getLatestProperties(
      page: params.page,
      limit: params.limit,
    );
  }
}
