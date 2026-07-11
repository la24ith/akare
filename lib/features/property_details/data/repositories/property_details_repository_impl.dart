import 'package:akare/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/property_details_entity.dart';
import '../../domain/repositories/property_details_repository.dart';
import '../datasources/property_details_remote_datasource.dart';

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  final PropertyDetailsRemoteDataSource remoteDataSource;
  PropertyDetailsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PropertyDetailsEntity>> getPropertyDetails(
    String propertyId,
  ) => _guard(() => remoteDataSource.getPropertyDetails(propertyId));

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String propertyId) =>
      _guard(() async {
        await remoteDataSource.toggleFavorite(propertyId);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> reportProperty({
    required String propertyId,
    required String reason,
  }) => _guard(() async {
    await remoteDataSource.reportProperty(
      propertyId: propertyId,
      reason: reason,
    );
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(
          e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء تحميل البيانات',
        ),
      );
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('تحقق من اتصالك بالإنترنت وحاول مرة أخرى'),
      );
    }
  }
}
