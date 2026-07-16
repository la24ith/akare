// lib/features/price_history/presentation/widgets/price_history_timeline.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/price_point_entity.dart';
import '../cubit/price_history_cubit.dart';
import '../cubit/price_history_state.dart';

/// ضعه بأي مكان بشاشة تفاصيل العقار — يوفّر الـ Cubit بنفسه ويحمّل البيانات
/// تلقائيًا. ما بيظهر إطلاقًا لو العقار إله نقطة سعر وحدة بس (ولا تغيير
/// حصل)، عشان ما نعرض تايم لاين فاضي المعنى.
class PriceHistoryTimeline extends StatelessWidget {
  final String propertyId;
  const PriceHistoryTimeline({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PriceHistoryCubit>()..load(propertyId),
      child: const _PriceHistoryView(),
    );
  }
}

// lib/features/price_history/presentation/widgets/price_history_timeline.dart
// بدّل _PriceHistoryView بالكامل بهاد:

class _PriceHistoryView extends StatelessWidget {
  const _PriceHistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PriceHistoryCubit, PriceHistoryState>(
      builder: (context, state) {
        if (state.status == PriceHistoryStatus.loading ||
            state.status == PriceHistoryStatus.initial) {
          return const _TimelineShimmer();
        }
        // خطأ أو أقل من نقطتين (عقار بسعر ثابت من البداية) — لا نعرض
        // القسم إطلاقًا، لا العنوان ولا المحتوى، صفر مساحة فارغة.
        if (state.status == PriceHistoryStatus.error ||
            state.points.length < 2) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تاريخ الأسعار',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedTimeline(points: state.points),
          ],
        );
      },
    );
  }
}

class _TimelineShimmer extends StatelessWidget {
  const _TimelineShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 90,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _AnimatedTimeline extends StatefulWidget {
  final List<PricePointEntity> points;
  const _AnimatedTimeline({required this.points});

  @override
  State<_AnimatedTimeline> createState() => _AnimatedTimelineState();
}

class _AnimatedTimelineState extends State<_AnimatedTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // مدة الأنيميشن تتناسب مع عدد النقاط — كل ما زادت النقاط، وقت أطول
    // شوي عشان يضل التتابع محسوس ومش سريع جدًا.
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.points.length * 220),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الأحدث فوق، الأقدم تحت — أكثر منطقية لقراءة "شو صار مؤخرًا" أول شي
    final reversed = widget.points.reversed.toList();
    final count = reversed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(reversed.length, (index) {
        final point = reversed[index];
        // السعر السابق زمنيًا (للمقارنة اتجاه السهم) هو العنصر التالي بالقائمة المعكوسة
        final previousPrice = index < reversed.length - 1
            ? reversed[index + 1].price
            : null;

        // كل عنصر بيبلش أنيميشنه بعد سابقه بفارق بسيط — تتابع (staggered)
        final start = index / count * 0.6;
        final end = (start + 0.5).clamp(0.0, 1.0);
        final interval = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: interval,
          builder: (context, child) {
            return Opacity(
              opacity: interval.value,
              child: Transform.translate(
                offset: Offset(0, (1 - interval.value) * 16),
                child: child,
              ),
            );
          },
          child: _TimelineTile(
            point: point,
            previousPrice: previousPrice,
            isFirst: index == 0,
            isLast: index == reversed.length - 1,
          ),
        );
      }),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final PricePointEntity point;
  final double? previousPrice;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.point,
    required this.previousPrice,
    required this.isFirst,
    required this.isLast,
  });

  (IconData, Color)? get _trend {
    if (previousPrice == null) return null;
    if (point.price < previousPrice!)
      return (
        Icons.trending_down_rounded,
        AppColors.primary,
      ); // انخفض = إيجابي للمشتري
    if (point.price > previousPrice!)
      return (Icons.trending_up_rounded, AppColors.error);
    return null;
  }

  String get _relativeDate {
    final diff = DateTime.now().difference(point.changedAt);
    if (diff.inDays < 1) return 'اليوم';
    if (diff.inDays < 7)
      return 'قبل ${diff.inDays} ${diff.inDays == 1 ? "يوم" : "أيام"}';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'قبل $weeks ${weeks == 1 ? "أسبوع" : "أسابيع"}';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'قبل $months ${months == 1 ? "شهر" : "أشهر"}';
    }
    final years = (diff.inDays / 365).floor();
    return 'قبل $years ${years == 1 ? "سنة" : "سنوات"}';
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trend;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العمود الرأسي: نقطة + خط واصل
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: isFirst ? 16 : 12,
                  height: isFirst ? 16 : 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: isFirst ? 0 : 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // المحتوى
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _relativeDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${point.price.toStringAsFixed(0)} د.أ',
                          style: TextStyle(
                            fontSize: isFirst ? 18 : 15,
                            fontWeight: isFirst
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isFirst
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: trend.$2.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(trend.$1, size: 16, color: trend.$2),
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
