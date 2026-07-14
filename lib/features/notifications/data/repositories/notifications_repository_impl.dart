// lib/features/notifications/data/repositories/notifications_repository_impl.dart
import 'package:akare/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  NotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications() {
    return remoteDataSource
        .watchNotifications()
        .map<Either<Failure, List<NotificationEntity>>>((list) => Right(list));
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) => _guard(() async {
    await remoteDataSource.markAsRead(id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> markAllAsRead() => _guard(() async {
    await remoteDataSource.markAllAsRead();
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message.isNotEmpty ? e.message : 'حدث خطأ'));
    } catch (_) {
      return const Left(ServerFailure('تحقق من اتصالك بالإنترنت'));
    }
  }
}
