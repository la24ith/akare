import "package:akare/core/theme/app_colors.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// الحاوية (Shell) لتطبيق الوكيل — تعرض التنقل السفلي وتحتفظ بحالة كل تبويب
class AgentShellScreen extends StatelessWidget {
  final Widget child;
  const AgentShellScreen({super.key, required this.child});

  static const _tabs = [
    ("/agent/dashboard", Icons.dashboard_outlined, Icons.dashboard, "الرئيسية"),
    ("/agent/properties", Icons.home_work_outlined, Icons.home_work, "عقاراتي"),
    (
      "/agent/properties/add",
      Icons.add_circle_outline,
      Icons.add_circle,
      "إضافة",
    ),
    ("/agent/profile", Icons.person_outline, Icons.person, "حسابي"),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => context.go(_tabs[index].$1),
        items: _tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.$2),
                activeIcon: Icon(t.$3),
                label: t.$4,
              ),
            )
            .toList(),
      ),
    );
  }
}
