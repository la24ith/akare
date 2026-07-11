class PropertySubmitData {
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

  const PropertySubmitData({
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
  });

  Map<String, dynamic> toJson(String agentId) => {
        "agent_id": agentId,
        "title": title,
        "description": description,
        "price": price,
        "listing_type": listingType,
        "property_type_id": propertyTypeId,
        "city_id": cityId,
        "address_text": addressText,
        "latitude": latitude,
        "longitude": longitude,
        "rooms_count": roomsCount,
        "bathrooms_count": bathroomsCount,
        "area_sqm": areaSqm,
        "status": "pending", // دائمًا pending عند الإضافة أو التعديل
      };
}
