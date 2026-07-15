import "package:akare/core/error/failures.dart";
import "package:dartz/dartz.dart";
import "../entities/dashboard_stats_entity.dart";

abstract class AgentDashboardRepository {
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats();
}
