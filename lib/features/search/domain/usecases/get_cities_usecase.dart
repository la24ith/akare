import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import 'package:dartz/dartz.dart';

import 'package:akare/core/constants/app_colors.dart';

import '../entities/city_entity.dart';
import '../repositories/search_repository.dart';

class GetCitiesUseCase implements UseCase<List<CityEntity>, NoParams> {
  final SearchRepository repository;
  GetCitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CityEntity>>> call(NoParams params) {
    return repository.getCities();
  }
}
