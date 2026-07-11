import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_property_details_usecase.dart';
import '../../domain/usecases/report_property_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'property_details_state.dart';

class PropertyDetailsCubit extends Cubit<PropertyDetailsState> {
  final GetPropertyDetailsUseCase getPropertyDetails;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final ReportPropertyUseCase reportPropertyUseCase;

  PropertyDetailsCubit({
    required this.getPropertyDetails,
    required this.toggleFavoriteUseCase,
    required this.reportPropertyUseCase,
  }) : super(const PropertyDetailsState());

  Future<void> load(String propertyId) async {
    emit(state.copyWith(status: PropertyDetailsStatus.loading));
    final result = await getPropertyDetails(propertyId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PropertyDetailsStatus.error,
        errorMessage: failure.message,
      )),
      (property) => emit(state.copyWith(
        status: PropertyDetailsStatus.loaded,
        property: property,
      )),
    );
  }

  Future<void> toggleFavorite() async {
    final current = state.property;
    if (current == null) return;

    // Optimistic update so the heart icon responds instantly.
    emit(state.copyWith(property: current.copyWith(isFavorite: !current.isFavorite)));

    final result = await toggleFavoriteUseCase(current.id);
    result.fold(
      (failure) {
        // Revert on failure.
        emit(state.copyWith(property: current, errorMessage: failure.message));
      },
      (_) {},
    );
  }

  Future<void> submitReport(String reason) async {
    final current = state.property;
    if (current == null) return;

    emit(state.copyWith(isSubmittingReport: true, reportSubmitted: false));
    final result = await reportPropertyUseCase(
      ReportPropertyParams(propertyId: current.id, reason: reason),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmittingReport: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmittingReport: false, reportSubmitted: true)),
    );
  }
}
