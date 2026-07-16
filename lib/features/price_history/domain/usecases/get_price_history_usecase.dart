// lib/features/price_history/domain/usecases/get_price_history_usecase.dart
import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/price_point_entity.dart';
import '../repositories/price_history_repository.dart';

class GetPriceHistoryUseCase
    implements UseCase<List<PricePointEntity>, String> {
  final PriceHistoryRepository repository;
  GetPriceHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<PricePointEntity>>> call(String propertyId) {
    return repository.getPriceHistory(propertyId);
  }
}
