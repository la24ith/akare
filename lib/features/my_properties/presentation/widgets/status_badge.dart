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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labels[status] ?? status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
