import 'package:flutter/material.dart';

import 'package:akare/core/constants/app_colors.dart';

const _reportReasons = [
  'إعلان مكرر',
  'معلومات غير صحيحة',
  'السعر مضلل',
  'العقار غير متاح',
  'محتوى غير لائق',
  'سبب آخر',
];

Future<void> showReportPropertySheet({
  required BuildContext context,
  required ValueChanged<String> onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _ReportSheet(onSubmit: onSubmit),
  );
}

class _ReportSheet extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _ReportSheet({required this.onSubmit});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الإبلاغ عن هذا العقار',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اختر السبب الأقرب لملاحظتك',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ..._reportReasons.map(
            (reason) => RadioListTile<String>(
              value: reason,
              groupValue: _selectedReason,
              onChanged: (v) => setState(() => _selectedReason = v),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text(reason, style: const TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _selectedReason == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      widget.onSubmit(_selectedReason!);
                    },
              child: const Text(
                'إرسال البلاغ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
