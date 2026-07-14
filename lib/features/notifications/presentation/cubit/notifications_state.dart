// lib/features/notifications/presentation/cubit/notifications_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsState extends Equatable {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, errorMessage];
}
