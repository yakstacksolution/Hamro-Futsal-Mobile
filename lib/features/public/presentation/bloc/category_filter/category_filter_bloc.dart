import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/cache/hive/hive_boxes.dart';
import 'package:hamro_futsal/core/cache/hive/hive_cache_service.dart';
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
    final List<CategoryFilterModel> cached = await HiveCacheService.instance
        .readList<CategoryFilterModel>(
          boxName: HiveBoxes.filter,
          scope: 'category_filters',
          fromJson: CategoryFilterModel.fromJson,
        );

    emit(
      state.copyWith(
        status: cached.isEmpty
            ? CategoryFilterStatus.loading
            : CategoryFilterStatus.success,
        filters: cached.isEmpty ? state.filters : cached,
        clearError: true,
      ),
    );

    final Either<AppException, List<CategoryFilterModel>> response =
        await _getCategoryFilterUseCase();

    response.fold(
      (AppException failure) => emit(
        cached.isNotEmpty
            ? state.copyWith(
                status: CategoryFilterStatus.success,
                errorMessage: failure.errorMessage,
              )
            : state.copyWith(
                status: CategoryFilterStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (List<CategoryFilterModel> filters) {
        unawaited(
          HiveCacheService.instance.syncList<CategoryFilterModel>(
            boxName: HiveBoxes.filter,
            scope: 'category_filters',
            items: filters,
            idOf: (CategoryFilterModel filter) => filter.id,
            toJson: (CategoryFilterModel filter) => filter.toJson(),
          ),
        );
        emit(
          state.copyWith(
            status: CategoryFilterStatus.success,
            filters: filters,
            clearError: true,
          ),
        );
      },
    );
  }
}
