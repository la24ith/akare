import 'package:akare/features/agent_dashboard/data/datasources/agent_dashboard_remote_datasource.dart';
import 'package:akare/features/agent_dashboard/data/repositories/agent_dashboard_repository_impl.dart';
import 'package:akare/features/agent_dashboard/domain/repositories/agent_dashboard_repository.dart';
import 'package:akare/features/agent_dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:akare/features/agent_dashboard/presentation/cubit/agent_dashboard_cubit.dart';
import 'package:akare/features/agent_profile/data/datasources/agent_profile_remote_datasource.dart';
import 'package:akare/features/agent_profile/data/repositories/agent_profile_repository_impl.dart';
import 'package:akare/features/agent_profile/domain/repositories/agent_profile_repository.dart';
import 'package:akare/features/agent_profile/domain/usecases/get_agent_profile_usecase.dart';
import 'package:akare/features/agent_profile/domain/usecases/sign_out_usecase.dart';
import 'package:akare/features/agent_profile/domain/usecases/update_agent_profile_usecase.dart';
import 'package:akare/features/agent_profile/presentation/cubit/agent_profile_cubit.dart';
import 'package:akare/features/auth/domain/usecases/user_session.dart';
import 'package:akare/features/comparison/presentation/cubit/compare_selection_cubit.dart';
import 'package:akare/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:akare/features/home/domain/usecases/get_favorites_usecase.dart';
import 'package:akare/features/my_properties/data/datasources/my_properties_remote_datasource.dart';
import 'package:akare/features/my_properties/data/repositories/my_properties_repository_impl.dart';
import 'package:akare/features/my_properties/domain/repositories/my_properties_repository.dart';
import 'package:akare/features/my_properties/domain/usecases/delete_property_usecase.dart';
import 'package:akare/features/my_properties/domain/usecases/get_my_properties_usecase.dart';
import 'package:akare/features/my_properties/domain/usecases/get_my_property_detail_usecase.dart';
import 'package:akare/features/my_properties/domain/usecases/update_property_status_usecase.dart';
import 'package:akare/features/my_properties/presentation/cubit/agent_property_detail_cubit.dart';
import 'package:akare/features/my_properties/presentation/cubit/my_properties_cubit.dart';
import 'package:akare/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:akare/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:akare/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:akare/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:akare/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:akare/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:akare/features/price_history/data/datasources/price_history_remote_datasource.dart';
import 'package:akare/features/price_history/data/repositories/price_history_repository_impl.dart';
import 'package:akare/features/price_history/domain/repositories/price_history_repository.dart';
import 'package:akare/features/price_history/domain/usecases/get_price_history_usecase.dart';
import 'package:akare/features/price_history/presentation/cubit/price_history_cubit.dart';
import 'package:akare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:akare/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:akare/features/profile/domain/repositories/profile_repository.dart';
import 'package:akare/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:akare/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:akare/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:akare/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:akare/features/property_form/data/datasources/property_form_remote_datasource.dart';
import 'package:akare/features/property_form/data/repositories/property_form_repository_impl.dart';
import 'package:akare/features/property_form/domain/repositories/property_form_repository.dart';
import 'package:akare/features/property_form/domain/usecases/delete_property_image_usecase.dart';
import 'package:akare/features/property_form/domain/usecases/get_form_lookups_usecase.dart';
import 'package:akare/features/property_form/domain/usecases/get_property_for_edit_usecase.dart';
import 'package:akare/features/property_form/domain/usecases/submit_property_usecase.dart';
import 'package:akare/features/property_form/domain/usecases/upload_property_image_usecase.dart';
import 'package:akare/features/property_form/presentation/cubit/property_form_cubit.dart';
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
  registerAgentFeatureDependencies();
}

void registerAgentFeatureDependencies() {
  // ---------------- Agent Dashboard ----------------
  sl.registerFactory(() => AgentDashboardCubit(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton<AgentDashboardRepository>(
    () => AgentDashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AgentDashboardRemoteDataSource>(
    () => AgentDashboardRemoteDataSourceImpl(supabase), // كان sl()
  );
  /////////////////////////////////////
  sl.registerLazySingleton(() => CompareSelectionCubit());

  //----------------price history----------------
  sl.registerLazySingleton<PriceHistoryRemoteDataSource>(
    () => PriceHistoryRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<PriceHistoryRepository>(
    () => PriceHistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPriceHistoryUseCase(sl()));
  sl.registerFactory(() => PriceHistoryCubit(getPriceHistory: sl()));
  // ---------------- My Properties ----------------
  sl.registerFactory(
    () => MyPropertiesCubit(
      getMyPropertiesUseCase: sl(),
      deletePropertyUseCase: sl(),
      updatePropertyStatusUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetMyPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => DeletePropertyUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePropertyStatusUseCase(sl()));
  sl.registerLazySingleton<MyPropertiesRepository>(
    () => MyPropertiesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MyPropertiesRemoteDataSource>(
    () => MyPropertiesRemoteDataSourceImpl(supabase), // كان sl()
  );
  sl.registerLazySingleton(() => GetMyPropertyDetailUseCase(sl()));
  sl.registerFactory(
    () => AgentPropertyDetailCubit(
      getPropertyDetail: sl(),
      deletePropertyUseCase: sl(),
      updatePropertyStatusUseCase: sl(),
    ),
  );
  // ---------------- Property Form ----------------
  sl.registerFactory(
    () => PropertyFormCubit(
      getFormLookupsUseCase: sl(),
      getPropertyForEditUseCase: sl(),
      submitPropertyUseCase: sl(),
      uploadPropertyImageUseCase: sl(),
      deletePropertyImageUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetFormLookupsUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyForEditUseCase(sl()));
  sl.registerLazySingleton(() => SubmitPropertyUseCase(sl()));
  sl.registerLazySingleton(() => UploadPropertyImageUseCase(sl()));
  sl.registerLazySingleton(() => DeletePropertyImageUseCase(sl()));
  sl.registerLazySingleton<PropertyFormRepository>(
    () => PropertyFormRepositoryImpl(
      sl(),
      supabase,
    ), // الباراميتر الثاني: كان sl()، صار supabase
  );
  sl.registerLazySingleton<PropertyFormRemoteDataSource>(
    () => PropertyFormRemoteDataSourceImpl(supabase), // كان sl()
  );

  // ---------------- Agent Profile ----------------
  sl.registerFactory(
    () => AgentProfileCubit(
      getAgentProfileUseCase: sl(),
      updateAgentProfileUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetAgentProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAgentProfileUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<AgentProfileRepository>(
    () => AgentProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AgentProfileRemoteDataSource>(
    () => AgentProfileRemoteDataSourceImpl(supabase), // كان sl()
  );
  // ---------------- Notifications ----------------
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => WatchNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(
    // ⚠️ lazySingleton مش factory — راجع الملاحظة بالكود فوق
    () => NotificationsCubit(
      watchNotifications: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
    ),
  );
  //profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabase),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerFactory(
    () => ProfileCubit(
      getProfile: sl(),
      updateProfileUseCase: sl(),
      uploadAvatarUseCase: sl(),
      logoutUseCase: sl(), // نفس LogoutUseCase من ميزة auth، مسجّل أصلًا
    ),
  );
  //--------------favorites----------------
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerFactory(() => FavoritesCubit(getFavorites: sl()));
}
