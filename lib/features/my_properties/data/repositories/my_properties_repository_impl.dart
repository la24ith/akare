import "package:akare/core/error/failures.dart";
import "package:akare/features/my_properties/domain/entities/agent_property_detail_entity.dart";
import "package:dartz/dartz.dart";
import "package:postgrest/postgrest.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../domain/entities/my_property_entity.dart";
import "../../domain/repositories/my_properties_repository.dart";
import "../datasources/my_properties_remote_datasource.dart";

class MyPropertiesRepositoryImpl implements MyPropertiesRepository {
  final MyPropertiesRemoteDataSource remoteDataSource;
  MyPropertiesRepositoryImpl(this.remoteDataSource);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(_mapError(e)));
    } on AuthException catch (_) {
      return const Left(
        ServerFailure("انتهت الجلسة، الرجاء تسجيل الدخول من جديد"),
      );
    } catch (_) {
      return const Left(ServerFailure("حدث خطأ غير متوقع، حاول مرة أخرى"));
    }
  }

  String _mapError(PostgrestException e) {
    if (e.code == "42501") return "لا تملك صلاحية تنفيذ هذا الإجراء";
    return "تعذّر تنفيذ العملية، حاول مرة أخرى";
  }

  @override
  Future<Either<Failure, List<MyPropertyEntity>>> getMyProperties({
    required PropertyStatusFilter filter,
    required int page,
    int pageSize = 10,
  }) {
    return _guard(
      () => remoteDataSource.getMyProperties(
        filter: filter,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String propertyId) {
    return _guard(() => remoteDataSource.deleteProperty(propertyId));
  }

  @override
  Future<Either<Failure, void>> updatePropertyStatus({
    required String propertyId,
    required String newStatus,
  }) {
    return _guard(
      () => remoteDataSource.updatePropertyStatus(propertyId, newStatus),
    );
  }

  @override
  Future<Either<Failure, AgentPropertyDetailEntity>> getPropertyDetail(
    String propertyId,
  ) => _guard(() => remoteDataSource.getPropertyDetail(propertyId));
}
