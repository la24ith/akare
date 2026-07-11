import '../../domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({required super.id, required super.nameAr});

  factory CityModel.fromSupabase(Map<String, dynamic> row) {
    return CityModel(id: row['id'], nameAr: row['name_ar'] ?? '');
  }
}
