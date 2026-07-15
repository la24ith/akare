import "package:akare/core/error/failures.dart";
import "package:akare/core/usecace/usecase.dart";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";

import "../repositories/agent_profile_repository.dart";

class UpdateAgentProfileParams extends Equatable {
  final String fullName;
  final String? companyName;
  final String? licenseNumber;
  final String? bio;

  const UpdateAgentProfileParams({
    required this.fullName,
    this.companyName,
    this.licenseNumber,
    this.bio,
  });

  @override
  List<Object?> get props => [fullName, companyName, licenseNumber, bio];
}

class UpdateAgentProfileUseCase
    implements UseCase<void, UpdateAgentProfileParams> {
  final AgentProfileRepository repository;
  UpdateAgentProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateAgentProfileParams params) {
    return repository.updateProfile(
      fullName: params.fullName,
      companyName: params.companyName,
      licenseNumber: params.licenseNumber,
      bio: params.bio,
    );
  }
}
