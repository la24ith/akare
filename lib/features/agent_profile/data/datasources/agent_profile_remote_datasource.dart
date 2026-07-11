import "package:supabase_flutter/supabase_flutter.dart";
import "../models/agent_profile_model.dart";

abstract class AgentProfileRemoteDataSource {
  Future<AgentProfileModel> getProfile();
  Future<void> updateProfile({
    required String fullName,
    String? companyName,
    String? licenseNumber,
    String? bio,
  });
  Future<void> signOut();
}

class AgentProfileRemoteDataSourceImpl implements AgentProfileRemoteDataSource {
  final SupabaseClient client;
  AgentProfileRemoteDataSourceImpl(this.client);

  @override
  Future<AgentProfileModel> getProfile() async {
    final uid = client.auth.currentUser!.id;
    final row = await client
        .from("agents")
        .select(
            "id, company_name, license_number, bio, is_verified_agent, users!inner(id, full_name, email, phone, avatar_url)")
        .eq("user_id", uid)
        .single();
    return AgentProfileModel.fromSupabase(row);
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? companyName,
    String? licenseNumber,
    String? bio,
  }) async {
    final uid = client.auth.currentUser!.id;
    await client.from("users").update({"full_name": fullName}).eq("id", uid);
    await client.from("agents").update({
      "company_name": companyName,
      "license_number": licenseNumber,
      "bio": bio,
    }).eq("user_id", uid);
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
