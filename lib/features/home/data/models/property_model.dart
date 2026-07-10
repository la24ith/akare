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

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // NOTE: adjust keys to match the actual Laravel API response shape,
    // same as the `file_url`/`url` fix applied in the posts feature.
    return PropertyModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      listingType: json['listing_type'] ?? 'sale',
      propertyTypeName: json['property_type']?['name_ar'] ?? '',
      cityName: json['city']?['name_ar'] ?? '',
      roomsCount: json['rooms_count'],
      bathroomsCount: json['bathrooms_count'],
      areaSqm: double.tryParse(json['area_sqm'].toString()) ?? 0,
      mainImageUrl: json['main_image_url'] ?? json['primary_image']?['image_url'],
      viewsCount: json['views_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
