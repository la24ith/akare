part of "agent_dashboard_cubit.dart";

enum AgentDashboardStatus { initial, loading, loaded, error }

class AgentDashboardState extends Equatable {
  final AgentDashboardStatus status;
  final DashboardStatsEntity? stats;
  final String? errorMessage;

  const AgentDashboardState({
    this.status = AgentDashboardStatus.initial,
    this.stats,
    this.errorMessage,
  });

  AgentDashboardState copyWith({
    AgentDashboardStatus? status,
    DashboardStatsEntity? stats,
    String? errorMessage,
  }) {
    return AgentDashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, errorMessage];
}
