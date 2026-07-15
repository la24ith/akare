import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// الـ domain layer بيعرف بس "الشكل" (interface) — التنفيذ الفعلي في data layer.
/// كده لو غيّرت مصدر البيانات (Supabase -> أي شيء آخر) الـ usecases مش هتتأثر.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> logout();
}
