import "package:akare/core/constants/app_colors.dart";
import "package:akare/core/di/injection_container.dart";
import "package:akare/features/home/presentation/widgets/home_section_states.dart";
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

/// بديل بسيط لبطاقة PropertyCard الأفقية — استبدله ببطاقتك الفعلية
/// (PropertyCard) الموجودة مسبقًا مع تمرير بادج الحالة الملوّن.
class HeroPropertyPlaceholder extends StatelessWidget {
  final String propertyId;
  const HeroPropertyPlaceholder({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
