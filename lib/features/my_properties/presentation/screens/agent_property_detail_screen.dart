import 'dart:ui';
import 'package:akare/core/di/injection_container.dart';
import 'package:akare/features/property_details/domain/entities/agent_entity.dart';
import 'package:akare/features/property_details/domain/entities/property_details_entity.dart';
import 'package:akare/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:akare/features/property_details/presentation/cubit/property_details_state.dart';
import 'package:akare/features/property_details/presentation/widgets/report_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

/// ---------------------------------------------------------------------
/// PREMIUM PALETTE
/// A self-contained design language for this screen so it renders
/// consistently regardless of your existing AppColors. Swap `primary`
/// for _Palette.royalBlue if you prefer blue over emerald, or merge
/// these into your global AppColors class.
/// ---------------------------------------------------------------------
class _Palette {
  static const emerald = Color(0xFF16A34A);
  static const royalBlue = Color(0xFF2563EB);
  static const primary = emerald; // switch to royalBlue if preferred

  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F8FA);
  static const surfaceAlt = Color(0xFFF1F3F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE7E9EC);
  static const gold = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

const _fontFamily = 'SF Pro Display'; // falls back to Inter/system if absent

/// Public entry point.
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

class _PropertyDetailsView extends StatefulWidget {
  final String propertyId;
  const _PropertyDetailsView({required this.propertyId});

