import 'package:akare/core/constants/app_colors.dart';
import 'package:akare/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
// exposes `sl` (GetIt.instance) — adjust path/name if yours differs
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../../home/presentation/widgets/property_card.dart';
import '../cubit/property_details_cubit.dart';
import '../cubit/property_details_state.dart';
import '../widgets/agent_card.dart';
import '../widgets/expandable_description.dart';
import '../widgets/location_card.dart';
import '../widgets/property_image_gallery.dart';
import '../widgets/property_specs_grid.dart';
import '../widgets/report_bottom_sheet.dart';

/// Public entry point. Provides its own [PropertyDetailsCubit] so it works
/// no matter how it's navigated to.
class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;
  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PropertyDetailsCubit>()..load(propertyId),
      child: _PropertyDetailsView(propertyId: propertyId),
    );
  }
}

class _PropertyDetailsView extends StatelessWidget {
  final String propertyId;
  const _PropertyDetailsView({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PropertyDetailsCubit, PropertyDetailsState>(
        listenWhen: (p, c) =>
            p.reportSubmitted != c.reportSubmitted && c.reportSubmitted,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال البلاغ، شكرًا لك')),
          );
        },
        builder: (context, state) {
          if (state.status == PropertyDetailsStatus.loading ||
              state.status == PropertyDetailsStatus.initial) {
            return const _DetailsShimmer();
          }

          if (state.status == PropertyDetailsStatus.error) {
            return _DetailsError(
              message: state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
              onRetry: () =>
                  context.read<PropertyDetailsCubit>().load(propertyId),
            );
          }

          final property = state.property!;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PropertyImageGallery(
                  imageUrls: property.imageUrls,
                  isFavorite: property.isFavorite,
                  onBack: () => Navigator.of(context).maybePop(),
                  onFavoriteTap: () =>
                      context.read<PropertyDetailsCubit>().toggleFavorite(),
                  onShareTap: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${property.title} — ${property.price.toStringAsFixed(0)} د.أ',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${property.price.toStringAsFixed(0)} د.أ',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          ListingBadge(isForSale: property.isForSale),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            property.cityName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${property.viewsCount} مشاهدة',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PropertySpecsGrid(
                        areaSqm: property.areaSqm,
                        roomsCount: property.roomsCount,
                        bathroomsCount: property.bathroomsCount,
                        propertyTypeName: property.propertyTypeName,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'الوصف',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExpandableDescription(text: property.description),
                      const SizedBox(height: 20),
                      const Text(
                        'الموقع',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LocationCard(
                        addressText: property.addressText,
                        latitude: property.latitude,
                        longitude: property.longitude,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'الوكيل العقاري',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AgentCard(agent: property.agent),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => showReportPropertySheet(
                            context: context,
                            onSubmit: (reason) => context
                                .read<PropertyDetailsCubit>()
                                .submitReport(reason),
                          ),
                          icon: const Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          label: const Text(
                            'الإبلاغ عن هذا العقار',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailsShimmer extends StatelessWidget {
  const _DetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            height: 280,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(height: 18),
          ShimmerBox(
            width: 140,
            height: 22,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 10),
          ShimmerBox(height: 16, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 20),
          const ShimmerBox(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          const SizedBox(height: 20),
          ShimmerBox(height: 60, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
