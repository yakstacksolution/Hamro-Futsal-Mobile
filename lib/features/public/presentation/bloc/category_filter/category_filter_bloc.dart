import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/category_filter_model.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_category_filter_use_case.dart';

part 'category_filter_event.dart';
part 'category_filter_state.dart';

class CategoryFilterBloc
    extends Bloc<CategoryFilterEvent, CategoryFilterState> {
  CategoryFilterBloc(this._getCategoryFilterUseCase)
    : super(const CategoryFilterState()) {
    on<FetchCategoryFilterEvent>(_onFetchCategoryFilter);
  }

  final GetCategoryFilterUseCase _getCategoryFilterUseCase;

  FutureOr<void> _onFetchCategoryFilter(
    FetchCategoryFilterEvent event,
    Emitter<CategoryFilterState> emit,
  ) async {
    emit(
      state.copyWith(status: CategoryFilterStatus.loading, clearError: true),
    );

    final Either<AppException, List<CategoryFilterModel>> response =
        await _getCategoryFilterUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: CategoryFilterStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<CategoryFilterModel> filters) => emit(
        state.copyWith(
          status: CategoryFilterStatus.success,
          filters: filters,
          clearError: true,
        ),
      ),
    );
  }
}
