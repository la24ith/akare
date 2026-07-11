part of "agent_profile_cubit.dart";

enum AgentProfileStatus { loading, loaded, error }
enum AgentProfileSaveStatus { idle, saving, saved, error }

class AgentProfileState extends Equatable {
  final AgentProfileStatus status;
  final AgentProfileSaveStatus saveStatus;
  final AgentProfileEntity? profile;
  final String? errorMessage;

  const AgentProfileState({
    this.status = AgentProfileStatus.loading,
    this.saveStatus = AgentProfileSaveStatus.idle,
    this.profile,
    this.errorMessage,
  });

  AgentProfileState copyWith({
    AgentProfileStatus? status,
    AgentProfileSaveStatus? saveStatus,
    AgentProfileEntity? profile,
    String? errorMessage,
  }) {
    return AgentProfileState(
      status: status ?? this.status,
      saveStatus: saveStatus ?? this.saveStatus,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, saveStatus, profile, errorMessage];
}
