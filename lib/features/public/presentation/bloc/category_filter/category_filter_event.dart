part of 'category_filter_bloc.dart';

sealed class CategoryFilterEvent extends Equatable {
  const CategoryFilterEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchCategoryFilterEvent extends CategoryFilterEvent {
  const FetchCategoryFilterEvent();
}
