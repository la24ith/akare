// lib/features/price_history/data/datasources/price_history_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/price_point_model.dart';

abstract class PriceHistoryRemoteDataSource {
  Future<List<PricePointModel>> getPriceHistory(String propertyId);
}

class PriceHistoryRemoteDataSourceImpl implements PriceHistoryRemoteDataSource {
  final SupabaseClient supabase;
  PriceHistoryRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<PricePointModel>> getPriceHistory(String propertyId) async {
    final rows = await supabase
        .from('price_history')
        .select('price, changed_at')
        .eq('property_id', propertyId)
        .order('changed_at', ascending: true);
    return (rows as List).map((r) => PricePointModel.fromSupabase(r)).toList();
  }
}
