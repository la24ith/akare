import 'package:dartz/dartz.dart';
import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecase/usecase.dart';
import '../entities/property_entity.dart';
import '../repositories/properties_repository.dart';

class GetFeaturedPropertiesUseCase
    implements UseCase<List<PropertyEntity>, NoParams> {
  final PropertiesRepository repository;
  GetFeaturedPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(NoParams params) {
    return repository.getFeaturedProperties();
  }
}
