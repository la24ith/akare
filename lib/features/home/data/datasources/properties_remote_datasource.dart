import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_model.dart';
import '../models/property_type_model.dart';

/// Row shape reused by every query below — keeps the embedded
/// property_types/cities/property_images joins in one place.
const _propertyColumns = '''
  id, title, price, listing_type, rooms_count, bathrooms_count,
  area_sqm, views_count,
  property_types(name_ar),
  cities(name_ar),
  property_images(image_url, is_primary)
''';

abstract class PropertiesRemoteDataSource {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertyModel>> getFeaturedProperties();
  Future<List<PropertyModel>> getLatestProperties({required int page, required int limit});
  Future<void> toggleFavorite(String propertyId);
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  final SupabaseClient supabase;
  PropertiesRemoteDataSourceImpl(this.supabase);

  String? get _userId => supabase.auth.currentUser?.id;

  /// Returns the set of property ids the current user has favorited, so
  /// list queries can stamp `isFavorite` without a per-row join.
  Future<Set<String>> _favoriteIds() async {
    final uid = _userId;
    if (uid == null) return {};
    final rows = await supabase.from('favorites').select('property_id').eq('user_id', uid);
    return (rows as List).map((r) => r['property_id'].toString()).toSet();
  }

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    final rows = await supabase.from('property_types').select();
    return (rows as List).map((r) => PropertyTypeModel.fromSupabase(r)).toList();
  }

  @override
  Future<List<PropertyModel>> getFeaturedProperties() async {
    // No `is_featured` column in the current schema, so "featured" is
    // defined as the most-viewed active listings. If you add a boolean
    // `is_featured` column later, swap the `.order` line for:
    //   .eq('is_featured', true)
    final favorites = await _favoriteIds();
    final rows = await supabase
        .from('properties')
        .select(_propertyColumns)
        .eq('status', 'active')
        .order('views_count', ascending: false)
        .limit(6);
    return (rows as List)
        .map((r) => PropertyModel.fromSupabase(r, isFavorite: favorites.contains(r['id'].toString())))
        .toList();
  }

  @override
  Future<List<PropertyModel>> getLatestProperties({required int page, required int limit}) async {
    final favorites = await _favoriteIds();
    final from = (page - 1) * limit;
    final to = from + limit - 1;
    final rows = await supabase
        .from('properties')
        .select(_propertyColumns)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .range(from, to);
    return (rows as List)
        .map((r) => PropertyModel.fromSupabase(r, isFavorite: favorites.contains(r['id'].toString())))
        .toList();
  }

  @override
  Future<void> toggleFavorite(String propertyId) async {
    final uid = _userId;
    if (uid == null) {
      throw const AuthException('يجب تسجيل الدخول لإضافة عقار للمفضلة');
    }

    final existing = await supabase
        .from('favorites')
        .select('id')
        .eq('user_id', uid)
        .eq('property_id', propertyId)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('favorites').insert({'user_id': uid, 'property_id': propertyId});
    } else {
      await supabase.from('favorites').delete().eq('id', existing['id']);
    }
  }
}
