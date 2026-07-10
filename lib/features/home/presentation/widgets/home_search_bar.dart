import 'package:akare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const HomeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'ابحث عن شقة، فيلا، أرض ...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
