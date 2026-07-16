// lib/features/profile/domain/usecases/upload_avatar_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';
import 'package:akare/core/usecase/usecase.dart';

class UploadAvatarUseCase implements UseCase<String, String> {
  final ProfileRepository repository;
  UploadAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String localFilePath) =>
      repository.uploadAvatar(localFilePath);
}
