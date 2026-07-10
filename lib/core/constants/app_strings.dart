/// نصوص عامة تتكرر في أكثر من شاشة — لتفادي تكرار الكتابة وتسهيل الترجمة لاحقًا
class AppStrings {
  AppStrings._();

  static const String appName = 'منصة عقارية';

  // أخطاء عامة
  static const String genericError = 'حدث خطأ غير متوقع، حاول لاحقًا';
  static const String networkError = 'تحقق من اتصالك بالإنترنت';

  // مصادقة
  static const String invalidEmail = 'صيغة البريد الإلكتروني غير صحيحة';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String passwordTooShort = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const String invalidPhone = 'رقم هاتف غير صحيح';
}
