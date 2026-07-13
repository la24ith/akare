// lib/features/my_properties/data/models/agent_property_detail_model.dart
import '../../domain/entities/agent_property_detail_entity.dart';

class AgentPropertyDetailModel extends AgentPropertyDetailEntity {
  const AgentPropertyDetailModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.listingType,
    required super.propertyTypeName,
    required super.cityName,
    required super.status,
    super.rejectionReason,
    super.addressText,
    super.latitude,
    super.longitude,
    super.roomsCount,
    super.bathroomsCount,
    required super.areaSqm,
    super.imageUrls,
    super.viewsCount,
    super.favoritesCount,
  });

  factory AgentPropertyDetailModel.fromSupabase(
    Map<String, dynamic> row, {
    int favoritesCount = 0,
  }) {
    final images = (row['property_images'] as List? ?? [])
      ..sort((a, b) => (a['sort_order'] ?? 0).compareTo(b['sort_order'] ?? 0));

    return AgentPropertyDetailModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      listingType: row['listing_type'] ?? 'sale',
      propertyTypeName: row['property_types']?['name_ar'] ?? '',
      cityName: row['cities']?['name_ar'] ?? '',
      status: row['status'] ?? 'pending',
      rejectionReason: row['rejection_reason'],
      addressText: row['address_text'],
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      roomsCount: row['rooms_count'],
      bathroomsCount: row['bathrooms_count'],
      areaSqm: (row['area_sqm'] as num?)?.toDouble() ?? 0,
      imageUrls: images.map((e) => e['image_url'].toString()).toList(),
      viewsCount: row['views_count'] ?? 0,
      favoritesCount: favoritesCount,
    );
  }
}
