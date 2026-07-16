// lib/features/profile/domain/entities/user_profile_entity.dart
import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;

  const UserProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  UserProfileEntity copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, phone, avatarUrl];
}
