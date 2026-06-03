part of 'category_filter_bloc.dart';

enum CategoryFilterStatus { idle, loading, success, failure }

final class CategoryFilterState extends Equatable {
  const CategoryFilterState({
    this.status = CategoryFilterStatus.idle,
    this.filters = const <CategoryFilterModel>[],
    this.errorMessage,
  });

  final CategoryFilterStatus status;
  final List<CategoryFilterModel> filters;
  final String? errorMessage;

  CategoryFilterState copyWith({
    CategoryFilterStatus? status,
    List<CategoryFilterModel>? filters,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryFilterState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, filters, errorMessage];
}
