import 'package:dartz/dartz.dart';
import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import '../repositories/property_details_repository.dart';

class ToggleFavoriteUseCase implements UseCase<Unit, String> {
  final PropertyDetailsRepository repository;
  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String propertyId) {
    return repository.toggleFavorite(propertyId);
  }
}
