// Merge into your existing `injection_container.dart`, alongside
// `registerHomeFeature`. Reuses `sl<SupabaseClient>()` and the Home
// feature's `GetPropertyTypesUseCase` (property types are shared between
// the Home categories row and the Search filter sheet).

import 'package:get_it/get_it.dart';

import 'features/home/domain/usecases/get_property_types_usecase.dart';
import 'features/search/data/datasources/search_remote_datasource.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/domain/usecases/get_cities_usecase.dart';
import 'features/search/domain/usecases/search_properties_usecase.dart';
import 'features/search/presentation/cubit/search_cubit.dart';

void registerSearchFeature(GetIt sl) {
  sl.registerFactory(() => SearchCubit(
        getCities: sl(),
        getPropertyTypes: sl<GetPropertyTypesUseCase>(), // shared with Home
        searchProperties: sl(),
      ));

  sl.registerLazySingleton(() => GetCitiesUseCase(sl()));
  sl.registerLazySingleton(() => SearchPropertiesUseCase(sl()));

  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));

  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl()),
  );
}

// GoRouter route example:
// GoRoute(
//   path: '/search',
//   builder: (context, state) => BlocProvider(
//     create: (_) => sl<SearchCubit>(),
//     child: const SearchScreen(),
//   ),
// ),
