import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:akare/core/constants/app_colors.dart';
import '../../../home/domain/entities/property_entity.dart';
import '../../../home/presentation/widgets/property_card.dart';

class PropertyGridTile extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PropertyGridTile({
    super.key,
    required this.property,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: property.mainImageUrl == null
                        ? Container(
                            color: AppColors.divider,
                            child: const Icon(
                              Icons.home_outlined,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: property.mainImageUrl!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListingBadge(isForSale: property.isForSale),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${property.price.toStringAsFixed(0)} د.أ',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
