import "package:akare/core/usecace/usecase.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../domain/entities/agent_profile_entity.dart";
import "../../domain/usecases/get_agent_profile_usecase.dart";
import "../../domain/usecases/sign_out_usecase.dart";
import "../../domain/usecases/update_agent_profile_usecase.dart";

part "agent_profile_state.dart";

class AgentProfileCubit extends Cubit<AgentProfileState> {
  final GetAgentProfileUseCase getAgentProfileUseCase;
  final UpdateAgentProfileUseCase updateAgentProfileUseCase;
  final SignOutUseCase signOutUseCase;

  AgentProfileCubit({
    required this.getAgentProfileUseCase,
    required this.updateAgentProfileUseCase,
    required this.signOutUseCase,
  }) : super(const AgentProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: AgentProfileStatus.loading));
    final result = await getAgentProfileUseCase(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AgentProfileStatus.error,
          errorMessage: f.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(status: AgentProfileStatus.loaded, profile: profile),
      ),
    );
  }

  Future<void> updateProfile({
    required String fullName,
    String? companyName,
    String? licenseNumber,
    String? bio,
  }) async {
    emit(state.copyWith(saveStatus: AgentProfileSaveStatus.saving));
    final result = await updateAgentProfileUseCase(
      UpdateAgentProfileParams(
        fullName: fullName,
        companyName: companyName,
        licenseNumber: licenseNumber,
        bio: bio,
      ),
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          saveStatus: AgentProfileSaveStatus.error,
          errorMessage: f.message,
        ),
      ),
      (_) {
        emit(state.copyWith(saveStatus: AgentProfileSaveStatus.saved));
        loadProfile();
      },
    );
  }

  Future<bool> signOut() async {
    final result = await signOutUseCase(NoParams());
    return result.fold((f) => false, (_) => true);
  }
}
