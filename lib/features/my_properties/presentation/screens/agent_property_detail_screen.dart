import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/agent_property_detail_entity.dart';
import '../cubit/agent_property_detail_cubit.dart';
import '../cubit/agent_property_detail_state.dart';

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.example.akare'; // بدّله لـ applicationId الفعلي عندك

class AgentPropertyDetailScreen extends StatelessWidget {
  final String propertyId;
  const AgentPropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AgentPropertyDetailCubit>()..load(propertyId),
      child: _AgentPropertyDetailView(propertyId: propertyId),
    );
  }
}

class _AgentPropertyDetailView extends StatefulWidget {
  final String propertyId;
  const _AgentPropertyDetailView({required this.propertyId});

  @override
  State<_AgentPropertyDetailView> createState() =>
      _AgentPropertyDetailViewState();
}

class _AgentPropertyDetailViewState extends State<_AgentPropertyDetailView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العقار'),
        content: const Text('هل أنت متأكد؟ هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AgentPropertyDetailCubit>().delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AgentPropertyDetailCubit, AgentPropertyDetailState>(
        listenWhen: (p, c) => p.wasDeleted != c.wasDeleted && c.wasDeleted,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حذف العقار')));
          context.pop();
        },
        builder: (context, state) {
          if (state.status == AgentPropertyDetailStatus.loading ||
              state.status == AgentPropertyDetailStatus.initial) {
            return const _DetailShimmer();
          }

          if (state.status == AgentPropertyDetailStatus.error) {
            return _DetailError(
              message: state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
              onRetry: () => context.read<AgentPropertyDetailCubit>().load(
                widget.propertyId,
              ),
            );
          }

          final p = state.property!;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Gallery(
                  imageUrls: p.imageUrls,
                  pageController: _pageController,
                  currentPage: _currentPage,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  onBack: () => context.pop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBanner(
                        status: p.status,
                        rejectionReason: p.rejectionReason,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${p.price.toStringAsFixed(0)} د.أ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.visibility_outlined,
                            label: '${p.viewsCount} مشاهدة',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.favorite_border,
                            label: '${p.favoritesCount} إعجاب',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SpecsGrid(property: p),
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
                      _ExpandableText(text: p.description),
                      if (p.latitude != null && p.longitude != null) ...[
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
                        _LocationPreview(
                          latitude: p.latitude!,
                          longitude: p.longitude!,
                          addressText: p.addressText,
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/agent/properties/edit/${p.id}',
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('تعديل'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: state.isActionInProgress
                                  ? null
                                  : () => _confirmDelete(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('حذف'),
                            ),
                          ),
                        ],
                      ),
                      if (p.isActive) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isActionInProgress
                                ? null
                                : () => context
                                      .read<AgentPropertyDetailCubit>()
                                      .updateStatus(
                                        p.isForSale ? 'sold' : 'rented',
                                      ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              p.isForSale ? 'تحديد كمباع' : 'تحديد كمؤجر',
                            ),
                          ),
                        ),
                      ],
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

/// معرض صور بسيط: PageView + مؤشرات نقاط + زر رجوع — بدون اعتماد على
/// أي widget خارجي مشترك.
class _Gallery extends StatelessWidget {
  final List<String> imageUrls;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;

  const _Gallery({
    required this.imageUrls,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrls.isEmpty
              ? Container(
                  color: AppColors.divider,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 56,
                    color: AppColors.textSecondary,
                  ),
                )
              : PageView.builder(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => Container(color: AppColors.divider),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.divider,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (i) {
                  final isActive = i == currentPage;
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

class _StatusBanner extends StatelessWidget {
  final String status;
  final String? rejectionReason;
  const _StatusBanner({required this.status, this.rejectionReason});

  (Color, String) get _config => switch (status) {
    'pending' => (const Color(0xFFE7A94C), 'قيد المراجعة'),
    'active' => (AppColors.primary, 'منشور'),
    'rejected' => (AppColors.error, 'مرفوض'),
    'sold' => (const Color(0xFF6B7A76), 'مباع'),
    'rented' => (const Color(0xFF6B7A76), 'مؤجر'),
    _ => (AppColors.textSecondary, status),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _config;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
        if (status == 'rejected' && rejectionReason != null) ...[
          const SizedBox(height: 8),
          Text(
            'سبب الرفض: $rejectionReason',
            style: const TextStyle(color: AppColors.error, fontSize: 12.5),
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final AgentPropertyDetailEntity property;
  const _SpecsGrid({required this.property});

  @override
  Widget build(BuildContext context) {
    final specs = <(IconData, String, String)>[
      (
        Icons.square_foot_rounded,
        '${property.areaSqm.toStringAsFixed(0)} م²',
        'المساحة',
      ),
      if (property.roomsCount != null)
        (Icons.bed_outlined, '${property.roomsCount}', 'الغرف'),
      if (property.bathroomsCount != null)
        (Icons.bathtub_outlined, '${property.bathroomsCount}', 'الحمامات'),
      (Icons.category_outlined, property.propertyTypeName, 'النوع'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: specs.map((s) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(s.$1, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                s.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.$3,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _expanded ? 'عرض أقل' : 'قراءة المزيد',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// معاينة موقع مصغّرة (flutter_map، بدون تفاعل) + زر فتح بخرائط Google —
/// نسخة مكتفية بذاتها، بدون استيراد من ميزة property_details.
class _LocationPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? addressText;
  const _LocationPreview({
    required this.latitude,
    required this.longitude,
    this.addressText,
  });

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final point = ll.LatLng(latitude, longitude);
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            child: AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileUrl,
                    userAgentPackageName: _userAgent,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    addressText ?? 'الموقع محدد على الخريطة',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openDirections,
                  child: const Text(
                    'فتح في الخرائط',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DetailError({required this.message, required this.onRetry});

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
