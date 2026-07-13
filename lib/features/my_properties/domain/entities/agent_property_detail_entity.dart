// lib/features/my_properties/domain/entities/agent_property_detail_entity.dart
class AgentPropertyDetailEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String listingType; // 'sale' | 'rent'
  final String propertyTypeName;
  final String cityName;
  final String status; // pending/active/rejected/sold/rented
  final String? rejectionReason;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final int? roomsCount;
  final int? bathroomsCount;
  final double areaSqm;
  final List<String> imageUrls;
  final int viewsCount;
  final int favoritesCount;

  const AgentPropertyDetailEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    required this.propertyTypeName,
    required this.cityName,
    required this.status,
    this.rejectionReason,
    this.addressText,
    this.latitude,
    this.longitude,
    this.roomsCount,
    this.bathroomsCount,
    required this.areaSqm,
    this.imageUrls = const [],
    this.viewsCount = 0,
    this.favoritesCount = 0,
  });

  bool get isForSale => listingType == 'sale';
  bool get isActive => status == 'active';
}
