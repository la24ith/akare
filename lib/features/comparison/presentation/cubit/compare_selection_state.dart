// lib/features/comparison/presentation/cubit/compare_selection_state.dart
import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/property_entity.dart';

class CompareSelectionState extends Equatable {
  static const maxItems = 4;

  final List<PropertyEntity> selected;
  const CompareSelectionState({this.selected = const []});

  bool get isFull => selected.length >= maxItems;
  bool get canCompare => selected.length >= 2;

  bool isSelected(String propertyId) => selected.any((p) => p.id == propertyId);

  @override
  List<Object?> get props => [selected];
}
