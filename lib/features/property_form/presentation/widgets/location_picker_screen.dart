import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.example.akare'; // بدّله لـ applicationId الفعلي عندك

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // مركز افتراضي احتياطي (عمّان) لو فشل تحديد الموقع ولا في إحداثيات سابقة
  static final _fallbackCenter = ll.LatLng(31.9454, 35.9284);

  late ll.LatLng _picked;
  final _mapController = MapController();
  bool _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      // وضع التعديل: في موقع محفوظ سابقًا — استخدمه مباشرة، ما في داعي لطلب موقع الجهاز
      _picked = ll.LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      // إضافة عقار جديد: ابدأ بموقع افتراضي، وحاول تجيب موقع المستخدم الفعلي فورًا
      _picked = _fallbackCenter;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _goToCurrentLocation(moveCamera: true),
      );
    }
  }

  Future<void> _goToCurrentLocation({bool moveCamera = false}) async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'خدمة الموقع غير مفعّلة على الجهاز';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض إذن الموقع';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'إذن الموقع مرفوض بشكل دائم — فعّله من إعدادات التطبيق';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = ll.LatLng(position.latitude, position.longitude);

      setState(() {
        _picked = point;
        _isLocating = false;
      });
      if (moveCamera) _mapController.move(point, 15);
    } catch (e) {
      setState(() {
        _isLocating = false;
        _locationError = e is String ? e : 'تعذّر تحديد موقعك الحالي';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _picked,
              initialZoom: 13,
              onTap: (tapPosition, latLng) => setState(() => _picked = latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: _userAgent,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked,
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
                                offset: const Offset(0, 3),
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
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _locationError ??
                      'اضغط على الخريطة أو حرّكها لتحديد موقع العقار بدقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: _locationError != null ? AppColors.error : null,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 90,
            child: FloatingActionButton.small(
              heroTag: 'locate_me',
              backgroundColor: Colors.white,
              onPressed: _isLocating
                  ? null
                  : () => _goToCurrentLocation(moveCamera: true),
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.primary,
                    ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_picked),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('تأكيد الموقع'),
            ),
          ),
        ],
      ),
    );
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
