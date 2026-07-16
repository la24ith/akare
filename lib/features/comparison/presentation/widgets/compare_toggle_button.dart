// lib/features/comparison/presentation/widgets/compare_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../cubit/compare_selection_cubit.dart';
import '../cubit/compare_selection_state.dart';

/// ضعه بـ Stack فوق أي بطاقة عقار (نفس مكان زر المفضلة تمامًا)، بأي شاشة
/// عندك فيها PropertyCard/PropertyListTile/PropertyGridTile — بدون الحاجة
/// لتعديل تلك الملفات نفسها.
class CompareToggleButton extends StatelessWidget {
  final PropertyEntity property;
  const CompareToggleButton({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareSelectionCubit, CompareSelectionState>(
      builder: (context, state) {
        final isSelected = state.isSelected(property.id);
        final disabled = !isSelected && state.isFull;

        return GestureDetector(
          onTap: disabled
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يمكن مقارنة 4 عقارات كحد أقصى'),
                  ),
                )
              : () => context.read<CompareSelectionCubit>().toggle(property),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              isSelected ? Icons.check_rounded : Icons.compare_arrows_rounded,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (disabled ? AppColors.textSecondary : AppColors.primary),
            ),
          ),
        );
      },
    );
  }
}
