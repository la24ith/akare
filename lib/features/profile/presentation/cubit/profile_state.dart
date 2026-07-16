// lib/features/profile/presentation/cubit/profile_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfileEntity? profile;
  final String? errorMessage;
  final bool isSaving;
  final bool isUploadingAvatar;
  final bool saveSuccess;
  final bool loggedOut;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.saveSuccess = false,
    this.loggedOut = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? profile,
    String? errorMessage,
    bool? isSaving,
    bool? isUploadingAvatar,
    bool? saveSuccess,
    bool? loggedOut,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      loggedOut: loggedOut ?? this.loggedOut,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    isSaving,
    isUploadingAvatar,
    saveSuccess,
    loggedOut,
  ];
}
