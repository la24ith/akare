// lib/features/price_history/data/models/price_point_model.dart
import '../../domain/entities/price_point_entity.dart';

class PricePointModel extends PricePointEntity {
  const PricePointModel({required super.price, required super.changedAt});

  factory PricePointModel.fromSupabase(Map<String, dynamic> row) {
    return PricePointModel(
      price: (row['price'] as num).toDouble(),
      changedAt: DateTime.parse(row['changed_at']),
    );
  }
}
