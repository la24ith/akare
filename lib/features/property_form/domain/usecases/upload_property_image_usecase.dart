import "dart:io";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:akare/core/error/failures.dart";
import "package:akare/core/usecase/usecase.dart";
import "../repositories/property_form_repository.dart";

class UploadPropertyImageParams extends Equatable {
  final File file;
  final String propertyId;
  final bool isPrimary;
  final int sortOrder;

  const UploadPropertyImageParams({
    required this.file,
    required this.propertyId,
    required this.isPrimary,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [file.path, propertyId, isPrimary, sortOrder];
}

class UploadPropertyImageUseCase
    implements UseCase<String, UploadPropertyImageParams> {
  final PropertyFormRepository repository;
  UploadPropertyImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadPropertyImageParams params) {
    return repository.uploadImage(
      file: params.file,
      propertyId: params.propertyId,
      isPrimary: params.isPrimary,
      sortOrder: params.sortOrder,
    );
  }
}
