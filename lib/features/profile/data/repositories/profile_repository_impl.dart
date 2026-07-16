// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() =>
      _guard(() => remoteDataSource.getProfile());

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile({
    required String fullName,
    required String phone,
  }) => _guard(
    () => remoteDataSource.updateProfile(fullName: fullName, phone: phone),
  );

  @override
  Future<Either<Failure, String>> uploadAvatar(String localFilePath) =>
      _guard(() => remoteDataSource.uploadAvatar(localFilePath));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message.isNotEmpty ? e.message : 'حدث خطأ'));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on StorageException catch (e) {
      return Left(
        ServerFailure(e.message.isNotEmpty ? e.message : 'تعذّر رفع الصورة'),
      );
    } catch (_) {
      return const Left(ServerFailure('تحقق من اتصالك بالإنترنت'));
    }
  }
}
