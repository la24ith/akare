import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecase/usecase.dart';

import '../entities/property_entity.dart';
import '../repositories/properties_repository.dart';

class GetLatestPropertiesParams extends Equatable {
  final int page;
  final int limit;
  final int? propertyTypeId; // ← جديد

  const GetLatestPropertiesParams({
    required this.page,
    this.limit = 10,
    this.propertyTypeId, // ← جديد
  });

  @override
  List<Object?> get props => [page, limit, propertyTypeId]; // ← أضفناه هون كمان (مهم جدًا)
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
      propertyTypeId: params.propertyTypeId, // ← جديد
    );
  }
}
