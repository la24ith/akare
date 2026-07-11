import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:akare/core/constants/app_colors.dart';

/// Shows the address and a button that opens Google Maps with the property's
/// coordinates. Kept as a simple card instead of an embedded `GoogleMap`
/// widget, since that needs platform API keys configured per project —
/// swap in `google_maps_flutter` here once those keys are set up.
class LocationCard extends StatelessWidget {
  final String? addressText;
  final double? latitude;
  final double? longitude;

  const LocationCard({
    super.key,
    this.addressText,
    this.latitude,
    this.longitude,
  });

  Future<void> _openInMaps() async {
    if (latitude == null || longitude == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              addressText ?? 'الموقع غير متوفر',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasLocation)
            TextButton(
              onPressed: _openInMaps,
              child: const Text(
                'فتح في الخرائط',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
