// lib/features/notifications/domain/usecases/watch_notifications_usecase.dart
import 'package:akare/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class WatchNotificationsUseCase {
  final NotificationsRepository repository;
  WatchNotificationsUseCase(this.repository);

  Stream<Either<Failure, List<NotificationEntity>>> call() =>
      repository.watchNotifications();
}
