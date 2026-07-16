import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.example.akare'; // بدّله لـ applicationId الفعلي عندك

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

  bool get hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    if (!hasLocation) return _NoLocationCard(addressText: addressText);

    final point = ll.LatLng(latitude!, longitude!);

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // خريطة معاينة — تفاعل معطّل، الضغط بيفتح النسخة الكاملة
          GestureDetector(
            onTap: () => _openFullscreen(context, point),
            child: AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15.2,
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
                        width: 48,
                        height: 60,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
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
                              painter: _TrianglePainter(AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // تعتيم متدرّج أسفل الخريطة عشان النص والأزرار تبين بوضوح
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          // زر تكبير أعلى اليمين
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _openFullscreen(context, point),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fullscreen_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // العنوان + زر الاتجاهات أسفل البطاقة
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    addressText ?? 'اضغط لعرض الموقع بالتفصيل',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _DirectionsButton(point: point),
              ],
            ),
          ),
        ],
      ),
    );
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

class _DirectionsButton extends StatelessWidget {
  final ll.LatLng point;
  const _DirectionsButton({required this.point});

  Future<void> _open() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_rounded, size: 15, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'الاتجاهات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دبوس مخصّص (دائرة + ذيل مثلث) بدل الأيقونة الافتراضية الجاهزة.
class _MapPin extends StatelessWidget {
  final ll.LatLng point;
  final double size;
  const _MapPin({required this.point, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Marker(
          point: point,
          width: size + 4,
          height: size + 14,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
                painter: _TrianglePainter(AppColors.primary),
              ),
            ],
          ),
        )
        as Widget; // Marker.child يُستهلك مباشرة من MarkerLayer، الإرجاع هون شكلي فقط
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

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
  final String? addressText;
  const _FullscreenMapScreen({required this.point, this.addressText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          addressText ?? 'الموقع',
          style: const TextStyle(fontSize: 15),
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
                    width: 48,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(10, 8),
                          painter: _TrianglePainter(AppColors.primary),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.directions_rounded),
                label: const Text('فتح الاتجاهات بتطبيق الخرائط'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoLocationCard extends StatelessWidget {
  final String? addressText;
  const _NoLocationCard({this.addressText});

  @override
  Widget build(BuildContext context) {
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
              Icons.location_off_outlined,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              addressText ?? 'الموقع غير متوفر',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
