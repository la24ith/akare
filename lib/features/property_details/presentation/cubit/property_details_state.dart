import 'package:equatable/equatable.dart';

import '../../domain/entities/property_details_entity.dart';

enum PropertyDetailsStatus { initial, loading, loaded, error }

class PropertyDetailsState extends Equatable {
  final PropertyDetailsStatus status;
  final PropertyDetailsEntity? property;
  final String? errorMessage;
  final bool isSubmittingReport;
  final bool reportSubmitted;

  const PropertyDetailsState({
    this.status = PropertyDetailsStatus.initial,
    this.property,
    this.errorMessage,
    this.isSubmittingReport = false,
    this.reportSubmitted = false,
  });

  PropertyDetailsState copyWith({
    PropertyDetailsStatus? status,
    PropertyDetailsEntity? property,
    String? errorMessage,
    bool? isSubmittingReport,
    bool? reportSubmitted,
  }) {
    return PropertyDetailsState(
      status: status ?? this.status,
      property: property ?? this.property,
      errorMessage: errorMessage,
      isSubmittingReport: isSubmittingReport ?? this.isSubmittingReport,
      reportSubmitted: reportSubmitted ?? this.reportSubmitted,
    );
  }

  @override
  List<Object?> get props =>
      [status, property, errorMessage, isSubmittingReport, reportSubmitted];
}
