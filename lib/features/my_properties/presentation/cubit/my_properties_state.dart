part of "my_properties_cubit.dart";

enum MyPropertiesStatus { initial, loading, loadingMore, loaded, error }

class MyPropertiesState extends Equatable {
  final MyPropertiesStatus status;
  final PropertyStatusFilter filter;
  final List<MyPropertyEntity> properties;
  final int page;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? actionMessage; // رسالة بعد حذف/تغيير حالة

  const MyPropertiesState({
    this.status = MyPropertiesStatus.initial,
    this.filter = PropertyStatusFilter.all,
    this.properties = const [],
    this.page = 0,
    this.hasReachedMax = false,
    this.errorMessage,
    this.actionMessage,
  });

  MyPropertiesState copyWith({
    MyPropertiesStatus? status,
    PropertyStatusFilter? filter,
    List<MyPropertyEntity>? properties,
    int? page,
    bool? hasReachedMax,
    String? errorMessage,
    String? actionMessage,
  }) {
    return MyPropertiesState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      properties: properties ?? this.properties,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, filter, properties, page, hasReachedMax, errorMessage, actionMessage];
}
