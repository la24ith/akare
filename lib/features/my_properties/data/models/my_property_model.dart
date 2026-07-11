import "../../domain/entities/my_property_entity.dart";

class MyPropertyModel extends MyPropertyEntity {
  const MyPropertyModel({
    required super.id,
    required super.title,
    required super.price,
    required super.listingType,
    required super.status,
    super.rejectionReason,
    required super.viewsCount,
    super.primaryImageUrl,
    required super.cityName,
    required super.propertyTypeName,
    required super.createdAt,
  });

  factory MyPropertyModel.fromSupabase(Map<String, dynamic> json) {
    final images = (json["property_images"] as List?) ?? [];
    String? primaryUrl;
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img["is_primary"] == true,
        orElse: () => images.first,
      );
      primaryUrl = primary["image_url"] as String?;
    }

    return MyPropertyModel(
      id: json["id"] as String,
      title: json["title"] as String,
      price: (json["price"] as num).toDouble(),
      listingType: json["listing_type"] as String,
      status: json["status"] as String,
      rejectionReason: json["rejection_reason"] as String?,
      viewsCount: (json["views_count"] as num?)?.toInt() ?? 0,
      primaryImageUrl: primaryUrl,
      cityName: (json["cities"]?["name_ar"] as String?) ?? "",
      propertyTypeName: (json["property_types"]?["name_ar"] as String?) ?? "",
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}
