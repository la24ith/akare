import '../../domain/entities/property_details_entity.dart';
import 'agent_model.dart';

class PropertyDetailsModel extends PropertyDetailsEntity {
  const PropertyDetailsModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.listingType,
    required super.propertyTypeName,
    required super.cityName,
    super.addressText,
    super.latitude,
    super.longitude,
    super.roomsCount,
    super.bathroomsCount,
    required super.areaSqm,
    super.imageUrls,
    super.viewsCount,
    super.isFavorite,
    required super.agent,
  });

  /// `row` comes from a query shaped like:
  ///
  /// ```dart
  /// supabase.from('properties').select('''
  ///   id, title, description, price, listing_type, rooms_count,
  ///   bathrooms_count, area_sqm, views_count, address_text, latitude, longitude,
  ///   property_types(name_ar),
  ///   cities(name_ar),
  ///   property_images(image_url, is_primary, sort_order),
  ///   agents(id, company_name, is_verified_agent, users(full_name, avatar_url, phone))
  /// ''').eq('id', propertyId).single()
  /// ```
  factory PropertyDetailsModel.fromSupabase(
    Map<String, dynamic> row, {
    bool isFavorite = false,
    int agentActiveListingsCount = 0,
  }) {
    final images = (row['property_images'] as List? ?? [])
      ..sort((a, b) => (a['sort_order'] ?? 0).compareTo(b['sort_order'] ?? 0));

    return PropertyDetailsModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      listingType: row['listing_type'] ?? 'sale',
      propertyTypeName: row['property_types']?['name_ar'] ?? '',
      cityName: row['cities']?['name_ar'] ?? '',
      addressText: row['address_text'],
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      roomsCount: row['rooms_count'],
      bathroomsCount: row['bathrooms_count'],
      areaSqm: (row['area_sqm'] as num?)?.toDouble() ?? 0,
      imageUrls: images.map((e) => e['image_url'].toString()).toList(),
      viewsCount: row['views_count'] ?? 0,
      isFavorite: isFavorite,
      agent: AgentModel.fromSupabase(row['agents'] ?? {}, activeListingsCount: agentActiveListingsCount),
    );
  }
}
