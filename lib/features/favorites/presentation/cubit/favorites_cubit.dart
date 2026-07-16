// lib/features/favorites/presentation/cubit/favorites_cubit.dart
import 'package:akare/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../home/domain/usecases/get_favorites_usecase.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase getFavorites;
  FavoritesCubit({required this.getFavorites}) : super(const FavoritesState());

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    final result = await getFavorites(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (properties) => emit(
        state.copyWith(status: FavoritesStatus.loaded, properties: properties),
      ),
    );
  }
}
