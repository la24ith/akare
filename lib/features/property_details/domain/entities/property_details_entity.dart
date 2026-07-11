import 'package:equatable/equatable.dart';

import 'agent_entity.dart';

class PropertyDetailsEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String listingType; // 'sale' | 'rent'
  final String propertyTypeName;
  final String cityName;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final int? roomsCount;
  final int? bathroomsCount;
  final double areaSqm;
  final List<String> imageUrls;
  final int viewsCount;
  final bool isFavorite;
  final AgentEntity agent;

  const PropertyDetailsEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    required this.propertyTypeName,
    required this.cityName,
    this.addressText,
    this.latitude,
    this.longitude,
    this.roomsCount,
    this.bathroomsCount,
    required this.areaSqm,
    this.imageUrls = const [],
    this.viewsCount = 0,
    this.isFavorite = false,
    required this.agent,
  });

  bool get isForSale => listingType == 'sale';
  bool get hasLocation => latitude != null && longitude != null;

  PropertyDetailsEntity copyWith({bool? isFavorite}) => PropertyDetailsEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        listingType: listingType,
        propertyTypeName: propertyTypeName,
        cityName: cityName,
        addressText: addressText,
        latitude: latitude,
        longitude: longitude,
        roomsCount: roomsCount,
        bathroomsCount: bathroomsCount,
        areaSqm: areaSqm,
        imageUrls: imageUrls,
        viewsCount: viewsCount,
        isFavorite: isFavorite ?? this.isFavorite,
        agent: agent,
      );

  @override
  List<Object?> get props => [
        id, title, description, price, listingType, propertyTypeName, cityName,
        addressText, latitude, longitude, roomsCount, bathroomsCount, areaSqm,
        imageUrls, viewsCount, isFavorite, agent,
      ];
}
