// lib/features/property_form/presentation/widgets/location_picker_screen.dart
import 'package:akare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // مركز افتراضي: عمّان — عدّله حسب سوقك الأساسي لو مختلف
  late LatLng _picked = LatLng(
    widget.initialLat ?? 31.9454,
    widget.initialLng ?? 35.9284,
  );
  final _mapController = MapController();

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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.akare', // بدّل لـ applicationId الفعلي عندك
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'اضغط على أي مكان بالخريطة لتحديد الموقع',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
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
