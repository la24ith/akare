/// Exceptions تُرمى من الـ datasources (data layer) فقط.
/// يتم تحويلها إلى Failure داخل الـ Repository قبل الوصول للـ domain.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class AuthException2 implements Exception {
  final String message;
  AuthException2([this.message = 'Authentication error']);
}

class UnknownException implements Exception {
  final String message;
  UnknownException([this.message = 'Unknown error']);
}
