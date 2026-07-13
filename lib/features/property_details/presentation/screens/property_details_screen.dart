import 'package:akare/core/constants/app_colors.dart';
import 'package:akare/core/di/injection_container.dart';
import 'package:akare/features/property_details/presentation/widgets/property_image_gallery.dart';
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
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              content: const Text(
                'تم إرسال البلاغ، شكرًا لك',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        PropertyImageGallery(
                          imageUrls: property.imageUrls,
                          isFavorite: property.isFavorite,
                          onBack: () => Navigator.of(context).maybePop(),
                          onFavoriteTap: () => context
                              .read<PropertyDetailsCubit>()
                              .toggleFavorite(),
                          onShareTap: () => SharePlus.instance.share(
                            ShareParams(
                              text:
                                  '${property.title} — ${property.price.toStringAsFixed(0)} د.أ',
                            ),
                          ),
                        ),
                        // soft fade so the rounded content sheet blends
                        // smoothly into the gallery below it.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price + badge row, in a soft highlighted card.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    AppColors.accent.withOpacity(0.12),
                                    AppColors.accent.withOpacity(0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${property.price.toStringAsFixed(0)} د.أ',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.visibility_outlined,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${property.viewsCount} مشاهدة',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListingBadge(isForSale: property.isForSale),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              property.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  property.cityName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            PropertySpecsGrid(
                              areaSqm: property.areaSqm,
                              roomsCount: property.roomsCount,
                              bathroomsCount: property.bathroomsCount,
                              propertyTypeName: property.propertyTypeName,
                            ),
                            const SizedBox(height: 26),
                            const _SectionHeader(
                              icon: Icons.description_rounded,
                              title: 'الوصف',
                            ),
                            const SizedBox(height: 10),
                            ExpandableDescription(text: property.description),
                            const SizedBox(height: 26),
                            const _SectionHeader(
                              icon: Icons.map_rounded,
                              title: 'الموقع',
                            ),
                            const SizedBox(height: 10),
                            LocationCard(
                              addressText: property.addressText,
                              latitude: property.latitude,
                              longitude: property.longitude,
                            ),
                            const SizedBox(height: 26),
                            const _SectionHeader(
                              icon: Icons.badge_rounded,
                              title: 'الوكيل العقاري',
                            ),
                            const SizedBox(height: 10),
                            AgentCard(agent: property.agent),
                            const SizedBox(height: 20),
                            Center(
                              child: TextButton.icon(
                                onPressed: () => showReportPropertySheet(
                                  context: context,
                                  onSubmit: (reason) => context
                                      .read<PropertyDetailsCubit>()
                                      .submitReport(reason),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                icon: const Icon(Icons.flag_outlined, size: 16),
                                label: const Text(
                                  'الإبلاغ عن هذا العقار',
                                  style: TextStyle(fontSize: 12.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Sticky bottom contact bar so the main call-to-action is
              // always reachable without hunting through the page.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomContactBar(agent: property.agent),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Small reusable section title with an icon in a soft rounded chip —
/// gives every section a consistent, polished rhythm.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Floating bottom bar with quick actions for reaching the agent.
/// Adjust the two callbacks (onCall / onMessage) to match however your
/// agent model exposes phone number / WhatsApp so it actually dials out.
class _BottomContactBar extends StatelessWidget {
  final dynamic agent;
  const _BottomContactBar({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: hook up to agent phone number
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text(
                'اتصال',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: hook up to whatsapp / in-app chat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: const Text(
                'تواصل مع الوكيل',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(height: 18),
          ShimmerBox(
            width: 140,
            height: 22,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 10),
          ShimmerBox(height: 16, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 20),
          const ShimmerBox(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(height: 20),
          ShimmerBox(height: 60, borderRadius: BorderRadius.circular(14)),
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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
