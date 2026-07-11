import 'package:equatable/equatable.dart';

import 'sort_option.dart';

class PropertyFilter extends Equatable {
  final String? keyword;
  final int? cityId;
  final int? propertyTypeId;
  final String? listingType; // 'sale' | 'rent' | null = both
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final SortOption sortBy;

  const PropertyFilter({
    this.keyword,
    this.cityId,
    this.propertyTypeId,
    this.listingType,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.sortBy = SortOption.newest,
  });

  /// True when at least one filter (beyond keyword/sort) is active —
  /// drives the "badge" on the filter icon in the UI.
  bool get hasActiveFilters =>
      cityId != null ||
      propertyTypeId != null ||
      listingType != null ||
      minPrice != null ||
      maxPrice != null ||
      minRooms != null;

  PropertyFilter copyWith({
    String? keyword,
    int? cityId,
    int? propertyTypeId,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    SortOption? sortBy,
    bool clearCity = false,
    bool clearType = false,
    bool clearListingType = false,
    bool clearPriceRange = false,
    bool clearRooms = false,
  }) {
    return PropertyFilter(
      keyword: keyword ?? this.keyword,
      cityId: clearCity ? null : (cityId ?? this.cityId),
      propertyTypeId: clearType ? null : (propertyTypeId ?? this.propertyTypeId),
      listingType: clearListingType ? null : (listingType ?? this.listingType),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      minRooms: clearRooms ? null : (minRooms ?? this.minRooms),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Keeps the keyword but drops every filter — used by "مسح الفلاتر".
  PropertyFilter cleared() => PropertyFilter(keyword: keyword);

  @override
  List<Object?> get props =>
      [keyword, cityId, propertyTypeId, listingType, minPrice, maxPrice, minRooms, sortBy];
}
