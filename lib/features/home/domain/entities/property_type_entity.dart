import 'package:equatable/equatable.dart';

class PropertyTypeEntity extends Equatable {
  final int id;
  final String nameAr;
  final String iconName;

  const PropertyTypeEntity({
    required this.id,
    required this.nameAr,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, nameAr, iconName];
}
