import '../../domain/entities/agent_entity.dart';

class AgentModel extends AgentEntity {
  const AgentModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.companyName,
    required super.phone,
    super.isVerifiedAgent,
    super.activeListingsCount,
  });

  /// `row` is the embedded `agents(...)` map from a properties query, which
  /// itself embeds `users(...)` via `agents.user_id`.
  factory AgentModel.fromSupabase(Map<String, dynamic> row, {int activeListingsCount = 0}) {
    final user = row['users'] ?? {};
    return AgentModel(
      id: row['id'].toString(),
      fullName: user['full_name'] ?? '',
      avatarUrl: user['avatar_url'],
      companyName: row['company_name'],
      phone: user['phone'] ?? '',
      isVerifiedAgent: row['is_verified_agent'] ?? false,
      activeListingsCount: activeListingsCount,
    );
  }
}
