// lib/features/comparison/presentation/screens/comparison_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../cubit/compare_selection_cubit.dart';
import '../cubit/compare_selection_state.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CompareSelectionCubit>(),
      child: const _ComparisonView(),
    );
  }
}

class _ComparisonView extends StatelessWidget {
  const _ComparisonView();

  static const _rowHeight = 52.0;
  static const _columnWidth = 150.0;
  static const _labelWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مقارنة العقارات'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          BlocBuilder<CompareSelectionCubit, CompareSelectionState>(
            builder: (context, state) => state.selected.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () =>
                        context.read<CompareSelectionCubit>().clear(),
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
          ),
        ],
      ),
      body: BlocBuilder<CompareSelectionCubit, CompareSelectionState>(
        builder: (context, state) {
          if (state.selected.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.compare_arrows_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.selected.isEmpty
                          ? 'اختر عقارين على الأقل من نتائج البحث لمقارنتهما'
                          : 'اختر عقارًا واحدًا إضافيًا على الأقل للمقارنة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          final rows = _buildRows(state.selected);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عمود التسميات — ثابت، ما بيتحرك مع التمرير الأفقي
                _LabelColumn(
                  rows: rows,
                  rowHeight: _rowHeight,
                  width: _labelWidth,
                ),
                const SizedBox(width: 8),
                // أعمدة العقارات — قابلة للتمرير أفقيًا
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.selected
                          .map(
                            (p) => _PropertyColumn(
                              property: p,
                              rows: rows,
                              rowHeight: _rowHeight,
                              width: _columnWidth,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_CompareRow> _buildRows(List<PropertyEntity> items) {
    // "الأفضل" لكل صف: أقل سعر أفضل، وأكبر قيمة أفضل للباقي.
    String? bestId(
      num? Function(PropertyEntity) getter, {
      bool lowerIsBetter = false,
    }) {
      PropertyEntity? best;
      num? bestValue;
      for (final p in items) {
        final v = getter(p);
        if (v == null) continue;
        if (bestValue == null ||
            (lowerIsBetter ? v < bestValue : v > bestValue)) {
          bestValue = v;
          best = p;
        }
      }
      return best?.id;
    }

    return [
      _CompareRow(
        icon: Icons.payments_rounded,
        label: 'السعر',
        valueOf: (p) => '${p.price.toStringAsFixed(0)} د.أ',
        bestPropertyId: bestId((p) => p.price, lowerIsBetter: true),
      ),
      _CompareRow(
        icon: Icons.square_foot_rounded,
        label: 'المساحة',
        valueOf: (p) => '${p.areaSqm.toStringAsFixed(0)} م²',
        bestPropertyId: bestId((p) => p.areaSqm),
      ),
      _CompareRow(
        icon: Icons.bed_rounded,
        label: 'الغرف',
        valueOf: (p) => p.roomsCount?.toString() ?? '—',
        bestPropertyId: bestId((p) => p.roomsCount),
      ),
      _CompareRow(
        icon: Icons.bathtub_rounded,
        label: 'الحمامات',
        valueOf: (p) => p.bathroomsCount?.toString() ?? '—',
        bestPropertyId: bestId((p) => p.bathroomsCount),
      ),
      _CompareRow(
        icon: Icons.location_on_rounded,
        label: 'المدينة',
        valueOf: (p) => p.cityName,
        bestPropertyId: null, // لا مقارنة كمية بالنص
      ),
      _CompareRow(
        icon: Icons.category_rounded,
        label: 'النوع',
        valueOf: (p) => p.propertyTypeName,
        bestPropertyId: null,
      ),
    ];
  }
}

class _CompareRow {
  final IconData icon;
  final String label;
  final String Function(PropertyEntity) valueOf;
  final String? bestPropertyId;
  _CompareRow({
    required this.icon,
    required this.label,
    required this.valueOf,
    this.bestPropertyId,
  });
}

class _LabelColumn extends StatelessWidget {
  final List<_CompareRow> rows;
  final double rowHeight;
  final double width;
  const _LabelColumn({
    required this.rows,
    required this.rowHeight,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          const SizedBox(
            height: 190,
          ), // يطابق ارتفاع رأس عمود العقار (صورة + سعر + عنوان)
          ...rows.map(
            (r) => SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  Icon(r.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyColumn extends StatelessWidget {
  final PropertyEntity property;
  final List<_CompareRow> rows;
  final double rowHeight;
  final double width;
  const _PropertyColumn({
    required this.property,
    required this.rows,
    required this.rowHeight,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // رأس العمود: صورة + زر إزالة + سعر + عنوان
          SizedBox(
            height: 190,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: property.mainImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: property.mainImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppColors.divider),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${property.price.toStringAsFixed(0)} د.أ',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            property.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => context.read<CompareSelectionCubit>().remove(
                      property.id,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // صفوف القيم
          ...rows.map((r) {
            final isBest = r.bestPropertyId == property.id;
            return Container(
              height: rowHeight,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: isBest
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
                border: const Border(
                  top: BorderSide(color: AppColors.divider, width: 0.6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isBest) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      r.valueOf(property),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isBest ? FontWeight.w800 : FontWeight.w600,
                        color: isBest
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
