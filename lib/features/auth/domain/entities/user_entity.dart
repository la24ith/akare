import 'package:equatable/equatable.dart';

enum UserRole { user, agent, admin }

/// Entity نقية بدون أي اعتماد على JSON أو Supabase — هذا ما يستخدمه الـ UI والـ usecases
class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, avatarUrl, role, isVerified];
}
