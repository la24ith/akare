// Merge this into your existing `injection_container.dart` (the same file
// where AuthCubit / LoginUseCase / RegisterUseCase are already registered).
// Assumes `Supabase.instance.client` is already initialized in main().

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/data/datasources/properties_remote_datasource.dart';
import 'features/home/data/repositories/properties_repository_impl.dart';
import 'features/home/domain/repositories/properties_repository.dart';
import 'features/home/domain/usecases/get_featured_properties_usecase.dart';
import 'features/home/domain/usecases/get_latest_properties_usecase.dart';
import 'features/home/domain/usecases/get_property_types_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

void registerHomeFeature(GetIt sl) {
  // Register once, near the top of your setup — reused by every feature.
  // Skip this line if you already registered SupabaseClient elsewhere.
  if (!sl.isRegistered<SupabaseClient>()) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }

  // Cubit — factory, because it's tied to the HomeScreen's widget lifecycle.
  sl.registerFactory(() => HomeCubit(
        getPropertyTypes: sl(),
        getFeaturedProperties: sl(),
        getLatestProperties: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetPropertyTypesUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => GetLatestPropertiesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PropertiesRepository>(() => PropertiesRepositoryImpl(sl()));

  // Data source
  sl.registerLazySingleton<PropertiesRemoteDataSource>(
    () => PropertiesRemoteDataSourceImpl(sl()),
  );
}
