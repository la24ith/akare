// Merge into your existing `injection_container.dart`, alongside the Home
// feature registration (`registerHomeFeature`). Reuses the same
// `sl<SupabaseClient>()` singleton.

import 'package:get_it/get_it.dart';

import 'features/property_details/data/datasources/property_details_remote_datasource.dart';
import 'features/property_details/data/repositories/property_details_repository_impl.dart';
import 'features/property_details/domain/repositories/property_details_repository.dart';
import 'features/property_details/domain/usecases/get_property_details_usecase.dart';
import 'features/property_details/domain/usecases/report_property_usecase.dart';
import 'features/property_details/domain/usecases/toggle_favorite_usecase.dart';
import 'features/property_details/presentation/cubit/property_details_cubit.dart';

void registerPropertyDetailsFeature(GetIt sl) {
  sl.registerFactory(() => PropertyDetailsCubit(
        getPropertyDetails: sl(),
        toggleFavoriteUseCase: sl(),
        reportPropertyUseCase: sl(),
      ));

  sl.registerLazySingleton(() => GetPropertyDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ReportPropertyUseCase(sl()));

  sl.registerLazySingleton<PropertyDetailsRepository>(() => PropertyDetailsRepositoryImpl(sl()));

  sl.registerLazySingleton<PropertyDetailsRemoteDataSource>(
    () => PropertyDetailsRemoteDataSourceImpl(sl()),
  );
}

// GoRouter route example:
// GoRoute(
//   path: '/property/:id',
//   builder: (context, state) => BlocProvider(
//     create: (_) => sl<PropertyDetailsCubit>(),
//     child: PropertyDetailsScreen(propertyId: state.pathParameters['id']!),
//   ),
// ),
