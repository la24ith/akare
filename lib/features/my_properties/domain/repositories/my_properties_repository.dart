import "package:akare/core/errors/failures.dart";
import "package:dartz/dartz.dart";

import "../entities/my_property_entity.dart";

abstract class MyPropertiesRepository {
  Future<Either<Failure, List<MyPropertyEntity>>> getMyProperties({
    required PropertyStatusFilter filter,
    required int page,
    int pageSize = 10,
  });

  Future<Either<Failure, void>> deleteProperty(String propertyId);

  /// active -> sold | active -> rented فقط (يُفرض هذا أيضًا من الـ RLS)
  Future<Either<Failure, void>> updatePropertyStatus({
    required String propertyId,
    required String newStatus,
  });
}
