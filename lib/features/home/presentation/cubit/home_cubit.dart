import 'dart:async';

import 'package:akare/core/network/connectivity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:akare/core/error/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import '../../domain/usecases/get_featured_properties_usecase.dart';
import '../../domain/usecases/get_latest_properties_usecase.dart';
import '../../domain/usecases/get_property_types_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetPropertyTypesUseCase getPropertyTypes;
  final GetFeaturedPropertiesUseCase getFeaturedProperties;
  final GetLatestPropertiesUseCase getLatestProperties;
  StreamSubscription<bool>? _connectivitySub;

  HomeCubit({
    required this.getPropertyTypes,
    required this.getFeaturedProperties,
    required this.getLatestProperties,
  }) : super(const HomeState()) {
    _connectivitySub = ConnectivityService.onStatusChange.listen(
      (isOnline) => emit(state.copyWith(isOffline: !isOnline)),
    );
  }

  /// Called once from initState. Sections load independently so a slow
  /// "featured" call never blocks categories or the latest list from
  /// appearing as soon as they're ready.
  Future<void> loadHome() async {
    final online = await ConnectivityService.isOnline();
    emit(state.copyWith(isOffline: !online));
    await Future.wait([
      _loadCategories(),
      _loadFeatured(),
      _loadLatest(reset: true),
    ]);
  }

  Future<void> refresh() async {
    emit(state.copyWith(currentPage: 1, hasReachedMax: false));
    await loadHome();
  }

  Future<void> _loadCategories() async {
    emit(state.copyWith(categoriesStatus: SectionStatus.loading));
    final result = await getPropertyTypes(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesStatus: SectionStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (types) => emit(
        state.copyWith(
          categoriesStatus: SectionStatus.loaded,
          categories: types,
        ),
      ),
    );
  }

  Future<void> _loadFeatured() async {
    emit(state.copyWith(featuredStatus: SectionStatus.loading));
    final result = await getFeaturedProperties(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          featuredStatus: SectionStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (properties) => emit(
        state.copyWith(
          featuredStatus: SectionStatus.loaded,
          featuredProperties: properties,
        ),
      ),
    );
  }

  Future<void> _loadLatest({bool reset = false}) async {
    final page = reset ? 1 : state.currentPage;
    emit(
      state.copyWith(
        latestStatus: reset ? SectionStatus.loading : state.latestStatus,
        isLoadingMore: !reset,
      ),
    );

    final result = await getLatestProperties(
      GetLatestPropertiesParams(page: page),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          latestStatus: SectionStatus.error,
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (properties) => emit(
        state.copyWith(
          latestStatus: SectionStatus.loaded,
          isLoadingMore: false,
          currentPage: page + 1,
          hasReachedMax: properties.isEmpty,
          latestProperties: reset
              ? properties
              : [...state.latestProperties, ...properties],
        ),
      ),
    );
  }

  Future<void> loadMoreLatest() async {
    if (state.isLoadingMore || state.hasReachedMax) return;
    await _loadLatest();
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
