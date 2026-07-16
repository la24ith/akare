// lib/features/home/domain/usecases/get_favorites_usecase.dart
import 'package:akare/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/property_entity.dart';
import '../repositories/properties_repository.dart';

class GetFavoritesUseCase implements UseCase<List<PropertyEntity>, NoParams> {
  final PropertiesRepository repository;
  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(NoParams params) =>
      repository.getFavorites();
}
