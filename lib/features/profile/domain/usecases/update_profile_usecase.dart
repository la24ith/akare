// lib/features/profile/domain/usecases/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';
import 'package:akare/core/usecase/usecase.dart';

class UpdateProfileParams extends Equatable {
  final String fullName;
  final String phone;
  const UpdateProfileParams({required this.fullName, required this.phone});

  @override
  List<Object?> get props => [fullName, phone];
}

class UpdateProfileUseCase
    implements UseCase<UserProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      fullName: params.fullName,
      phone: params.phone,
    );
  }
}
