import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../home/data/models/property_model.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/entities/sort_option.dart';
import '../models/city_model.dart';

const _propertyColumns = '''
  id, title, price, listing_type, rooms_count, bathrooms_count,
  area_sqm, views_count,
  property_types(name_ar),
  cities(name_ar),
  property_images(image_url, is_primary)
''';

abstract class SearchRemoteDataSource {
  Future<List<CityModel>> getCities();
  Future<List<PropertyModel>> searchProperties({
    required PropertyFilter filter,
    required int page,
    required int limit,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabase;
  SearchRemoteDataSourceImpl(this.supabase);

  String? get _userId => supabase.auth.currentUser?.id;

  Future<Set<String>> _favoriteIds() async {
    final uid = _userId;
    if (uid == null) return {};
    final rows = await supabase.from('favorites').select('property_id').eq('user_id', uid);
    return (rows as List).map((r) => r['property_id'].toString()).toSet();
  }

  @override
  Future<List<CityModel>> getCities() async {
    final rows = await supabase.from('cities').select().order('name_ar');
    return (rows as List).map((r) => CityModel.fromSupabase(r)).toList();
  }

  @override
  Future<List<PropertyModel>> searchProperties({
    required PropertyFilter filter,
    required int page,
    required int limit,
  }) async {
    var query = supabase.from('properties').select(_propertyColumns).eq('status', 'active');

    if (filter.keyword != null && filter.keyword!.trim().isNotEmpty) {
      query = query.ilike('title', '%${filter.keyword!.trim()}%');
    }
    if (filter.cityId != null) query = query.eq('city_id', filter.cityId!);
    if (filter.propertyTypeId != null) query = query.eq('property_type_id', filter.propertyTypeId!);
    if (filter.listingType != null) query = query.eq('listing_type', filter.listingType!);
    if (filter.minPrice != null) query = query.gte('price', filter.minPrice!);
    if (filter.maxPrice != null) query = query.lte('price', filter.maxPrice!);
    if (filter.minRooms != null) query = query.gte('rooms_count', filter.minRooms!);

    final (column, ascending) = switch (filter.sortBy) {
      SortOption.newest => ('created_at', false),
      SortOption.priceLowToHigh => ('price', true),
      SortOption.priceHighToLow => ('price', false),
    };

    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final favorites = await _favoriteIds();
    final rows = await query.order(column, ascending: ascending).range(from, to);

    return (rows as List)
        .map((r) => PropertyModel.fromSupabase(r, isFavorite: favorites.contains(r['id'].toString())))
        .toList();
  }
}
