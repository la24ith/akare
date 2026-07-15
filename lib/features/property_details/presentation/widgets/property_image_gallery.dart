import 'package:akare/features/property_details/presentation/widgets/property_qr_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:akare/core/constants/app_colors.dart';

class PropertyImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;
  final String propertyId;
  final String propertyTitle;

  const PropertyImageGallery({
    super.key,
    required this.imageUrls,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteTap,
    required this.onShareTap,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<PropertyImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: images.isEmpty
                ? Container(
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.home_outlined,
                      size: 56,
                      color: AppColors.textSecondary,
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) =>
                          Container(color: AppColors.divider),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.divider,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
          ),
          // Subtle gradient so the top buttons stay legible over bright photos.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.25],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_forward,
                  onTap: widget.onBack,
                ),
                const Spacer(),
                _CircleIconButton(icon: Icons.share, onTap: widget.onShareTap),
                const SizedBox(width: 10),
                _CircleIconButton(
                  icon: widget.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  iconColor: widget.isFavorite
                      ? AppColors.error
                      : AppColors.textPrimary,
                  onTap: widget.onFavoriteTap,
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  // أو _CircleIconButton حسب أي نسخة عندك من الشاشة
                  icon: Icons.qr_code_rounded,
                  onTap: () => showPropertyQrSheet(
                    context: context,
                    propertyId: widget.propertyId,
                    propertyTitle: widget.propertyTitle,
                  ),
                ),
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
