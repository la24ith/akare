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
  factory PropertyModel.fromSupabase(
    Map<String, dynamic> row, {
    bool isFavorite = false,
  }) {
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
  // أضف داخل PropertyModel (home/data/models/property_model.dart)

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'listing_type': listingType,
    'property_type_name': propertyTypeName,
    'city_name': cityName,
    'rooms_count': roomsCount,
    'bathrooms_count': bathroomsCount,
    'area_sqm': areaSqm,
    'main_image_url': mainImageUrl,
    'views_count': viewsCount,
    'is_favorite': isFavorite,
  };

  factory PropertyModel.fromCacheJson(Map<String, dynamic> json) =>
      PropertyModel(
        id: json['id'],
        title: json['title'],
        price: (json['price'] as num).toDouble(),
        listingType: json['listing_type'],
        propertyTypeName: json['property_type_name'],
        cityName: json['city_name'],
        roomsCount: json['rooms_count'],
        bathroomsCount: json['bathrooms_count'],
        areaSqm: (json['area_sqm'] as num).toDouble(),
        mainImageUrl: json['main_image_url'],
        viewsCount: json['views_count'] ?? 0,
        isFavorite: json['is_favorite'] ?? false,
      );
}
