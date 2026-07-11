import "package:akare/core/errors/failures.dart";
import "package:dartz/dartz.dart";
import "../entities/agent_profile_entity.dart";

abstract class AgentProfileRepository {
  Future<Either<Failure, AgentProfileEntity>> getProfile();

  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    String? companyName,
    String? licenseNumber,
    String? bio,
  });

  Future<Either<Failure, void>> signOut();
}
