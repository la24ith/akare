import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../../home/domain/entities/property_entity.dart';
import '../entities/city_entity.dart';
import '../entities/property_filter.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<CityEntity>>> getCities();

  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    required PropertyFilter filter,
    required int page,
    int limit = 10,
  });
}
