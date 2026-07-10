/// إعدادات الاتصال بـ Supabase.
///
/// !! هام: لا تترك المفاتيح الحقيقية هنا عند رفع الكود لأي مستودع عام.
/// الأفضل استخدام --dart-define عند البناء، مثال:
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
///
/// وفي هذا الملف نقرأها من String.fromEnvironment، مع قيمة افتراضية فارغة
/// تنبهك أثناء التطوير إذا نسيت تمريرها.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );
}
