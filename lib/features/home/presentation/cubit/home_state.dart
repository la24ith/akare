import 'package:equatable/equatable.dart';

import '../../domain/entities/property_entity.dart';
import '../../domain/entities/property_type_entity.dart';

enum SectionStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final SectionStatus categoriesStatus;
  final SectionStatus featuredStatus;
  final SectionStatus latestStatus;
  final bool isOffline;
  final int? selectedCategoryId;

  final List<PropertyTypeEntity> categories;
  final List<PropertyEntity> featuredProperties;
  final List<PropertyEntity> latestProperties;

  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;

  final String? errorMessage;

  const HomeState({
    this.categoriesStatus = SectionStatus.initial,
    this.featuredStatus = SectionStatus.initial,
    this.latestStatus = SectionStatus.initial,
    this.categories = const [],
    this.featuredProperties = const [],
    this.latestProperties = const [],
    this.isOffline = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
    this.selectedCategoryId,
  });

  bool get isLatestEmpty =>
      latestStatus == SectionStatus.loaded && latestProperties.isEmpty;

  HomeState copyWith({
    SectionStatus? categoriesStatus,
    SectionStatus? featuredStatus,
    SectionStatus? latestStatus,
    List<PropertyTypeEntity>? categories,
    List<PropertyEntity>? featuredProperties,
    List<PropertyEntity>? latestProperties,
    bool? isLoadingMore,
    bool? isOffline,
    bool? hasReachedMax,
    int? currentPage,

    String? errorMessage,
    int? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return HomeState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      featuredStatus: featuredStatus ?? this.featuredStatus,
      latestStatus: latestStatus ?? this.latestStatus,
      categories: categories ?? this.categories,
      featuredProperties: featuredProperties ?? this.featuredProperties,
      latestProperties: latestProperties ?? this.latestProperties,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffline: isOffline ?? this.isOffline,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props => [
    categoriesStatus,
    featuredStatus,
    latestStatus,
    categories,
    featuredProperties,
    latestProperties,
    isLoadingMore,
    hasReachedMax,
    currentPage,
    errorMessage,
    isOffline,
    selectedCategoryId,
  ];
}
