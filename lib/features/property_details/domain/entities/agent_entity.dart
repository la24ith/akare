import 'package:equatable/equatable.dart';

class AgentEntity extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? companyName;
  final String phone;
  final bool isVerifiedAgent;
  final int activeListingsCount;

  const AgentEntity({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.companyName,
    required this.phone,
    this.isVerifiedAgent = false,
    this.activeListingsCount = 0,
  });

  @override
  List<Object?> get props =>
      [id, fullName, avatarUrl, companyName, phone, isVerifiedAgent, activeListingsCount];
}
