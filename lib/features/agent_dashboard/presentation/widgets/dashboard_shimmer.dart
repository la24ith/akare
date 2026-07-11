import "package:akare/features/home/presentation/widgets/home_shimmer.dart";
import "package:flutter/material.dart";

class AgentDashboardShimmer extends StatelessWidget {
  const AgentDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 180,
            height: 24,
            borderRadius: BorderRadius.circular(18),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(
              4,
              (_) => ShimmerBox(
                borderRadius: BorderRadius.circular(18),
                height: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShimmerBox(
            width: 140,
            height: 24,
            borderRadius: BorderRadius.circular(18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => ShimmerBox(
                width: 150,
                height: 180,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
