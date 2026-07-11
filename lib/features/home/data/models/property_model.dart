import '../../domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.price,
    required super.listingType,
    required super.propertyTypeName,
    required super.cityName,
    super.roomsCount,
    super.bathroomsCount,
    required super.areaSqm,
    super.mainImageUrl,
    super.viewsCount,
    super.isFavorite,
  });

  /// Builds a model from a Supabase row. `property_types` and `cities` come
  /// back as embedded maps (many-to-one FK), `property_images` as an
  /// embedded list (one-to-many) when selected like:
  ///
  /// ```dart
  /// supabase.from('properties').select('''
  ///   id, title, price, listing_type, rooms_count, bathrooms_count,
  ///   area_sqm, views_count,
  ///   property_types(name_ar),
  ///   cities(name_ar),
  ///   property_images(image_url, is_primary)
  /// ''')
  /// ```
  ///
  /// [isFavorite] is resolved separately (against the current user's
  /// favorites) and passed in by the repository, since Postgres has no
  /// per-row "is this mine" concept without a join on `auth.uid()`.
  factory PropertyModel.fromSupabase(Map<String, dynamic> row, {bool isFavorite = false}) {
    final images = (row['property_images'] as List? ?? []);
    String? mainImage;
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img['is_primary'] == true,
        orElse: () => images.first,
      );
      mainImage = primary['image_url'] as String?;
    }

    return PropertyModel(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      listingType: row['listing_type'] ?? 'sale',
      propertyTypeName: row['property_types']?['name_ar'] ?? '',
      cityName: row['cities']?['name_ar'] ?? '',
      roomsCount: row['rooms_count'],
      bathroomsCount: row['bathrooms_count'],
      areaSqm: (row['area_sqm'] as num?)?.toDouble() ?? 0,
      mainImageUrl: mainImage,
      viewsCount: row['views_count'] ?? 0,
      isFavorite: isFavorite,
    );
  }
}
