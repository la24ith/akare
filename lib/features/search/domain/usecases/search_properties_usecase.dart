import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../entities/property_filter.dart';
import '../repositories/search_repository.dart';

class SearchPropertiesParams extends Equatable {
  final PropertyFilter filter;
  final int page;
  final int limit;
  const SearchPropertiesParams({
    required this.filter,
    required this.page,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [filter, page, limit];
}

class SearchPropertiesUseCase
    implements UseCase<List<PropertyEntity>, SearchPropertiesParams> {
  final SearchRepository repository;
  SearchPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(
    SearchPropertiesParams params,
  ) {
    return repository.searchProperties(
      filter: params.filter,
      page: params.page,
      limit: params.limit,
    );
  }
}
