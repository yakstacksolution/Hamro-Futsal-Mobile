import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_accept_quote_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/usecase/opponent_match_usecase.dart';

part 'accept_request_event.dart';
part 'accept_request_state.dart';

/// Drives the two-phase accept transaction: quote (accept hold + advance +
/// payment QR), then the multipart accept submit with the payment proof.
///
/// Kept separate from [OpponentMatchBloc] — the accept flow has its own
/// lifecycle (hold expiry, re-entrancy) the same way booking checkout keeps
/// its hold/submit blocs apart from the details bloc.
class AcceptOpponentRequestBloc
    extends Bloc<AcceptRequestEvent, AcceptRequestState> {
  AcceptOpponentRequestBloc(this.useCase) : super(const AcceptRequestState()) {
    on<LoadAcceptQuoteEvent>(_onLoadQuote);
    on<SubmitAcceptEvent>(_onSubmit);
    on<ResetAcceptQuoteEvent>(_onResetQuote);
  }

  final OpponentMatchUseCase useCase;

  Future<void> _onLoadQuote(
    LoadAcceptQuoteEvent event,
    Emitter<AcceptRequestState> emit,
  ) async {
    if (state.quoteStatus == AcceptRequestStatus.loading) return;
    emit(
      state.copyWith(
        quoteStatus: AcceptRequestStatus.loading,
        clearQuote: true,
        clearError: true,
      ),
    );
    final result = await useCase.getAcceptQuote(event.requestId, event.teamId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          quoteStatus: AcceptRequestStatus.failure,
          errorMessage: failure.errorMessage,
          errorStatusCode: failure.statusCode,
        ),
      ),
      (quote) => emit(
        state.copyWith(
          quoteStatus: AcceptRequestStatus.success,
          quote: quote,
          clearError: true,
        ),
      ),
    );
  }

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

  /// Back to the team-confirmation step — the hold expired or the user
  /// changed teams, so the old quote is void.
  void _onResetQuote(
    ResetAcceptQuoteEvent event,
    Emitter<AcceptRequestState> emit,
  ) {
    emit(
      state.copyWith(
        quoteStatus: AcceptRequestStatus.initial,
        clearQuote: true,
        clearError: true,
      ),
    );
  }
}
