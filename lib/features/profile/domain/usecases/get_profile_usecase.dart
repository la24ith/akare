// lib/features/profile/domain/usecases/get_profile_usecase.dart
import 'package:akare/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<UserProfileEntity, NoParams> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(NoParams params) =>
      repository.getProfile();
}
