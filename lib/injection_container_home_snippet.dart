// Merge this into your existing `injection_container.dart` (the same file
// where AuthCubit / LoginUseCase / RegisterUseCase are already registered).
// Only the Dio instance (`sl<Dio>()`) is assumed to already exist there.

import 'package:get_it/get_it.dart';

import 'features/home/data/datasources/properties_remote_datasource.dart';
import 'features/home/data/repositories/properties_repository_impl.dart';
import 'features/home/domain/repositories/properties_repository.dart';
import 'features/home/domain/usecases/get_featured_properties_usecase.dart';
import 'features/home/domain/usecases/get_latest_properties_usecase.dart';
import 'features/home/domain/usecases/get_property_types_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

void registerHomeFeature(GetIt sl) {
  sl.registerFactory(
    () => HomeCubit(
      getPropertyTypes: sl(),
      getFeaturedProperties: sl(),
      getLatestProperties: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPropertyTypesUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => GetLatestPropertiesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PropertiesRepository>(
    () => PropertiesRepositoryImpl(sl()),
  );

  // Data source — reuses the same Dio client the auth feature registered.
  sl.registerLazySingleton<PropertiesRemoteDataSource>(
    () => PropertiesRemoteDataSourceImpl(sl()),
  );
}
