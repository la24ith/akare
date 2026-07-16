// lib/features/agent_dashboard/presentation/widgets/agent_scaffold.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// الإطار الثابت لتطبيق الوكيل — يلف الفروع الثلاثة (Dashboard/Properties/Profile)
/// عبر StatefulShellRoute، مع زر عائم بالمنتصف لإضافة عقار جديد (خارج الفروع
/// نفسها، فبيفتح بملء الشاشة بدون الشريط السفلي تحته).
class AgentScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AgentScaffold({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // لو ضغط نفس التبويب الحالي، يرجّعه لأول شاشة بالفرع (مو يكرر التنقل)
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 10,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.space_dashboard_rounded,
                label: 'الرئيسية',
                isActive: navigationShell.currentIndex == 0,
                onTap: () => _goBranch(0),
              ),
              _NavItem(
                icon: Icons.apartment_rounded,
                label: 'عقاراتي',
                isActive: navigationShell.currentIndex == 1,
                onTap: () => _goBranch(1),
              ),
              const SizedBox(width: 56), // مساحة فارغة تحت الزر العائم
              _NavItem(
                icon: Icons.person_rounded,
                label: 'حسابي',
                isActive: navigationShell.currentIndex == 2,
                onTap: () => _goBranch(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
