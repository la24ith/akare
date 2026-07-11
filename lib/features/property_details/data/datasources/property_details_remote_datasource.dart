import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_details_model.dart';

const _detailsColumns = '''
  id, title, description, price, listing_type, rooms_count, bathrooms_count,
  area_sqm, views_count, address_text, latitude, longitude,
  property_types(name_ar),
  cities(name_ar),
  property_images(image_url, is_primary, sort_order),
  agents(id, company_name, is_verified_agent, users(full_name, avatar_url, phone))
''';

abstract class PropertyDetailsRemoteDataSource {
  Future<PropertyDetailsModel> getPropertyDetails(String propertyId);
  Future<void> toggleFavorite(String propertyId);
  Future<void> reportProperty({required String propertyId, required String reason});
}

class PropertyDetailsRemoteDataSourceImpl implements PropertyDetailsRemoteDataSource {
  final SupabaseClient supabase;
  PropertyDetailsRemoteDataSourceImpl(this.supabase);

  String? get _userId => supabase.auth.currentUser?.id;

  @override
  Future<PropertyDetailsModel> getPropertyDetails(String propertyId) async {
    final row = await supabase.from('properties').select(_detailsColumns).eq('id', propertyId).single();

    bool isFavorite = false;
    final uid = _userId;
    if (uid != null) {
      final favRow = await supabase
          .from('favorites')
          .select('id')
          .eq('user_id', uid)
          .eq('property_id', propertyId)
          .maybeSingle();
      isFavorite = favRow != null;
    }

    // Simple length-of-rows count — avoids version-specific `.count()` APIs.
    // Swap for `.count(CountOption.exact)` if your supabase_flutter version
    // supports it and you'd rather not fetch the ids themselves.
    final activeListingsRows = await supabase
        .from('properties')
        .select('id')
        .eq('agent_id', row['agents']?['id'])
        .eq('status', 'active');

    // Fire-and-forget view counter via a Postgres function you'll need to
    // create (`increment_property_views(property_id uuid)`), e.g.:
    //   update properties set views_count = views_count + 1 where id = property_id;
    // Don't block the screen on it, and don't fail the page if it errors.
    unawaited(
      supabase.rpc('increment_property_views', params: {'property_id': propertyId}).catchError((_) => null),
    );

    return PropertyDetailsModel.fromSupabase(
      row,
      isFavorite: isFavorite,
      agentActiveListingsCount: (activeListingsRows as List).length,
    );
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

  @override
  Future<void> reportProperty({required String propertyId, required String reason}) async {
    final uid = _userId;
    if (uid == null) {
      throw const AuthException('يجب تسجيل الدخول للإبلاغ عن عقار');
    }
    await supabase.from('property_reports').insert({
      'property_id': propertyId,
      'reporter_user_id': uid,
      'reason': reason,
    });
  }
}
