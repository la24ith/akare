import '../../domain/entities/property_type_entity.dart';

class PropertyTypeModel extends PropertyTypeEntity {
  const PropertyTypeModel({
    required super.id,
    required super.nameAr,
    required super.iconName,
  });

  factory PropertyTypeModel.fromSupabase(Map<String, dynamic> row) {
    return PropertyTypeModel(
      id: row['id'],
      nameAr: row['name_ar'] ?? '',
      iconName: row['icon_name'] ?? 'home',
    );
  }
  // أضف داخل PropertyTypeModel (home/data/models/property_type_model.dart)

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_ar': nameAr,
    'icon_name': iconName,
  };

  factory PropertyTypeModel.fromCacheJson(Map<String, dynamic> json) =>
      PropertyTypeModel(
        id: json['id'],
        nameAr: json['name_ar'],
        iconName: json['icon_name'],
      );
}
