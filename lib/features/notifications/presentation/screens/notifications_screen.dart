// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:akare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<NotificationsCubit>()..start(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
            child: const Text(
              'تحديد الكل كمقروء',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'لا توجد إشعارات حاليًا',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final n = state.notifications[index];
              return NotificationTile(
                notification: n,
                onTap: () {
                  if (!n.isRead)
                    context.read<NotificationsCubit>().markAsRead(n.id);
                  if (n.relatedPropertyId != null) {
                    context.push('/agent/properties/${n.relatedPropertyId}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
