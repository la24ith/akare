import "package:akare/core/usecace/usecase.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../domain/entities/dashboard_stats_entity.dart";
import "../../domain/usecases/get_dashboard_stats_usecase.dart";

part "agent_dashboard_state.dart";

class AgentDashboardCubit extends Cubit<AgentDashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  AgentDashboardCubit(this.getDashboardStatsUseCase)
    : super(const AgentDashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: AgentDashboardStatus.loading));
    final result = await getDashboardStatsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AgentDashboardStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (stats) => emit(
        state.copyWith(status: AgentDashboardStatus.loaded, stats: stats),
      ),
    );
  }
}
