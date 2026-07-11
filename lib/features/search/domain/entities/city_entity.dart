import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final int id;
  final String nameAr;

  const CityEntity({required this.id, required this.nameAr});

  @override
  List<Object?> get props => [id, nameAr];
}
