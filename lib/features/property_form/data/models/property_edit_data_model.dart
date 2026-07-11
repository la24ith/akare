import "../../domain/entities/property_edit_data_entity.dart";
import "../../domain/entities/property_image_entity.dart";

class PropertyEditDataModel extends PropertyEditDataEntity {
  const PropertyEditDataModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.listingType,
    required super.propertyTypeId,
    required super.cityId,
    super.addressText,
    super.latitude,
    super.longitude,
    super.roomsCount,
    super.bathroomsCount,
    required super.areaSqm,
    required super.images,
  });

  factory PropertyEditDataModel.fromSupabase(Map<String, dynamic> json) {
    final imagesJson = (json["property_images"] as List?) ?? [];
    final images = imagesJson
        .map((img) => PropertyImageEntity(
              id: img["id"] as String,
              remoteUrl: img["image_url"] as String,
              isPrimary: img["is_primary"] as bool? ?? false,
              sortOrder: (img["sort_order"] as num?)?.toInt() ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return PropertyEditDataModel(
      id: json["id"] as String,
      title: json["title"] as String,
      description: json["description"] as String,
      price: (json["price"] as num).toDouble(),
      listingType: json["listing_type"] as String,
      propertyTypeId: json["property_type_id"] as int,
      cityId: json["city_id"] as int,
      addressText: json["address_text"] as String?,
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      roomsCount: (json["rooms_count"] as num?)?.toInt(),
      bathroomsCount: (json["bathrooms_count"] as num?)?.toInt(),
      areaSqm: (json["area_sqm"] as num).toDouble(),
      images: images,
    );
  }
}
