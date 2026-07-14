import "package:akare/core/constants/app_colors.dart";
import "package:akare/core/di/injection_container.dart";
import "package:akare/features/home/presentation/widgets/home_section_states.dart";
import "package:akare/features/notifications/presentation/widgets/notification_bell.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../cubit/agent_dashboard_cubit.dart";
import "../widgets/dashboard_shimmer.dart";
import "../widgets/stat_card.dart";

class AgentDashboardScreen extends StatelessWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AgentDashboardCubit>()..loadDashboard(),
      child: const _AgentDashboardView(),
    );
  }
}

class _AgentDashboardView extends StatelessWidget {
  const _AgentDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [NotificationBell(), SizedBox(width: 8)]),
      backgroundColor: const Color(0xFFF7F8F8),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push("/agent/properties/add"),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("إضافة عقار", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AgentDashboardCubit>().loadDashboard(),
          child: BlocBuilder<AgentDashboardCubit, AgentDashboardState>(
            builder: (context, state) {
              if (state.status == AgentDashboardStatus.loading &&
                  state.stats == null) {
                return const AgentDashboardShimmer();
              }
              if (state.status == AgentDashboardStatus.error &&
                  state.stats == null) {
                return SectionError(
                  message: state.errorMessage ?? "تعذّر تحميل البيانات",
                  onRetry: () =>
                      context.read<AgentDashboardCubit>().loadDashboard(),
                );
              }
              final stats = state.stats;
              if (stats == null) return const SizedBox.shrink();

              final hasNoProperties =
                  stats.activeCount == 0 &&
                  stats.pendingCount == 0 &&
                  stats.soldOrRentedCount == 0;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _WelcomeHeader(
                    name: stats.agentName,
                    avatarUrl: stats.agentAvatarUrl,
                    isVerified: stats.isVerifiedAgent,
                  ),
                  const SizedBox(height: 20),
                  if (hasNoProperties)
                    _EmptyDashboardState(
                      onAdd: () => context.push("/agent/properties/add"),
                    )
                  else ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          title: "عقارات نشطة",
                          value: "${stats.activeCount}",
                          icon: Icons.check_circle_outline,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: "قيد المراجعة",
                          value: "${stats.pendingCount}",
                          icon: Icons.hourglass_empty,
                          color: AppColors.accent,
                        ),
                        StatCard(
                          title: "مباعة / مؤجرة",
                          value: "${stats.soldOrRentedCount}",
                          icon: Icons.sell_outlined,
                          color: const Color(0xFF6B7A76),
                        ),
                        StatCard(
                          title: "إجمالي المشاهدات",
                          value: "${stats.totalViews}",
                          icon: Icons.visibility_outlined,
                          color: const Color(0xFF3B82C4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: "أحدث عقاراتي"),
                    const SizedBox(height: 12),
                    if (stats.recentProperties.isEmpty)
                      const EmptyProperties(message: "لا توجد عقارات بعد")
                    else
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: stats.recentProperties.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final p = stats.recentProperties[index];
                            return SizedBox(
                              width: 160,
                              child: GestureDetector(
                                onTap: () =>
                                    context.push("/agent/properties/${p.id}"),
                                child: HeroPropertyPlaceholder(
                                  propertyId: p.id,
                                  imageUrl: p.mainImageUrl,
                                  title: p.title,
                                  price: p.price,
                                  status: p.listingType,
                                  subtitle: p.mainImageUrl != null
                                      ? "${p.roomsCount ?? 0} غرف · ${p.areaSqm.toStringAsFixed(0)} م²"
                                      : p.cityName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// بطاقة عرض مصغّرة لعقار ضمن قائمة أفقية (مثلاً "أحدث عقاراتي" بالداشبورد).
///
/// بديل عن الـ placeholder الفارغ السابق — تعرض فعلياً:
/// صورة، بادج حالة، سعر، عنوان، وسطر مواصفات مختصر.
///
/// ⚠️ عدّل أسماء الحقول بالـ constructor حسب ما هو موجود فعلياً
/// بـ entity الخاص بـ stats.recentProperties[index] عندك.
class HeroPropertyPlaceholder extends StatelessWidget {
  final String propertyId;
  final String? imageUrl;
  final String title;
  final double price;
  final String status; // 'pending' | 'active' | 'rejected' | 'sold' | 'rented'
  final String? subtitle; // مثلاً: "3 غرف · 120 م²" أو اسم المدينة

  const HeroPropertyPlaceholder({
    super.key,
    required this.propertyId,
    required this.title,
    required this.price,
    required this.status,
    this.imageUrl,
    this.subtitle,
  });

  (Color, String) get _statusConfig => switch (status) {
    'pending' => (const Color(0xFFE7A94C), 'قيد المراجعة'),
    'active' => (AppColors.primary, 'منشور'),
    'rejected' => (AppColors.error, 'مرفوض'),
    'sold' => (const Color(0xFF6B7A76), 'مباع'),
    'rented' => (const Color(0xFF6B7A76), 'مؤجر'),
    _ => (AppColors.textSecondary, status),
  };

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _statusConfig;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة + بادج الحالة
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImageFallback(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  )
                else
                  _ImageFallback(),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // النصوص
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${price.toStringAsFixed(0)} د.أ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 32,
          color: Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isVerified;

  const _WelcomeHeader({
    required this.name,
    required this.avatarUrl,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  "أهلاً، $name",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFF0E6E5C), size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDashboardState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "ابدأ بإضافة أول عقار لك",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "عقاراتك ستظهر هنا بعد إضافتها",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text("أضف أول عقار"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
