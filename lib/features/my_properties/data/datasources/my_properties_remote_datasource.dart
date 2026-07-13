import "package:akare/core/network/supabase_client.dart";
import "package:akare/features/my_properties/data/models/agent_property_detail_model.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../domain/entities/my_property_entity.dart";
import "../models/my_property_model.dart";

abstract class MyPropertiesRemoteDataSource {
  Future<List<MyPropertyModel>> getMyProperties({
    required PropertyStatusFilter filter,
    required int page,
    required int pageSize,
  });
  Future<void> deleteProperty(String propertyId);
  Future<void> updatePropertyStatus(String propertyId, String newStatus);
  Future<AgentPropertyDetailModel> getPropertyDetail(String propertyId);
}

class MyPropertiesRemoteDataSourceImpl implements MyPropertiesRemoteDataSource {
  final SupabaseClient client;
  MyPropertiesRemoteDataSourceImpl(this.client);
  @override
  @override
  Future<AgentPropertyDetailModel> getPropertyDetail(String propertyId) async {
    try {
      final row = await supabase
          .from('properties')
          .select('''
    id, title, description, price, listing_type, status, rejection_reason,
    rooms_count, bathrooms_count, area_sqm, views_count, address_text,
    latitude, longitude,
    property_types(name_ar), cities(name_ar),
    property_images(image_url, is_primary, sort_order)
  ''')
          .eq('id', propertyId)
          .single();

      final favRows = await supabase
          .from('favorites')
          .select('id')
          .eq('property_id', propertyId);

      return AgentPropertyDetailModel.fromSupabase(
        row,
        favoritesCount: (favRows as List).length,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('❌ GET PROPERTY DETAIL ERROR: $e');
      print('❌ STACK: $st');
      rethrow;
    }
  }

  Future<String> get _agentId async {
    final uid = client.auth.currentUser!.id;
    final row = await client
        .from("agents")
        .select("id")
        .eq("user_id", uid)
        .single();
    return row["id"] as String;
  }

  String? _statusValue(PropertyStatusFilter filter) {
    switch (filter) {
      case PropertyStatusFilter.all:
        return null;
      case PropertyStatusFilter.pending:
        return "pending";
      case PropertyStatusFilter.active:
        return "active";
      case PropertyStatusFilter.rejected:
        return "rejected";
      case PropertyStatusFilter.sold:
        return "sold";
      case PropertyStatusFilter.rented:
        return "rented";
    }
  }

  @override
  Future<List<MyPropertyModel>> getMyProperties({
    required PropertyStatusFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final agentId = await _agentId;
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = client
        .from("properties")
        .select(
          "*, property_images(image_url, is_primary), cities(name_ar), property_types(name_ar)",
        )
        .eq("agent_id", agentId);

    final statusValue = _statusValue(filter);
    if (statusValue != null) {
      query = query.eq("status", statusValue);
    }

    final rows = await query
        .order("created_at", ascending: false)
        .range(from, to);

    return (rows as List)
        .map((row) => MyPropertyModel.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    await client.from("properties").delete().eq("id", propertyId);
  }

  @override
  Future<void> updatePropertyStatus(String propertyId, String newStatus) async {
    await client
        .from("properties")
        .update({"status": newStatus})
        .eq("id", propertyId);
  }
}
