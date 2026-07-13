// lib/features/my_properties/presentation/cubit/agent_property_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_property_usecase.dart';
import '../../domain/usecases/get_my_property_detail_usecase.dart';
import '../../domain/usecases/update_property_status_usecase.dart';
import 'agent_property_detail_state.dart';

class AgentPropertyDetailCubit extends Cubit<AgentPropertyDetailState> {
  final GetMyPropertyDetailUseCase getPropertyDetail;
  final DeletePropertyUseCase deletePropertyUseCase;
  final UpdatePropertyStatusUseCase updatePropertyStatusUseCase;

  AgentPropertyDetailCubit({
    required this.getPropertyDetail,
    required this.deletePropertyUseCase,
    required this.updatePropertyStatusUseCase,
  }) : super(const AgentPropertyDetailState());

  Future<void> load(String propertyId) async {
    emit(state.copyWith(status: AgentPropertyDetailStatus.loading));
    final result = await getPropertyDetail(propertyId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AgentPropertyDetailStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (property) => emit(
        state.copyWith(
          status: AgentPropertyDetailStatus.loaded,
          property: property,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final property = state.property;
    if (property == null) return;
    emit(state.copyWith(isActionInProgress: true));
    // ⚠️ عدّل الاستدعاء التالي حسب توقيع DeletePropertyUseCase الفعلي عندك (params أو String مباشرة)
    final result = await deletePropertyUseCase(property.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(isActionInProgress: false, wasDeleted: true)),
    );
  }

  Future<void> updateStatus(String newStatus) async {
    final property = state.property;
    if (property == null) return;
    emit(state.copyWith(isActionInProgress: true));
    // ⚠️ عدّل حسب توقيع UpdatePropertyStatusUseCase الفعلي عندك (Params class أو باراميترين)
    final result = await updatePropertyStatusUseCase(
      UpdatePropertyStatusParams(propertyId: property.id, newStatus: newStatus),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => load(property.id),
    );
  }
}
