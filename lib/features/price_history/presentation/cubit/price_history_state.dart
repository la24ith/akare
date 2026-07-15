// lib/features/price_history/presentation/cubit/price_history_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/price_point_entity.dart';

enum PriceHistoryStatus { initial, loading, loaded, error }

class PriceHistoryState extends Equatable {
  final PriceHistoryStatus status;
  final List<PricePointEntity> points;
  final String? errorMessage;

  const PriceHistoryState({
    this.status = PriceHistoryStatus.initial,
    this.points = const [],
    this.errorMessage,
  });

  PriceHistoryState copyWith({
    PriceHistoryStatus? status,
    List<PricePointEntity>? points,
    String? errorMessage,
  }) {
    return PriceHistoryState(
      status: status ?? this.status,
      points: points ?? this.points,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, points, errorMessage];
}
