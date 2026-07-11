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
// Home feature
import '../../features/home/data/datasources/properties_remote_datasource.dart';
import '../../features/home/data/repositories/properties_repository_impl.dart';
import '../../features/home/domain/repositories/properties_repository.dart';
import '../../features/home/domain/usecases/get_property_types_usecase.dart';
import '../../features/home/domain/usecases/get_featured_properties_usecase.dart';
import '../../features/home/domain/usecases/get_latest_properties_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

// Property Details feature
import '../../features/property_details/data/datasources/property_details_remote_datasource.dart';
import '../../features/property_details/data/repositories/property_details_repository_impl.dart';
import '../../features/property_details/domain/repositories/property_details_repository.dart';
import '../../features/property_details/domain/usecases/get_property_details_usecase.dart';
import '../../features/property_details/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/property_details/domain/usecases/report_property_usecase.dart';
import '../../features/property_details/presentation/cubit/property_details_cubit.dart';

// Search feature
import '../../features/search/data/datasources/search_remote_datasource.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/get_cities_usecase.dart';
import '../../features/search/domain/usecases/search_properties_usecase.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';

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

  // ---------------- Home ----------------
  sl.registerLazySingleton<PropertiesRemoteDataSource>(
    () => PropertiesRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<PropertiesRepository>(
    () => PropertiesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPropertyTypesUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => GetLatestPropertiesUseCase(sl()));
  sl.registerFactory(
    () => HomeCubit(
      getPropertyTypes: sl(),
      getFeaturedProperties: sl(),
      getLatestProperties: sl(),
    ),
  );

  // ---------------- Property Details ----------------
  sl.registerLazySingleton<PropertyDetailsRemoteDataSource>(
    () => PropertyDetailsRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<PropertyDetailsRepository>(
    () => PropertyDetailsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPropertyDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ReportPropertyUseCase(sl()));
  sl.registerFactory(
    () => PropertyDetailsCubit(
      getPropertyDetails: sl(),
      toggleFavoriteUseCase: sl(),
      reportPropertyUseCase: sl(),
    ),
  );

  // ---------------- Search ----------------
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCitiesUseCase(sl()));
  sl.registerLazySingleton(() => SearchPropertiesUseCase(sl()));
  sl.registerFactory(
    () => SearchCubit(
      getCities: sl(),
      getPropertyTypes: sl<GetPropertyTypesUseCase>(), // مشترك مع Home
      searchProperties: sl(),
    ),
  );
}
