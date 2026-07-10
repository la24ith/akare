import '../../domain/entities/property_type_entity.dart';

class PropertyTypeModel extends PropertyTypeEntity {
  const PropertyTypeModel({
    required super.id,
    required super.nameAr,
    required super.iconName,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      iconName: json['icon_name'] ?? 'home',
    );
  }
}
