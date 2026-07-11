import "package:equatable/equatable.dart";

class AgentProfileEntity extends Equatable {
  final String userId;
  final String agentId;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? companyName;
  final String? licenseNumber;
  final String? bio;
  final bool isVerifiedAgent;

  const AgentProfileEntity({
    required this.userId,
    required this.agentId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.companyName,
    this.licenseNumber,
    this.bio,
    required this.isVerifiedAgent,
  });

  @override
  List<Object?> get props => [
        userId,
        agentId,
        fullName,
        email,
        phone,
        avatarUrl,
        companyName,
        licenseNumber,
        bio,
        isVerifiedAgent,
      ];
}
