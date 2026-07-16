// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    required String fullName,
    required String phone,
  });
  Future<String> uploadAvatar(String localFilePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;
  ProfileRemoteDataSourceImpl(this.supabase);

  String get _uid {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('يجب تسجيل الدخول');
    return uid;
  }

  @override
  Future<UserProfileModel> getProfile() async {
    final row = await supabase.from('users').select().eq('id', _uid).single();
    return UserProfileModel.fromSupabase(row);
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final row = await supabase
        .from('users')
        .update({'full_name': fullName, 'phone': phone})
        .eq('id', _uid)
        .select()
        .single();
    return UserProfileModel.fromSupabase(row);
  }

  @override
  Future<String> uploadAvatar(String localFilePath) async {
    final uid = _uid;
    final file = File(localFilePath);
    final fileName = '$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
    await supabase
        .from('users')
        .update({'avatar_url': publicUrl})
        .eq('id', uid);
    return publicUrl;
  }
}
