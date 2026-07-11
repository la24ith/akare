import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/property_entity.dart';
import '../../../home/domain/entities/property_type_entity.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/property_filter.dart';

enum ResultsStatus { initial, loading, loaded, error }
enum ViewMode { grid, list }

class SearchState extends Equatable {
  final PropertyFilter filter;
  final ViewMode viewMode;

  final List<CityEntity> cities;
  final List<PropertyTypeEntity> propertyTypes;

  final ResultsStatus resultsStatus;
  final List<PropertyEntity> results;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  const SearchState({
    this.filter = const PropertyFilter(),
    this.viewMode = ViewMode.list,
    this.cities = const [],
    this.propertyTypes = const [],
    this.resultsStatus = ResultsStatus.initial,
    this.results = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  bool get isEmpty => resultsStatus == ResultsStatus.loaded && results.isEmpty;

  SearchState copyWith({
    PropertyFilter? filter,
    ViewMode? viewMode,
    List<CityEntity>? cities,
    List<PropertyTypeEntity>? propertyTypes,
    ResultsStatus? resultsStatus,
    List<PropertyEntity>? results,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
  }) {
    return SearchState(
      filter: filter ?? this.filter,
      viewMode: viewMode ?? this.viewMode,
      cities: cities ?? this.cities,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      resultsStatus: resultsStatus ?? this.resultsStatus,
      results: results ?? this.results,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        filter,
        viewMode,
        cities,
        propertyTypes,
        resultsStatus,
        results,
        isLoadingMore,
        hasReachedMax,
        currentPage,
        errorMessage,
      ];
}
