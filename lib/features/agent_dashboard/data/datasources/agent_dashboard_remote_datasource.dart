import "package:akare/features/home/data/models/property_model.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../models/dashboard_stats_model.dart";

abstract class AgentDashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

class AgentDashboardRemoteDataSourceImpl
    implements AgentDashboardRemoteDataSource {
  final SupabaseClient client;
  AgentDashboardRemoteDataSourceImpl(this.client);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final uid = client.auth.currentUser!.id;

    // بيانات الوكيل + المستخدم
    final agentRow = await client
        .from("agents")
        .select("id, is_verified_agent, users!inner(full_name, avatar_url)")
        .eq("user_id", uid)
        .single();

    final agentId = agentRow["id"] as String;
    final userJson = agentRow["users"] as Map<String, dynamic>;

    // عدّ العقارات حسب الحالة
    final activeCount = await client
        .from("properties")
        .count(CountOption.exact)
        .eq("agent_id", agentId)
        .eq("status", "active");

    final pendingCount = await client
        .from("properties")
        .count(CountOption.exact)
        .eq("agent_id", agentId)
        .eq("status", "pending");

    final soldRentedCount = await client
        .from("properties")
        .count(CountOption.exact)
        .eq("agent_id", agentId)
        .inFilter("status", ["sold", "rented"]);

    // مجموع المشاهدات
    final viewsRows = await client
        .from("properties")
        .select("views_count")
        .eq("agent_id", agentId);
    final totalViews = (viewsRows as List).fold<int>(
      0,
      (sum, row) => sum + ((row["views_count"] ?? 0) as int),
    );

    // أحدث 5 عقارات
    final recentRows = await client
        .from("properties")
        .select(
          "*, property_images(image_url, is_primary), property_types(name_ar, icon_name), cities(name_ar)",
        )
        .eq("agent_id", agentId)
        .order("created_at", ascending: false)
        .limit(5);

    final recentProperties = (recentRows as List)
        .map((row) => PropertyModel.fromSupabase(row as Map<String, dynamic>))
        .toList();

    return DashboardStatsModel(
      agentName: userJson["full_name"] as String,
      agentAvatarUrl: userJson["avatar_url"] as String?,
      isVerifiedAgent: agentRow["is_verified_agent"] as bool? ?? false,
      activeCount: activeCount,
      pendingCount: pendingCount,
      soldOrRentedCount: soldRentedCount,
      totalViews: totalViews,
      recentProperties: recentProperties,
    );
  }
}
