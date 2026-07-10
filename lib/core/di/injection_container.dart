import 'package:get_it/get_it.dart';

import '../network/supabase_client.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance; // Service Locator

/// يُستدعى مرة واحدة في main() قبل تشغيل التطبيق.
/// أي feature جديدة تُضاف: أضف تسجيل الـ datasource/repository/usecase/cubit هنا فقط.
Future<void> init() async {
  // ---------------- Auth ----------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: supabase),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // ملاحظة: Cubit يُسجَّل بـ registerFactory (وليس LazySingleton) لأنه
  // مرتبط بدورة حياة الشاشة (Widget lifecycle) - كل مرة تُفتح الشاشة
  // نريد نسخة جديدة نظيفة من الحالة.
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // TODO: عند إضافة feature جديدة (properties, favorites...) سجّلها هنا بنفس النمط
}
