import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/domain/entities/property_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CityEntity>>> getCities() =>
      _guard(() => remoteDataSource.getCities());

  @override
  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    required PropertyFilter filter,
    required int page,
    int limit = 10,
  }) => _guard(
    () => remoteDataSource.searchProperties(
      filter: filter,
      page: page,
      limit: limit,
    ),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(e.message.isNotEmpty ? e.message : 'حدث خطأ أثناء البحث'),
      );
    } catch (_) {
      return const Left(
        ServerFailure('تحقق من اتصالك بالإنترنت وحاول مرة أخرى'),
      );
    }
  }
}
