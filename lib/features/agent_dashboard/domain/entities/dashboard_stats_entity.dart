import "package:akare/features/home/domain/entities/property_entity.dart";
import "package:equatable/equatable.dart";

/// إحصائيات لوحة تحكم الوكيل
class DashboardStatsEntity extends Equatable {
  final String agentName;
  final String? agentAvatarUrl;
  final bool isVerifiedAgent;
  final int activeCount;
  final int pendingCount;
  final int soldOrRentedCount;
  final int totalViews;
  final List<PropertyEntity> recentProperties;

  const DashboardStatsEntity({
    required this.agentName,
    this.agentAvatarUrl,
    required this.isVerifiedAgent,
    required this.activeCount,
    required this.pendingCount,
    required this.soldOrRentedCount,
    required this.totalViews,
    required this.recentProperties,
  });

  @override
  List<Object?> get props => [
    agentName,
    agentAvatarUrl,
    isVerifiedAgent,
    activeCount,
    pendingCount,
    soldOrRentedCount,
    totalViews,
    recentProperties,
  ];
}
