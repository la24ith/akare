import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:akare/core/usecase/usecase.dart';
import '../../../home/domain/usecases/get_property_types_usecase.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final GetCitiesUseCase getCities;
  final GetPropertyTypesUseCase getPropertyTypes;
  final SearchPropertiesUseCase searchProperties;

  SearchCubit({
    required this.getCities,
    required this.getPropertyTypes,
    required this.searchProperties,
  }) : super(const SearchState());

  /// Loads filter lookups (cities/types) and the initial (unfiltered) result
  /// page — called once from initState.
  Future<void> init() async {
    await Future.wait([_loadLookups(), _runSearch(reset: true)]);
  }

  Future<void> _loadLookups() async {
    final citiesResult = await getCities(const NoParams());
    final typesResult = await getPropertyTypes(const NoParams());
    emit(
      state.copyWith(
        cities: citiesResult.getOrElse(() => state.cities),
        propertyTypes: typesResult.getOrElse(() => state.propertyTypes),
      ),
    );
  }

  void setViewMode(ViewMode mode) => emit(state.copyWith(viewMode: mode));

  void updateKeyword(String keyword) {
    emit(state.copyWith(filter: state.filter.copyWith(keyword: keyword)));
  }

  /// Called from the filter bottom sheet's "بحث" button.
  Future<void> applyFilter(PropertyFilter filter) async {
    emit(state.copyWith(filter: filter));
    await _runSearch(reset: true);
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(filter: state.filter.cleared()));
    await _runSearch(reset: true);
  }

  Future<void> search() => _runSearch(reset: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;
    await _runSearch();
  }

  Future<void> _runSearch({bool reset = false}) async {
    final page = reset ? 1 : state.currentPage;
    emit(
      state.copyWith(
        resultsStatus: reset ? ResultsStatus.loading : state.resultsStatus,
        isLoadingMore: !reset,
      ),
    );

    final result = await searchProperties(
      SearchPropertiesParams(filter: state.filter, page: page),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          resultsStatus: ResultsStatus.error,
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (properties) => emit(
        state.copyWith(
          resultsStatus: ResultsStatus.loaded,
          isLoadingMore: false,
          currentPage: page + 1,
          hasReachedMax: properties.isEmpty,
          results: reset ? properties : [...state.results, ...properties],
        ),
      ),
    );
  }
}
