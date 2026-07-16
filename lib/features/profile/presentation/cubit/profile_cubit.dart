// lib/features/profile/presentation/cubit/profile_cubit.dart
import 'package:akare/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/usecases/logout_usecase.dart'; // نفس LogoutUseCase الموجود أصلًا
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final LogoutUseCase logoutUseCase;

  ProfileCubit({
    required this.getProfile,
    required this.updateProfileUseCase,
    required this.uploadAvatarUseCase,
    required this.logoutUseCase,
  }) : super(const ProfileState());

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getProfile(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) =>
          emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
    );
  }

  Future<void> save({required String fullName, required String phone}) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false));
    final result = await updateProfileUseCase(
      UpdateProfileParams(fullName: fullName, phone: phone),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (profile) => emit(
        state.copyWith(isSaving: false, saveSuccess: true, profile: profile),
      ),
    );
  }

  Future<void> uploadAvatar(String localFilePath) async {
    emit(state.copyWith(isUploadingAvatar: true));
    final result = await uploadAvatarUseCase(localFilePath);
    result.fold(
      (failure) => emit(
        state.copyWith(isUploadingAvatar: false, errorMessage: failure.message),
      ),
      (url) => emit(
        state.copyWith(
          isUploadingAvatar: false,
          profile: state.profile?.copyWith(avatarUrl: url),
        ),
      ),
    );
  }

  Future<void> logout() async {
    await logoutUseCase(); // عدّل التوقيع لو LogoutUseCase عندك بياخد Params مختلفة
    emit(state.copyWith(loggedOut: true));
  }
}
