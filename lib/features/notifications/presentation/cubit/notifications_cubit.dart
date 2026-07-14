// lib/features/notifications/presentation/cubit/notifications_cubit.dart
import 'dart:async';
import 'package:akare/core/usecace/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import 'notifications_state.dart';

/// ⚠️ يُسجَّل بـ GetIt كـ registerLazySingleton وليس registerFactory —
/// خلافًا لباقي الـ Cubits بالمشروع. السبب: هاد الـ Cubit لازم يبقى حي
/// ويستمع بالخلفية طول ما الوكيل بالتطبيق (لعرض عدد الإشعارات غير المقروءة
/// بأيقونة الجرس بأي شاشة)، مش مرتبط بدورة حياة شاشة وحدة بس.
class NotificationsCubit extends Cubit<NotificationsState> {
  final WatchNotificationsUseCase watchNotifications;
  final MarkNotificationAsReadUseCase markAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllAsReadUseCase;
  StreamSubscription? _subscription;

  NotificationsCubit({
    required this.watchNotifications,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
  }) : super(const NotificationsState());
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const NotificationsState());
  }

  /// آمن للاستدعاء أكتر من مرة (من أكتر من شاشة) — ما بيكرر الاشتراك.
  void start() {
    if (_subscription != null) return;
    _subscription = watchNotifications().listen(
      (result) => result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.message),
        ),
        (list) => emit(
          state.copyWith(
            notifications: list,
            isLoading: false,
            errorMessage: null,
          ),
        ),
      ),
      onError: (_) => emit(
        state.copyWith(isLoading: false, errorMessage: 'تعذّر تحميل الإشعارات'),
      ),
    );
  }

  Future<void> markAsRead(String id) => markAsReadUseCase(id);
  Future<void> markAllAsRead() => markAllAsReadUseCase(const NoParams());

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
