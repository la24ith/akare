// lib/features/notifications/domain/repositories/notifications_repository.dart
import 'package:akare/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications();
  Future<Either<Failure, Unit>> markAsRead(String id);
  Future<Either<Failure, Unit>> markAllAsRead();
}
