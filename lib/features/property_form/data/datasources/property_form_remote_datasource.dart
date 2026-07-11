import "dart:io";
import "package:akare/features/home/data/models/property_type_model.dart";
import "package:akare/features/search/data/models/city_model.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../models/property_edit_data_model.dart";

abstract class PropertyFormRemoteDataSource {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<CityModel>> getCities();
  Future<PropertyEditDataModel> getPropertyForEdit(String propertyId);
  Future<String> submitProperty(
    Map<String, dynamic> data,
    String? editingPropertyId,
  );
  Future<String> uploadImage({
    required File file,
    required String propertyId,
    required bool isPrimary,
    required int sortOrder,
  });
  Future<void> deleteImage(String imageId);
  Future<void> setPrimaryImage({
    required String propertyId,
    required String imageId,
  });
}

class PropertyFormRemoteDataSourceImpl implements PropertyFormRemoteDataSource {
  final SupabaseClient client;
  PropertyFormRemoteDataSourceImpl(this.client);

  Future<String> get _agentId async {
    final uid = client.auth.currentUser!.id;
    final row = await client
        .from("agents")
        .select("id")
        .eq("user_id", uid)
        .single();
    return row["id"] as String;
  }

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    final rows = await client.from("property_types").select();
    return (rows as List)
        .map((r) => PropertyTypeModel.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CityModel>> getCities() async {
    final rows = await client.from("cities").select();
    return (rows as List)
        .map((r) => CityModel.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PropertyEditDataModel> getPropertyForEdit(String propertyId) async {
    final row = await client
        .from("properties")
        .select("*, property_images(id, image_url, is_primary, sort_order)")
        .eq("id", propertyId)
        .single();
    return PropertyEditDataModel.fromSupabase(row);
  }

  @override
  Future<String> submitProperty(
    Map<String, dynamic> data,
    String? editingPropertyId,
  ) async {
    if (editingPropertyId == null) {
      final row = await client
          .from("properties")
          .insert(data)
          .select("id")
          .single();
      return row["id"] as String;
    } else {
      await client.from("properties").update(data).eq("id", editingPropertyId);
      return editingPropertyId;
    }
  }

  @override
  Future<String> uploadImage({
    required File file,
    required String propertyId,
    required bool isPrimary,
    required int sortOrder,
  }) async {
    final agentId = await _agentId;
    final ext = file.path.split(".").last;
    final fileName = "${DateTime.now().microsecondsSinceEpoch}.$ext";
    final storagePath = "$agentId/$propertyId/$fileName";

    await client.storage.from("property-images").upload(storagePath, file);
    final publicUrl = client.storage
        .from("property-images")
        .getPublicUrl(storagePath);

    await client.from("property_images").insert({
      "property_id": propertyId,
      "image_url": publicUrl,
      "is_primary": isPrimary,
      "sort_order": sortOrder,
    });

    return publicUrl;
  }

  @override
  Future<void> deleteImage(String imageId) async {
    await client.from("property_images").delete().eq("id", imageId);
  }

  @override
  Future<void> setPrimaryImage({
    required String propertyId,
    required String imageId,
  }) async {
    await client
        .from("property_images")
        .update({"is_primary": false})
        .eq("property_id", propertyId);
    await client
        .from("property_images")
        .update({"is_primary": true})
        .eq("id", imageId);
  }
}
