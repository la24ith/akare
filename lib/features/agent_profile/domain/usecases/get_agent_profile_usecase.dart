import "package:akare/core/error/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "package:dartz/dartz.dart";

import "../entities/agent_profile_entity.dart";
import "../repositories/agent_profile_repository.dart";

class GetAgentProfileUseCase implements UseCase<AgentProfileEntity, NoParams> {
  final AgentProfileRepository repository;
  GetAgentProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AgentProfileEntity>> call(NoParams params) {
    return repository.getProfile();
  }
}