  @override
  State<_PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<_PropertyDetailsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      body: BlocConsumer<PropertyDetailsCubit, PropertyDetailsState>(
        listenWhen: (p, c) =>
            p.reportSubmitted != c.reportSubmitted && c.reportSubmitted,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: _Palette.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              content: const Text(
                'تم إرسال البلاغ، شكرًا لك',
                style: TextStyle(color: Colors.white, fontFamily: _fontFamily),
              ),
            ),
          );
        },
        builder: (context, state) {
          if (state.status == PropertyDetailsStatus.loading ||
              state.status == PropertyDetailsStatus.initial) {
            return const _PremiumShimmer();
          }
          if (state.status == PropertyDetailsStatus.error) {
            return _DetailsError(
              message: state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
              onRetry: () =>
                  context.read<PropertyDetailsCubit>().load(widget.propertyId),
            );
          }

          final property = state.property!;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroGallery(
                      imageUrls: property.imageUrls,
                      pageController: _pageController,
                      currentPage: _currentPage,
                      onPageChanged: (i) => setState(() => _currentPage = i),
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
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: _Palette.bg,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PriceHeader(property: property),
                            const SizedBox(height: 22),
                            _SpecsRow(property: property),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              icon: Icons.notes_rounded,
                              title: 'الوصف',
                            ),
                            const SizedBox(height: 12),
                            _ExpandableDescription(text: property.description),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              icon: Icons.place_rounded,
                              title: 'الموقع',
                            ),
                            const SizedBox(height: 12),
                            _MiniMapCard(
                              addressText:
                                  property.addressText ?? 'العنوان غير متوفر',
                              latitude: property.latitude,
                              longitude: property.longitude,
                            ),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              icon: Icons.badge_rounded,
                              title: 'الوكيل العقاري',
                            ),
                            const SizedBox(height: 12),
                            _AgentProfileCard(agent: property.agent),
                            const SizedBox(height: 22),
                            Center(
                              child: TextButton.icon(
                                onPressed: () => showReportPropertySheet(
                                  context: context,
                                  onSubmit: (reason) => context
                                      .read<PropertyDetailsCubit>()
                                      .submitReport(reason),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _Palette.textSecondary,
                                ),
                                icon: const Icon(Icons.flag_outlined, size: 16),
                                label: const Text(
                                  'الإبلاغ عن هذا العقار',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontFamily: _fontFamily,
                                  ),
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _StickyContactBar(agent: property.agent),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// =======================================================================
/// HERO GALLERY — immersive full-bleed image carousel with glass controls
/// =======================================================================
class _HeroGallery extends StatelessWidget {
  final List<String> imageUrls;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  const _HeroGallery({
    required this.imageUrls,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
            itemBuilder: (context, index) {
              if (imageUrls.isEmpty) {
                return Container(color: _Palette.surfaceAlt);
              }
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: _Palette.surfaceAlt);
                },
                errorBuilder: (context, error, stack) =>
                    Container(color: _Palette.surfaceAlt),
              );
            },
          ),
          // bottom gradient scrim for legibility + smooth blend into sheet
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33000000)],
                ),
              ),
            ),
          ),
          // floating top controls
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: onShareTap,
                    ),
                    const SizedBox(width: 10),
                    _GlassIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFavorite ? _Palette.danger : Colors.white,
                      onTap: onFavoriteTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // elegant page indicator dots
          if (imageUrls.length > 1)
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (i) {
                  final active = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
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

/// Glassmorphic circular icon button used for floating hero controls.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withOpacity(0.18),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================================
/// PRICE HEADER — price, status badge, title, location, views
/// =======================================================================
class _PriceHeader extends StatelessWidget {
  final PropertyDetailsEntity property;
  const _PriceHeader({required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                _Palette.primary.withOpacity(0.12),
                _Palette.primary.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [
                          _Palette.primary,
                          _Palette.primary.withOpacity(0.75),
                        ],
                      ).createShader(rect),
                      child: Text(
                        '${property.price.toStringAsFixed(0)} \$ ',
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_rounded,
                          size: 14,
                          color: _Palette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${property.viewsCount} مشاهدة',
                          style: const TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12.5,
                            color: _Palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(isForSale: property.isForSale),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          property.title,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _Palette.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: _Palette.primary),
            const SizedBox(width: 4),
            Text(
              property.cityName,
              style: const TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13,
                color: _Palette.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isForSale;
  const _StatusBadge({required this.isForSale});

  @override
  Widget build(BuildContext context) {
    final color = isForSale ? _Palette.primary : _Palette.royalBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        isForSale ? 'للبيع' : 'للإيجار',
        style: const TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// =======================================================================
/// SPECS ROW — modern icon cards for area / rooms / bathrooms / type
/// =======================================================================
class _SpecsRow extends StatelessWidget {
  final dynamic property;
  const _SpecsRow({required this.property});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.straighten_rounded, '${property.areaSqm} م²', 'المساحة'),
      (Icons.bed_rounded, '${property.roomsCount}', 'غرف نوم'),
      (Icons.bathtub_rounded, '${property.bathroomsCount}', 'حمامات'),
      (Icons.home_work_rounded, '${property.propertyTypeName}', 'النوع'),
    ];
    return Row(
      children: List.generate(items.length, (i) {
        final (icon, value, label) = items[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == items.length - 1 ? 0 : 8),
            child: _SpecCard(icon: icon, value: value, label: label),
          ),
        );
      }),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _SpecCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _Palette.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: _Palette.primary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _Palette.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 10.5,
              color: _Palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _Palette.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _Palette.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _Palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// =======================================================================
/// EXPANDABLE DESCRIPTION with animated "Read More / Read Less"
/// =======================================================================
class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13.5,
              height: 1.6,
              color: _Palette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'عرض أقل' : 'قراءة المزيد',
              style: const TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _Palette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================================
/// MINI MAP CARD — stylized map preview + address + "open in maps" chip
/// Swap the placeholder pattern for a real google_maps_flutter / static
/// maps image if you have an API key wired up.
/// =======================================================================
/// =======================================================================
/// MINI MAP CARD — real flutter_map preview + fullscreen expand + directions
/// =======================================================================
const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.example.akare'; // بدّله لـ applicationId الفعلي عندك

class _MiniMapCard extends StatelessWidget {
  final String addressText;
  final double? latitude;
  final double? longitude;
  const _MiniMapCard({
    required this.addressText,
    required this.latitude,
    required this.longitude,
  });

  bool get _hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasLocation) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 20,
              color: _Palette.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                addressText,
                style: const TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.5,
                  color: _Palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final point = ll.LatLng(latitude!, longitude!);

    return Container(
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openFullscreen(context, point),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  AbsorbPointer(
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
                        MarkerLayer(markers: [_pin(point)]),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fullscreen_rounded,
                        size: 16,
                        color: _Palette.primary,
                      ),
                    ),
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
                    addressText,
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 12.5,
                      color: _Palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openDirections(point),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _Palette.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_rounded,
                          size: 14,
                          color: _Palette.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'الاتجاهات',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _Palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _pin(ll.LatLng point) {
    return Marker(
      point: point,
      width: 48,
      height: 60,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _Palette.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          CustomPaint(
            size: const Size(10, 8),
            painter: _PinTailPainter(_Palette.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(ll.LatLng point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openFullscreen(BuildContext context, ll.LatLng point) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenMapScreen(point: point, addressText: addressText),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FullscreenMapScreen extends StatelessWidget {
  final ll.LatLng point;
  final String addressText;
  const _FullscreenMapScreen({required this.point, required this.addressText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _Palette.bg,
        foregroundColor: _Palette.textPrimary,
        elevation: 0,
        title: Text(
          addressText,
          style: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: point, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: _userAgent,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 52,
                    height: 64,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: _Palette.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(11, 9),
                          painter: _PinTailPainter(_Palette.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
                  );
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.directions_rounded),
                label: const Text(
                  'فتح الاتجاهات بتطبيق الخرائط',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================================
/// AGENT PROFILE CARD — avatar, rating, response time, verified badge
/// =======================================================================

class _AgentProfileCard extends StatelessWidget {
  final AgentEntity agent; // كان dynamic
  const _AgentProfileCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _Palette.primary,
                      _Palette.primary.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: agent.avatarUrl != null
                      ? Image.network(agent.avatarUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.person_rounded,
                            color: _Palette.textSecondary,
                          ),
                        ),
                ),
              ),
              if (agent.isVerifiedAgent)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: _Palette.royalBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.fullName, // كان agent.name
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agent.companyName ??
                      'وكيل عقاري', // بدل rating/responseTime غير الموجودين
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12,
                    color: _Palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _Palette.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: _Palette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================================
/// STICKY BOTTOM ACTION BAR — outlined Call + gradient Contact/WhatsApp
/// =======================================================================
class _StickyContactBar extends StatelessWidget {
  final dynamic agent;
  const _StickyContactBar({required this.agent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: launch phone dialer with agent.phoneNumber
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.primary,
                    side: BorderSide(
                      color: _Palette.primary.withOpacity(0.35),
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text(
                    'اتصال',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        _Palette.primary,
                        _Palette.primary.withOpacity(0.75),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // TODO: launch whatsapp / in-app chat with agent
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'تواصل مع الوكيل',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================================
/// SHIMMER + ERROR STATES
/// =======================================================================
class _PremiumShimmer extends StatelessWidget {
  const _PremiumShimmer();

  Widget _box({double? width, required double height, double radius = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(height: 320, radius: 26),
          const SizedBox(height: 20),
          _box(width: 160, height: 26),
          const SizedBox(height: 10),
          _box(height: 18),
          const SizedBox(height: 20),
          _box(height: 96, radius: 20),
          const SizedBox(height: 20),
          _box(height: 70, radius: 18),
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
                color: _Palette.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _Palette.danger,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _fontFamily,
                color: _Palette.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.primary,
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
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
