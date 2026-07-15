import "package:akare/core/error/failures.dart";
import "package:dartz/dartz.dart";
import "package:postgrest/postgrest.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../domain/entities/agent_profile_entity.dart";
import "../../domain/repositories/agent_profile_repository.dart";
import "../datasources/agent_profile_remote_datasource.dart";

class AgentProfileRepositoryImpl implements AgentProfileRepository {
  final AgentProfileRemoteDataSource remoteDataSource;
  AgentProfileRepositoryImpl(this.remoteDataSource);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on PostgrestException catch (_) {
      return const Left(ServerFailure("تعذّر تنفيذ العملية، حاول مرة أخرى"));
    } on AuthException catch (_) {
      return const Left(
        ServerFailure("انتهت الجلسة، الرجاء تسجيل الدخول من جديد"),
      );
    } catch (_) {
      return const Left(ServerFailure("حدث خطأ غير متوقع، حاول مرة أخرى"));
    }
  }

  @override
  Future<Either<Failure, AgentProfileEntity>> getProfile() {
    return _guard(() => remoteDataSource.getProfile());
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    String? companyName,
    String? licenseNumber,
    String? bio,
  }) {
    return _guard(
      () => remoteDataSource.updateProfile(
        fullName: fullName,
        companyName: companyName,
        licenseNumber: licenseNumber,
        bio: bio,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return _guard(() => remoteDataSource.signOut());
  }
}
