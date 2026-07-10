import '../../domain/entities/user_entity.dart';

/// Model = نفس الـ Entity لكن بيعرف يتحول من/إلى Map (JSON القادم من Supabase).
/// هذا الفصل مهم: الـ domain (UserEntity) ما بيعرفش حاجة عن Supabase أو JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    super.avatarUrl,
    required super.role,
    required super.isVerified,
  });

  /// row قادم من جدول public.users في Supabase
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      role: _roleFromString(map['role'] as String? ?? 'user'),
      isVerified: map['is_verified'] as bool? ?? false,
    );
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'agent':
        return UserRole.agent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}
