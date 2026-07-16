import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../home/domain/entities/property_type_entity.dart';
import '../../../home/presentation/widgets/category_chip.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/entities/sort_option.dart';

const _maxPriceCeiling = 1000000.0;

Future<void> showFilterSheet({
  required BuildContext context,
  required PropertyFilter currentFilter,
  required List<CityEntity> cities,
  required List<PropertyTypeEntity> propertyTypes,
  required ValueChanged<PropertyFilter> onApply,
  required VoidCallback onClear,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _FilterSheet(
      initialFilter: currentFilter,
      cities: cities,
      propertyTypes: propertyTypes,
      onApply: onApply,
      onClear: onClear,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  final PropertyFilter initialFilter;
  final List<CityEntity> cities;
  final List<PropertyTypeEntity> propertyTypes;
  final ValueChanged<PropertyFilter> onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.initialFilter,
    required this.cities,
    required this.propertyTypes,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late PropertyFilter _draft = widget.initialFilter;
  late RangeValues _priceRange = RangeValues(
    widget.initialFilter.minPrice ?? 0,
    widget.initialFilter.maxPrice ?? _maxPriceCeiling,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الفلاتر',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _draft = _draft.cleared();
                              _priceRange = const RangeValues(
                                0,
                                _maxPriceCeiling,
                              );
                            });
                          },
                          child: const Text(
                            'مسح الفلاتر',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label('المدينة'),
                    _CityDropdown(
                      cities: widget.cities,
                      selectedId: _draft.cityId,
                      onChanged: (id) => setState(
                        () => _draft = _draft.copyWith(
                          cityId: id,
                          clearCity: id == null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('نوع العقار'),
                    SizedBox(
                      height: 84,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        itemCount: widget.propertyTypes.length,
                        itemBuilder: (context, index) {
                          final type = widget.propertyTypes[index];
                          return CategoryChip(
                            type: type,
                            isSelected: _draft.propertyTypeId == type.id,
                            onTap: () => setState(() {
                              final selected = _draft.propertyTypeId == type.id;
                              _draft = _draft.copyWith(
                                propertyTypeId: selected ? null : type.id,
                                clearType: selected,
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('بيع أم إيجار'),
                    Row(
                      children: [
                        _ChoiceButton(
                          label: 'الكل',
                          isSelected: _draft.listingType == null,
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(
                              clearListingType: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ChoiceButton(
                          label: 'للبيع',
                          isSelected: _draft.listingType == 'sale',
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(listingType: 'sale'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ChoiceButton(
                          label: 'للإيجار',
                          isSelected: _draft.listingType == 'rent',
                          onTap: () => setState(
                            () => _draft = _draft.copyWith(listingType: 'rent'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _label('نطاق السعر (د.أ)'),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: _maxPriceCeiling,
                      divisions: 50,
                      activeColor: AppColors.primary,
                      labels: RangeLabels(
                        _priceRange.start.toStringAsFixed(0),
                        _priceRange.end.toStringAsFixed(0),
                      ),
                      onChanged: (values) =>
                          setState(() => _priceRange = values),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_priceRange.start.toStringAsFixed(0)} د.أ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_priceRange.end.toStringAsFixed(0)} د.أ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _label('عدد الغرف (كحد أدنى)'),
                    _RoomsStepper(
                      value: _draft.minRooms ?? 0,
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(
                          minRooms: v == 0 ? null : v,
                          clearRooms: v == 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('الترتيب'),
                    _SortDropdown(
                      value: _draft.sortBy,
                      onChanged: (v) =>
                          setState(() => _draft = _draft.copyWith(sortBy: v)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final result = _draft.copyWith(
                        minPrice: _priceRange.start > 0
                            ? _priceRange.start
                            : null,
                        maxPrice: _priceRange.end < _maxPriceCeiling
                            ? _priceRange.end
                            : null,
                        clearPriceRange:
                            _priceRange.start == 0 &&
                            _priceRange.end == _maxPriceCeiling,
                      );
                      Navigator.of(context).pop();
                      widget.onApply(result);
                    },
                    child: const Text(
                      'بحث',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

class _CityDropdown extends StatelessWidget {
  final List<CityEntity> cities;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  const _CityDropdown({
    required this.cities,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: selectedId,
          hint: const Text(
            'كل المدن',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('كل المدن')),
            ...cities.map(
              (c) => DropdownMenuItem(value: c.id, child: Text(c.nameAr)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomsStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _RoomsStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stepButton(Icons.remove, () => onChanged((value - 1).clamp(0, 10))),
        Expanded(
          child: Text(
            value == 0 ? 'الكل' : '$value+',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _stepButton(Icons.add, () => onChanged((value + 1).clamp(0, 10))),
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final SortOption value;
  final ValueChanged<SortOption> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          isExpanded: true,
          value: value,
          items: SortOption.values
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(
                    o.labelAr,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}
