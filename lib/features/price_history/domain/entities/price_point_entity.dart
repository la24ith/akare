// lib/features/price_history/domain/entities/price_point_entity.dart
import 'package:equatable/equatable.dart';

class PricePointEntity extends Equatable {
  final double price;
  final DateTime changedAt;

  const PricePointEntity({required this.price, required this.changedAt});

  @override
  List<Object?> get props => [price, changedAt];
}
