import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/change_password/domain/usecase/change_password_usecase.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc(this._useCase) : super(const ChangePasswordState()) {
    on<SubmitChangePasswordEvent>(_onSubmit);
  }

  final ChangePasswordUseCase _useCase;

  Future<void> _onSubmit(
    SubmitChangePasswordEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(const ChangePasswordState(status: ChangePasswordStatus.submitting));

    final result = await _useCase(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(
        ChangePasswordState(
          status: ChangePasswordStatus.failure,
          message: failure.errorMessage,
        ),
      ),
      (message) => emit(
        ChangePasswordState(
          status: ChangePasswordStatus.success,
          message: message,
        ),
      ),
    );
  }
}
