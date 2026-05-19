import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:hamro_footsall/features/auth/domain/entities/auth_entities.dart';
import 'package:hamro_footsall/features/auth/domain/usecase/authentication_usecase.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthUseCase authUseCase;
  AuthenticationBloc(this.authUseCase) : super(const AuthenticationState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<OtpVerificationEvent>(_onOtpVerification);
    on<ResendOtpEvent>(_onResendOtp);
    on<LogoutEvent>(_onLogout);
  }

  void _onLogin(LoginEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(
        state.copyWith(
          loginStatus: AuthStatus.loading,
          clearErrorMessage: true,
          clearErrorData: true,
          clearSuccessMessage: true,
        ),
      );
      Either<AppException, TokenModel> response = await authUseCase.signIn(
        SignInEntity(
          email: event.email,
          password: event.password,
          rememberMe: event.rememberMe,
        ),
      );
      response.fold(
        (AppException failure) {
          emit(
            state.copyWith(
              loginStatus: AuthStatus.failure,
              errorMessage: failure.errorMessage,
              loginErrorData: failure.data,
            ),
          );
        },
        (TokenModel token) => emit(
          state.copyWith(
            loginStatus: AuthStatus.success,
            successMessage: 'Login successful',
            clearErrorMessage: true,
            clearErrorData: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loginStatus: AuthStatus.failure,
          errorMessage: error.toString(),
          clearErrorData: true,
        ),
      );
    }
  }

  void _onRegister(
    RegisterEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          registrationStatus: AuthStatus.loading,
          clearErrorMessage: true,
          clearErrorData: true,
          clearSuccessMessage: true,
        ),
      );
      Either<AppException, TokenModel> response = await authUseCase.signUp(
        SignUpEntity(
          email: event.email,
          password: event.password,
          fullName: event.fullName,
          accountType: event.accountType,
          passwordConfirmation: event.passwordConfirmation,
          termAccepted: event.termsAccepted,
        ),
      );
      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            registrationStatus: AuthStatus.failure,
            errorMessage: failure.errorMessage,
            registrationErrorData: failure.data,
          ),
        ),
        (TokenModel token) => emit(
          state.copyWith(
            registrationStatus: AuthStatus.success,
            successMessage: 'Registration successful',
            clearErrorMessage: true,
            clearErrorData: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          registrationStatus: AuthStatus.failure,
          errorMessage: error.toString(),
          clearErrorData: true,
        ),
      );
    }
  }

  FutureOr<void> _onOtpVerification(
    OtpVerificationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          otpVerificationStatus: AuthStatus.loading,
          clearErrorMessage: true,
          clearErrorData: true,
          clearSuccessMessage: true,
        ),
      );

      final Either<AppException, Map<String, dynamic>>? response =
          await authUseCase.verifyOtp(
            OtpVerificationEntity(email: event.email, otp: event.otp),
          );

      if (response == null) {
        emit(
          state.copyWith(
            otpVerificationStatus: AuthStatus.failure,
            errorMessage: 'OTP verification failed. Please try again.',
          ),
        );
        return;
      }

      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            otpVerificationStatus: AuthStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (Map<String, dynamic> data) => emit(
          state.copyWith(
            otpVerificationStatus: AuthStatus.success,
            otpVerificationData: data,
            successMessage: 'OTP verified successfully',
            clearErrorMessage: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          otpVerificationStatus: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          resendOtpStatus: AuthStatus.loading,
          clearErrorMessage: true,
          clearErrorData: true,
          clearSuccessMessage: true,
        ),
      );

      final Either<AppException, Map<String, dynamic>>? response =
          await authUseCase.resendOtp(
            ResendOtpEntity(email: event.email, purpose: event.purpose),
          );

      if (response == null) {
        emit(
          state.copyWith(
            resendOtpStatus: AuthStatus.failure,
            errorMessage: 'Resend OTP failed. Please try again.',
          ),
        );
        return;
      }

      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            resendOtpStatus: AuthStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (Map<String, dynamic> data) => emit(
          state.copyWith(
            resendOtpStatus: AuthStatus.success,
            successMessage: 'OTP resent successfully. Check your email.',
            clearErrorMessage: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          resendOtpStatus: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          logoutStatus: AuthStatus.loading,
          clearErrorMessage: true,
          clearErrorData: true,
          clearSuccessMessage: true,
        ),
      );
      final Either<AppException, bool>? response = await authUseCase.logout();
      if (response == null) {
        emit(
          state.copyWith(
            logoutStatus: AuthStatus.failure,
            errorMessage: 'Logout failed. Please try again.',
          ),
        );
        return;
      }

      response.fold(
        (AppException failure) => emit(
          state.copyWith(
            logoutStatus: AuthStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        ),
        (_) => emit(
          state.copyWith(
            logoutStatus: AuthStatus.success,
            successMessage: 'Logout successful',
            clearErrorMessage: true,
            clearErrorData: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          logoutStatus: AuthStatus.failure,
          errorMessage: error.toString(),
          clearErrorData: true,
        ),
      );
    }
  }
}
