import "dart:io";
import "package:akare/core/error/failures.dart";
import "package:dartz/dartz.dart";
import "package:postgrest/postgrest.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../domain/entities/property_edit_data_entity.dart";
import "../../domain/entities/property_form_lookups_entity.dart";
import "../../domain/entities/property_submit_data.dart";
import "../../domain/repositories/property_form_repository.dart";
import "../datasources/property_form_remote_datasource.dart";

class PropertyFormRepositoryImpl implements PropertyFormRepository {
  final PropertyFormRemoteDataSource remoteDataSource;
  final SupabaseClient client;
  PropertyFormRepositoryImpl(this.remoteDataSource, this.client);

  Future<String> get _agentId async {
    final uid = client.auth.currentUser!.id;
    final row = await client
        .from("agents")
        .select("id")
        .eq("user_id", uid)
        .single();
    return row["id"] as String;
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(_mapPgError(e)));
    } on StorageException catch (_) {
      return const Left(ServerFailure("تعذّر رفع الصورة، حاول مرة أخرى"));
    } on AuthException catch (_) {
      return const Left(
        ServerFailure("انتهت الجلسة، الرجاء تسجيل الدخول من جديد"),
      );
    } catch (_) {
      return const Left(ServerFailure("حدث خطأ غير متوقع، حاول مرة أخرى"));
    }
  }

  String _mapPgError(PostgrestException e) {
    if (e.code == "23502") return "الرجاء تعبئة جميع الحقول المطلوبة";
    if (e.code == "42501") return "لا تملك صلاحية تنفيذ هذا الإجراء";
    return "تعذّر حفظ العقار، تحقق من البيانات وحاول مرة أخرى";
  }

  @override
  Future<Either<Failure, PropertyFormLookupsEntity>> getLookups() {
    return _guard(() async {
      final types = await remoteDataSource.getPropertyTypes();
      final cities = await remoteDataSource.getCities();
      return PropertyFormLookupsEntity(propertyTypes: types, cities: cities);
    });
  }

  @override
  Future<Either<Failure, PropertyEditDataEntity>> getPropertyForEdit(
    String propertyId,
  ) {
    return _guard(() => remoteDataSource.getPropertyForEdit(propertyId));
  }

  @override
  Future<Either<Failure, String>> submitProperty({
    required PropertySubmitData data,
    String? editingPropertyId,
  }) {
    return _guard(() async {
      final agentId = await _agentId;
      return remoteDataSource.submitProperty(
        data.toJson(agentId),
        editingPropertyId,
      );
    });
  }

  @override
  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String propertyId,
    required bool isPrimary,
    required int sortOrder,
  }) {
    return _guard(
      () => remoteDataSource.uploadImage(
        file: file,
        propertyId: propertyId,
        isPrimary: isPrimary,
        sortOrder: sortOrder,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageId) {
    return _guard(() => remoteDataSource.deleteImage(imageId));
  }

  @override
  Future<Either<Failure, void>> setPrimaryImage({
    required String propertyId,
    required String imageId,
  }) {
    return _guard(
      () => remoteDataSource.setPrimaryImage(
        propertyId: propertyId,
        imageId: imageId,
      ),
    );
  }
}
