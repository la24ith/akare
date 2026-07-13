import "package:flutter/material.dart";

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static const Map<String, Color> _colors = {
    "pending": Color(0xFFE7A94C),
    "active": Color(0xFF0E6E5C),
    "rejected": Color(0xFFD64545),
    "sold": Color(0xFF6B7A76),
    "rented": Color(0xFF6B7A76),
  };

  static const Map<String, String> _labels = {
    "pending": "قيد المراجعة",
    "active": "نشط",
    "rejected": "مرفوض",
    "sold": "مباع",
    "rented": "مؤجر",
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    final label = _labels[status] ?? status;

    final width = MediaQuery.of(context).size.width;

    // نحسب معامل تحجيم بناءً على عرض الشاشة
    // 360 هو عرض مرجعي لموبايل عادي، ونحدد الحد الأدنى والأقصى حتى لا يصغر/يكبر بشكل مبالغ فيه
    final scale = (width / 360).clamp(0.85, 1.4);

    final fontSize = (12 * scale).clamp(11.0, 15.0);
    final horizontalPadding = (10 * scale).clamp(8.0, 16.0);
    final verticalPadding = (4 * scale).clamp(3.0, 7.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
