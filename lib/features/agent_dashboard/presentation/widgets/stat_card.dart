import "package:flutter/material.dart";

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحجيم بسيط بناءً على عرض الخلية المتاح (لأغراض التناسق البصري
        // بين الشاشات فقط)، والـ FittedBox تحت هو من يضمن عدم حصول overflow
        // بشكل نهائي، بغض النظر عن ارتفاع الخلية اللي يعطيها الـ GridView.
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 160.0;
        final scale = (availableWidth / 160).clamp(0.75, 1.3);

        final cardPadding = 16 * scale;
        final iconBoxPadding = 10 * scale;
        final iconSize = 22 * scale;
        final valueFontSize = 22 * scale;
        final titleFontSize = 13 * scale;
        final spacingLarge = 12 * scale;
        final spacingSmall = 4 * scale;
        final borderRadius = 18 * scale;
        final iconBorderRadius = 12 * scale;

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // شبكة الأمان: لو المحتوى (حتى بعد الـ scale) أكبر من المساحة
          // المتاحة فعلياً، الـ FittedBox يصغّر كل شي (أيقونة + نصوص +
          // مسافات) ككتلة واحدة بنفس النسب، بدل ما يعمل overflow.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.topStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(iconBoxPadding),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(iconBorderRadius),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),
                SizedBox(height: spacingLarge),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: spacingSmall),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
