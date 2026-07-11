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
}
