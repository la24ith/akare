import 'package:equatable/equatable.dart';

/// Lightweight representation of a property, sized for list/card display.
/// (Property Details screen will use a richer `PropertyDetailsEntity`.)
class PropertyEntity extends Equatable {
  final String id;
  final String title;
  final double price;
  final String listingType; // 'sale' | 'rent'
  final String propertyTypeName;
  final String cityName;
  final int? roomsCount;
  final int? bathroomsCount;
  final double areaSqm;
  final String? mainImageUrl;
  final int viewsCount;
  final bool isFavorite;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.listingType,
    required this.propertyTypeName,
    required this.cityName,
    this.roomsCount,
    this.bathroomsCount,
    required this.areaSqm,
    this.mainImageUrl,
    this.viewsCount = 0,
    this.isFavorite = false,
  });

  bool get isForSale => listingType == 'sale';

  PropertyEntity copyWith({bool? isFavorite}) => PropertyEntity(
        id: id,
        title: title,
        price: price,
        listingType: listingType,
        propertyTypeName: propertyTypeName,
        cityName: cityName,
        roomsCount: roomsCount,
        bathroomsCount: bathroomsCount,
        areaSqm: areaSqm,
        mainImageUrl: mainImageUrl,
        viewsCount: viewsCount,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        listingType,
        propertyTypeName,
        cityName,
        roomsCount,
        bathroomsCount,
        areaSqm,
        mainImageUrl,
        viewsCount,
        isFavorite,
      ];
}
