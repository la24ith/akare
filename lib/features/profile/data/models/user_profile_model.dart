// lib/features/profile/data/models/user_profile_model.dart
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    super.avatarUrl,
  });

  factory UserProfileModel.fromSupabase(Map<String, dynamic> row) {
    return UserProfileModel(
      id: row['id'].toString(),
      fullName: row['full_name'] ?? '',
      email: row['email'] ?? '',
      phone: row['phone'] ?? '',
      avatarUrl: row['avatar_url'],
    );
  }
}
