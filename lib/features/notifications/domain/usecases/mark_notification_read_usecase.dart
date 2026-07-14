// lib/features/notifications/domain/usecases/mark_notification_read_usecase.dart
import 'package:akare/core/errors/failures.dart';
import 'package:akare/core/usecace/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/notifications_repository.dart';

class MarkNotificationAsReadUseCase implements UseCase<Unit, String> {
  final NotificationsRepository repository;
  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) => repository.markAsRead(id);
}

class MarkAllNotificationsAsReadUseCase implements UseCase<Unit, NoParams> {
  final NotificationsRepository repository;
  MarkAllNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      repository.markAllAsRead();
}
