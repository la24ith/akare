// lib/features/notifications/presentation/widgets/notification_bell.dart
import 'package:akare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/notifications_cubit.dart';

/// ضيفه بأي AppBar بتطبيق الوكيل (Dashboard مثلًا). بيشتغل مباشرة لأنه
/// النسخة نفسها من NotificationsCubit (singleton) متشاركة بكل مكان.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<NotificationsCubit>()..start(),
      child: Builder(
        builder: (context) {
          final unread = context.select(
            (NotificationsCubit c) => c.state.unreadCount,
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/agent/notifications'),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
