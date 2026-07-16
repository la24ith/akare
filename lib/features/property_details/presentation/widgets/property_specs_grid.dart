import 'package:flutter/material.dart';

import 'package:akare/core/theme/app_colors.dart';

class PropertySpecsGrid extends StatelessWidget {
  final double areaSqm;
  final int? roomsCount;
  final int? bathroomsCount;
  final String propertyTypeName;

  const PropertySpecsGrid({
    super.key,
    required this.areaSqm,
    required this.propertyTypeName,
    this.roomsCount,
    this.bathroomsCount,
  });

  @override
  Widget build(BuildContext context) {
    final specs = <_Spec>[
      _Spec(
        Icons.square_foot_rounded,
        '${areaSqm.toStringAsFixed(0)} م²',
        'المساحة',
      ),
      if (roomsCount != null) _Spec(Icons.bed_outlined, '$roomsCount', 'الغرف'),
      if (bathroomsCount != null)
        _Spec(Icons.bathtub_outlined, '$bathroomsCount', 'الحمامات'),
      _Spec(Icons.category_outlined, propertyTypeName, 'النوع'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: specs.map((s) => _SpecItem(spec: s)).toList(),
      ),
    );
  }
}

class _Spec {
  final IconData icon;
  final String value;
  final String label;
  _Spec(this.icon, this.value, this.label);
}

class _SpecItem extends StatelessWidget {
  final _Spec spec;
  const _SpecItem({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(spec.icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          spec.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          spec.label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
