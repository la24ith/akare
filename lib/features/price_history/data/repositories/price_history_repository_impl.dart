// lib/features/price_history/data/repositories/price_history_repository_impl.dart
import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/price_point_entity.dart';
import '../../domain/repositories/price_history_repository.dart';
import '../datasources/price_history_remote_datasource.dart';

class PriceHistoryRepositoryImpl implements PriceHistoryRepository {
  final PriceHistoryRemoteDataSource remoteDataSource;
  PriceHistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PricePointEntity>>> getPriceHistory(
    String propertyId,
  ) async {
    try {
      return Right(await remoteDataSource.getPriceHistory(propertyId));
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(
          e.message.isNotEmpty ? e.message : 'تعذّر تحميل تاريخ الأسعار',
        ),
      );
    } catch (_) {
      return const Left(ServerFailure('تحقق من اتصالك بالإنترنت'));
    }
  }
}
