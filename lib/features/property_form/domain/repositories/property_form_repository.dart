import "dart:io";
import "package:akare/core/error/failures.dart";
import "package:dartz/dartz.dart";
import "../entities/property_edit_data_entity.dart";
import "../entities/property_form_lookups_entity.dart";
import "../entities/property_submit_data.dart";

abstract class PropertyFormRepository {
  Future<Either<Failure, PropertyFormLookupsEntity>> getLookups();

  Future<Either<Failure, PropertyEditDataEntity>> getPropertyForEdit(
    String propertyId,
  );

  /// يرجّع id العقار (جديد أو نفسه بحالة التعديل)
  Future<Either<Failure, String>> submitProperty({
    required PropertySubmitData data,
    String? editingPropertyId,
  });

  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String propertyId,
    required bool isPrimary,
    required int sortOrder,
  });

  Future<Either<Failure, void>> deleteImage(String imageId);

  Future<Either<Failure, void>> setPrimaryImage({
    required String propertyId,
    required String imageId,
  });
}
