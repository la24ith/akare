import "package:equatable/equatable.dart";
import "property_image_entity.dart";

/// بيانات العقار الكاملة عند فتح فورم التعديل
class PropertyEditDataEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String listingType;
  final int propertyTypeId;
  final int cityId;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final int? roomsCount;
  final int? bathroomsCount;
  final double areaSqm;
  final List<PropertyImageEntity> images;

  const PropertyEditDataEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    required this.propertyTypeId,
    required this.cityId,
    this.addressText,
    this.latitude,
    this.longitude,
    this.roomsCount,
    this.bathroomsCount,
    required this.areaSqm,
    required this.images,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        listingType,
        propertyTypeId,
        cityId,
        addressText,
        latitude,
        longitude,
        roomsCount,
        bathroomsCount,
        areaSqm,
        images,
      ];
}
