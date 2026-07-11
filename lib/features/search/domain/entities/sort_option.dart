enum SortOption { newest, priceLowToHigh, priceHighToLow }

extension SortOptionLabel on SortOption {
  String get labelAr => switch (this) {
        SortOption.newest => 'الأحدث',
        SortOption.priceLowToHigh => 'الأقل سعرًا',
        SortOption.priceHighToLow => 'الأعلى سعرًا',
      };
}
