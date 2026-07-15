/// Failure = تمثيل الخطأ داخل طبقة الـ domain (بدون تفاصيل تقنية عن Supabase)
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم، حاول لاحقًا']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تحقق من اتصالك بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'بيانات الدخول غير صحيحة']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}
