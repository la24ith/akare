import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../../domain/entities/my_property_entity.dart";
import "../../domain/usecases/delete_property_usecase.dart";
import "../../domain/usecases/get_my_properties_usecase.dart";
import "../../domain/usecases/update_property_status_usecase.dart";

part "my_properties_state.dart";

class MyPropertiesCubit extends Cubit<MyPropertiesState> {
  final GetMyPropertiesUseCase getMyPropertiesUseCase;
  final DeletePropertyUseCase deletePropertyUseCase;
  final UpdatePropertyStatusUseCase updatePropertyStatusUseCase;

  static const _pageSize = 10;

  MyPropertiesCubit({
    required this.getMyPropertiesUseCase,
    required this.deletePropertyUseCase,
    required this.updatePropertyStatusUseCase,
  }) : super(const MyPropertiesState());

  Future<void> loadFirstPage({PropertyStatusFilter? filter}) async {
    emit(state.copyWith(
      status: MyPropertiesStatus.loading,
      filter: filter ?? state.filter,
      page: 0,
      hasReachedMax: false,
      properties: [],
    ));
    final result = await getMyPropertiesUseCase(
      GetMyPropertiesParams(filter: state.filter, page: 0),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: MyPropertiesStatus.error,
        errorMessage: failure.message,
      )),
      (properties) => emit(state.copyWith(
        status: MyPropertiesStatus.loaded,
        properties: properties,
        hasReachedMax: properties.length < _pageSize,
      )),
    );
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == MyPropertiesStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: MyPropertiesStatus.loadingMore));
    final nextPage = state.page + 1;
    final result = await getMyPropertiesUseCase(
      GetMyPropertiesParams(filter: state.filter, page: nextPage),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: MyPropertiesStatus.loaded,
        errorMessage: failure.message,
      )),
      (properties) => emit(state.copyWith(
        status: MyPropertiesStatus.loaded,
        properties: [...state.properties, ...properties],
        page: nextPage,
        hasReachedMax: properties.length < _pageSize,
      )),
    );
  }

  void changeFilter(PropertyStatusFilter filter) {
    if (filter == state.filter) return;
    loadFirstPage(filter: filter);
  }

  Future<void> deleteProperty(String propertyId) async {
    final result = await deletePropertyUseCase(propertyId);
    result.fold(
      (failure) => emit(state.copyWith(actionMessage: failure.message)),
      (_) {
        final updated =
            state.properties.where((p) => p.id != propertyId).toList();
        emit(state.copyWith(
          properties: updated,
          actionMessage: "تم حذف العقار بنجاح",
        ));
      },
    );
  }

  Future<void> updateStatus(String propertyId, String newStatus) async {
    final result = await updatePropertyStatusUseCase(
      UpdatePropertyStatusParams(propertyId: propertyId, newStatus: newStatus),
    );
    result.fold(
      (failure) => emit(state.copyWith(actionMessage: failure.message)),
      (_) => loadFirstPage(),
    );
  }
}
