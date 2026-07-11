import "../../domain/entities/agent_profile_entity.dart";

class AgentProfileModel extends AgentProfileEntity {
  const AgentProfileModel({
    required super.userId,
    required super.agentId,
    required super.fullName,
    required super.email,
    required super.phone,
    super.avatarUrl,
    super.companyName,
    super.licenseNumber,
    super.bio,
    required super.isVerifiedAgent,
  });

  factory AgentProfileModel.fromSupabase(Map<String, dynamic> agentJson) {
    final user = agentJson["users"] as Map<String, dynamic>;
    return AgentProfileModel(
      userId: user["id"] as String,
      agentId: agentJson["id"] as String,
      fullName: user["full_name"] as String,
      email: user["email"] as String,
      phone: user["phone"] as String,
      avatarUrl: user["avatar_url"] as String?,
      companyName: agentJson["company_name"] as String?,
      licenseNumber: agentJson["license_number"] as String?,
      bio: agentJson["bio"] as String?,
      isVerifiedAgent: agentJson["is_verified_agent"] as bool? ?? false,
    );
  }
}
