import 'package:flutter/material.dart';

import 'package:akare/core/constants/app_colors.dart';

/// Lightweight shimmer built with a moving [LinearGradient] shader — avoids
/// pulling in the `shimmer` package just for this effect.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1 + 3 * t, 0),
              end: Alignment(1 + 3 * t, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder that mirrors [PropertyCard]'s layout so the loading state
/// doesn't jump when real content arrives.
class PropertyCardShimmer extends StatelessWidget {
  const PropertyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            height: 140,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          const SizedBox(height: 10),
          ShimmerBox(
            width: 160,
            height: 14,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          ShimmerBox(
            width: 100,
            height: 14,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }
}

class PropertyListTileShimmer extends StatelessWidget {
  const PropertyListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const ShimmerBox(
            width: 100,
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: 140,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: 90,
                  height: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
