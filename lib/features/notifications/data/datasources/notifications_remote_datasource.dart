// lib/features/notifications/data/datasources/notifications_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Stream<List<NotificationModel>> watchNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final SupabaseClient supabase;
  NotificationsRemoteDataSourceImpl(this.supabase);

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);

    // .stream() بترجع القائمة الكاملة المفلترة في كل مرة يصير فيها تغيير
    // (إدراج/تعديل) — مش diff تدريجي، وهذا أبسط للتعامل معه بالواجهة.
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows.map((r) => NotificationModel.fromSupabase(r)).toList(),
        );
  }

  @override
  Future<void> markAsRead(String id) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', id);
  }

  @override
  Future<void> markAllAsRead() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }
}
