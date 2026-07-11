import "package:akare/core/errors/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "package:dartz/dartz.dart";

import "../repositories/agent_profile_repository.dart";

class SignOutUseCase implements UseCase<void, NoParams> {
  final AgentProfileRepository repository;
  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
