import "package:akare/features/home/domain/entities/property_entity.dart";
import "../../domain/entities/dashboard_stats_entity.dart";

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.agentName,
    super.agentAvatarUrl,
    required super.isVerifiedAgent,
    required super.activeCount,
    required super.pendingCount,
    required super.soldOrRentedCount,
    required super.totalViews,
    required List<PropertyEntity> recentProperties,
  }) : super(recentProperties: recentProperties);
}
