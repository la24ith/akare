// lib/features/comparison/presentation/widgets/compare_floating_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/compare_selection_cubit.dart';
import '../cubit/compare_selection_state.dart';

/// ضعه بـ Stack أسفل أي شاشة نتائج (Search مثلًا) — بيظهر وينزلق للأعلى
/// تلقائيًا فقط لما يكون في عقار واحد على الأقل محدد للمقارنة.
class CompareFloatingBar extends StatelessWidget {
  const CompareFloatingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareSelectionCubit, CompareSelectionState>(
      builder: (context, state) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          offset: state.selected.isEmpty ? const Offset(0, 2) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: state.selected.isEmpty ? 0 : 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: state.selected.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: p.mainImageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: p.mainImageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.white24,
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${state.selected.length}/${CompareSelectionState.maxItems} عقارات محددة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: state.canCompare
                        ? () => context.push('/compare')
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'قارن الآن',
                      style: TextStyle(
                        color: state.canCompare
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
