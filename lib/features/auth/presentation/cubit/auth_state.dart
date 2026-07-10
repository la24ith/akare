import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// كل الحالات الممكنة لـ AuthCubit — نمط موحّد يتكرر في كل Cubit بالمشروع:
/// Initial / Loading / Success (بنوعين مختلفين هنا) / Error
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// نجاح تسجيل الدخول أو التسجيل
class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

/// نجاح إرسال رابط استعادة كلمة المرور (حالة منفصلة لتفادي الخلط مع AuthSuccess)
class ForgotPasswordEmailSent extends AuthState {
  const ForgotPasswordEmailSent();
}

/// تم تسجيل الخروج بنجاح
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
