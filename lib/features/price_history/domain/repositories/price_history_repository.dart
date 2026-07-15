// lib/features/price_history/domain/repositories/price_history_repository.dart
import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/price_point_entity.dart';

abstract class PriceHistoryRepository {
  Future<Either<Failure, List<PricePointEntity>>> getPriceHistory(
    String propertyId,
  );
}
