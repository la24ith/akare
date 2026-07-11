import "package:akare/features/home/domain/entities/property_type_entity.dart";
import "package:akare/features/search/domain/entities/city_entity.dart";
import "package:equatable/equatable.dart";

class PropertyFormLookupsEntity extends Equatable {
  final List<PropertyTypeEntity> propertyTypes;
  final List<CityEntity> cities;

  const PropertyFormLookupsEntity({
    required this.propertyTypes,
    required this.cities,
  });

  @override
  List<Object?> get props => [propertyTypes, cities];
}
