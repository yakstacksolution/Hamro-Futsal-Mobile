import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/usecase/opponent_match_usecase.dart';

part 'accept_request_event.dart';
part 'accept_request_state.dart';

/// Drives the single-shot acceptance: the accepting team is posted to the
/// request and the requester receives it as an invitation.
///
/// Kept separate from [OpponentMatchBloc] because the accept call has its own
/// lifecycle (re-entrancy, 409/410 terminal errors) that must not leak into the
/// list state.
class AcceptOpponentRequestBloc
    extends Bloc<AcceptRequestEvent, AcceptRequestState> {
  AcceptOpponentRequestBloc(this.useCase) : super(const AcceptRequestState()) {
    on<SubmitAcceptEvent>(_onSubmit);
  }

  final OpponentMatchUseCase useCase;

  Future<void> _onSubmit(
    SubmitAcceptEvent event,
    Emitter<AcceptRequestState> emit,
  ) async {
    // Re-entrancy guard — a double tap or network retry must not accept twice.
    if (state.submitStatus == AcceptRequestStatus.loading) return;
    emit(
      state.copyWith(
        submitStatus: AcceptRequestStatus.loading,
        clearError: true,
      ),
    );
    final result = await useCase.acceptRequest(event.request);
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: AcceptRequestStatus.failure,
          errorMessage: failure.errorMessage,
          errorStatusCode: failure.statusCode,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          submitStatus: AcceptRequestStatus.success,
          result: updated,
          clearError: true,
        ),
      ),
    );
  }
}
