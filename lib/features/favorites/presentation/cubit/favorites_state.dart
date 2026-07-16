// lib/features/favorites/presentation/cubit/favorites_state.dart
import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/property_entity.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<PropertyEntity> properties;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.properties = const [],
    this.errorMessage,
  });

  bool get isEmpty => status == FavoritesStatus.loaded && properties.isEmpty;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<PropertyEntity>? properties,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, properties, errorMessage];
}
