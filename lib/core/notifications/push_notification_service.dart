// lib/core/notifications/push_notification_service.dart
import 'package:akare/core/network/supabase_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../network/supabase_config.dart';
import 'local_notification_service.dart';

/// يُستدعى top-level (خارج أي كلاس) — إلزامي لـ Firebase عشان يقدر
/// يشغّله بعملية (isolate) منفصلة وقت التطبيق مغلق تمامًا.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // النظام بيعرض الإشعار تلقائيًا من نفس الـ payload وقت التطبيق مغلق،
  // ما في داعي تستدعي LocalNotificationService هون.
}

class PushNotificationService {
  static Future<void> init() async {
    await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // التطبيق مفتوح وبالمقدمة: نعرضها يدويًا عبر flutter_local_notifications
    // (FCM ما بيعرض إشعار نظام تلقائي وقت foreground)
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.show(
          title: notification.title ?? '',
          body: notification.body ?? '',
        );
      }
    });

    await _saveTokenIfLoggedIn();
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveTokenIfLoggedIn() async {
    if (supabase.auth.currentUser == null) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(token);
  }

  /// نادِ عليها بعد نجاح تسجيل الدخول مباشرة (جوا AuthCubit بعد Login).
  static Future<void> onUserLoggedIn() => _saveTokenIfLoggedIn();

  static Future<void> _saveToken(String token) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase.from('device_tokens').upsert({
      'user_id': uid,
      'fcm_token': token,
      'platform': 'android',
    }, onConflict: 'fcm_token');
  }

  /// نادِ عليها عند تسجيل الخروج — تمنع إرسال إشعارات لمستخدم بعد ما طلع.
  static Future<void> onUserLoggedOut() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await supabase.from('device_tokens').delete().eq('fcm_token', token);
    }
  }
}
