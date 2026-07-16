// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();

  Future<Either<Failure, UserProfileEntity>> updateProfile({
    required String fullName,
    required String phone,
  });

  /// يرفع الصورة لـ Storage ويحدّث avatar_url بجدول users، ويرجع الرابط الجديد.
  Future<Either<Failure, String>> uploadAvatar(String localFilePath);
}
