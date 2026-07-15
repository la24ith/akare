// lib/features/my_properties/domain/usecases/get_my_property_detail_usecase.dart
import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/agent_property_detail_entity.dart';
import '../repositories/my_properties_repository.dart';

class GetMyPropertyDetailUseCase
    implements UseCase<AgentPropertyDetailEntity, String> {
  final MyPropertiesRepository repository;
  GetMyPropertyDetailUseCase(this.repository);

  @override
  Future<Either<Failure, AgentPropertyDetailEntity>> call(String propertyId) {
    return repository.getPropertyDetail(propertyId);
  }
}
