// lib/features/property_details/presentation/widgets/property_share_card.dart
import 'package:akare/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// البطاقة البصرية اللي رح تُلتقط كصورة PNG وتُشارك. حجمها ثابت (1080×1350 —
/// نسبة شائعة لقصص انستغرام/واتساب ستاتوس) بغض النظر عن حجم الشاشة.
class PropertyShareCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final double price;
  final bool isForSale;
  final String cityName;
  final double areaSqm;
  final int? roomsCount;

  const PropertyShareCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.isForSale,
    required this.cityName,
    required this.areaSqm,
    this.roomsCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1080,
      height: 1350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الصورة الخلفية
          if (imageUrl != null)
            CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
          else
            Container(color: AppColors.divider),

          // تدرّج داكن من الأسفل لوضوح النص
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.35, 1],
              ),
            ),
          ),

          // شعار التطبيق أعلى يمين
          Positioned(
            top: 48,
            right: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Text(
                'عقارك',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // بادج بيع/إيجار أعلى يسار
          Positioned(
            top: 48,
            left: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: isForSale ? AppColors.primary : const Color(0xFF3E6FE0),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                isForSale ? 'للبيع' : 'للإيجار',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // محتوى الأسفل
          Positioned(
            left: 48,
            right: 48,
            bottom: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${price.toStringAsFixed(0)} د.أ',
                  style: const TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 28),
                    const Icon(
                      Icons.square_foot_rounded,
                      color: Colors.white70,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${areaSqm.toStringAsFixed(0)} م²',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (roomsCount != null) ...[
                      const SizedBox(width: 28),
                      const Icon(
                        Icons.bed_rounded,
                        color: Colors.white70,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$roomsCount',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
