// lib/features/price_history/presentation/cubit/price_history_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_price_history_usecase.dart';
import 'price_history_state.dart';

class PriceHistoryCubit extends Cubit<PriceHistoryState> {
  final GetPriceHistoryUseCase getPriceHistory;
  PriceHistoryCubit({required this.getPriceHistory})
    : super(const PriceHistoryState());

  Future<void> load(String propertyId) async {
    emit(state.copyWith(status: PriceHistoryStatus.loading));
    final result = await getPriceHistory(propertyId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PriceHistoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (points) => emit(
        state.copyWith(status: PriceHistoryStatus.loaded, points: points),
      ),
    );
  }
}
