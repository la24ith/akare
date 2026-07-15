// lib/features/comparison/presentation/cubit/compare_selection_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/property_entity.dart';
import 'compare_selection_state.dart';

/// ⚠️ يُسجَّل بـ GetIt كـ registerLazySingleton (مش factory) — نفس مبدأ
/// NotificationsCubit، لأنه الاختيار لازم يستمر أثناء تنقل المستخدم بين
/// شاشات مختلفة (بحث → تفاصيل عقار → رجوع) لحد ما يفتح شاشة المقارنة فعليًا.
class CompareSelectionCubit extends Cubit<CompareSelectionState> {
  CompareSelectionCubit() : super(const CompareSelectionState());

  void toggle(PropertyEntity property) {
    final current = List<PropertyEntity>.from(state.selected);
    final exists = current.any((p) => p.id == property.id);

    if (exists) {
      current.removeWhere((p) => p.id == property.id);
    } else {
      if (current.length >= CompareSelectionState.maxItems)
        return; // وصل الحد الأقصى
      current.add(property);
    }
    emit(CompareSelectionState(selected: current));
  }

  void remove(String propertyId) {
    emit(
      CompareSelectionState(
        selected: state.selected.where((p) => p.id != propertyId).toList(),
      ),
    );
  }

  void clear() => emit(const CompareSelectionState());
}
