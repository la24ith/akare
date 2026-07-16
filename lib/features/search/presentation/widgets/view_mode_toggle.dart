import 'package:flutter/material.dart';

import 'package:akare/core/theme/app_colors.dart';
import '../cubit/search_state.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode mode;
  final ValueChanged<ViewMode> onChanged;
  const ViewModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.view_list_rounded, ViewMode.list),
          _button(Icons.grid_view_rounded, ViewMode.grid),
        ],
      ),
    );
  }

  Widget _button(IconData icon, ViewMode value) {
    final isActive = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
