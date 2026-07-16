import "package:akare/core/theme/app_colors.dart";
import "package:flutter/material.dart";
import "../../domain/entities/my_property_entity.dart";

class PropertyFilterChips extends StatelessWidget {
  final PropertyStatusFilter selected;
  final ValueChanged<PropertyStatusFilter> onChanged;

  const PropertyFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _labels = {
    PropertyStatusFilter.all: "الكل",
    PropertyStatusFilter.pending: "معلّقة",
    PropertyStatusFilter.active: "نشطة",
    PropertyStatusFilter.rejected: "مرفوضة",
    PropertyStatusFilter.sold: "مباعة",
    PropertyStatusFilter.rented: "مؤجرة",
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _labels.keys.elementAt(index);
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(_labels[filter]!),
            selected: isSelected,
            onSelected: (_) => onChanged(filter),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          );
        },
      ),
    );
  }
}
