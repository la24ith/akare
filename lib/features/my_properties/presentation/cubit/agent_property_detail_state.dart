// lib/features/my_properties/presentation/cubit/agent_property_detail_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/agent_property_detail_entity.dart';

enum AgentPropertyDetailStatus { initial, loading, loaded, error }

class AgentPropertyDetailState extends Equatable {
  final AgentPropertyDetailStatus status;
  final AgentPropertyDetailEntity? property;
  final String? errorMessage;
  final bool isActionInProgress;
  final bool wasDeleted;

  const AgentPropertyDetailState({
    this.status = AgentPropertyDetailStatus.initial,
    this.property,
    this.errorMessage,
    this.isActionInProgress = false,
    this.wasDeleted = false,
  });

  AgentPropertyDetailState copyWith({
    AgentPropertyDetailStatus? status,
    AgentPropertyDetailEntity? property,
    String? errorMessage,
    bool? isActionInProgress,
    bool? wasDeleted,
  }) {
    return AgentPropertyDetailState(
      status: status ?? this.status,
      property: property ?? this.property,
      errorMessage: errorMessage,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      wasDeleted: wasDeleted ?? this.wasDeleted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    property,
    errorMessage,
    isActionInProgress,
    wasDeleted,
  ];
}
