import "package:akare/core/error/failures.dart";
import "package:akare/core/usecase/usecase.dart";
import "package:dartz/dartz.dart";

import "../entities/dashboard_stats_entity.dart";
import "../repositories/agent_dashboard_repository.dart";

class GetDashboardStatsUseCase
    implements UseCase<DashboardStatsEntity, NoParams> {
  final AgentDashboardRepository repository;
  GetDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardStatsEntity>> call(NoParams params) {
    return repository.getDashboardStats();
  }
}
