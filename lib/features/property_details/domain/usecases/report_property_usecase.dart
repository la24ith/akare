import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import '../repositories/property_details_repository.dart';

class ReportPropertyParams extends Equatable {
  final String propertyId;
  final String reason;
  const ReportPropertyParams({required this.propertyId, required this.reason});

  @override
  List<Object?> get props => [propertyId, reason];
}

class ReportPropertyUseCase implements UseCase<Unit, ReportPropertyParams> {
  final PropertyDetailsRepository repository;
  ReportPropertyUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ReportPropertyParams params) {
    return repository.reportProperty(
      propertyId: params.propertyId,
      reason: params.reason,
    );
  }
}
