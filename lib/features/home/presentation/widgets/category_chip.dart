import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/property_type_entity.dart';

/// Maps the backend's `icon_name` string to a concrete Material icon.
/// Falls back to a generic home icon for unrecognized names so new
/// property types never render blank.
IconData iconForPropertyType(String iconName) {
  const map = {
    'apartment': Icons.apartment_rounded,
    'villa': Icons.villa_rounded,
    'land': Icons.terrain_rounded,
    'office': Icons.business_center_rounded,
    'shop': Icons.storefront_rounded,
  };
  return map[iconName] ?? Icons.home_work_rounded;
}

class CategoryChip extends StatelessWidget {
  final PropertyTypeEntity type;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.type,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                iconForPropertyType(type.iconName),
                color: isSelected ? Colors.white : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                type.nameAr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
