// lib/features/property_details/presentation/widgets/property_qr_sheet.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// ⚠️ بيستخدم رابط placeholder مؤقت لحد ما نبني ميزة Deep Linking.
/// بمجرد ما نضبط App Links/Universal Links، بدّل _buildLink بالرابط
/// الحقيقي (مثلاً https://akare.app/property/$propertyId) وبس — كل شي
/// تاني بهاد الملف بيضل بدون تغيير.
String _buildPropertyLink(String propertyId) {
  return 'https://akare.app/property/$propertyId'; // TODO: رابط حقيقي بعد Deep Linking
}

Future<void> showPropertyQrSheet({
  required BuildContext context,
  required String propertyId,
  required String propertyTitle,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) =>
        _PropertyQrSheet(propertyId: propertyId, propertyTitle: propertyTitle),
  );
}

class _PropertyQrSheet extends StatelessWidget {
  final String propertyId;
  final String propertyTitle;
  const _PropertyQrSheet({
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  Widget build(BuildContext context) {
    final link = _buildPropertyLink(propertyId);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            propertyTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'امسح الرمز لمشاركة العقار مباشرة',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: QrImageView(
              data: link,
              version: QrVersions.auto,
              size: 200,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('تم نسخ الرابط')));
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('نسخ الرابط'),
            ),
          ),
        ],
      ),
    );
  }
}
