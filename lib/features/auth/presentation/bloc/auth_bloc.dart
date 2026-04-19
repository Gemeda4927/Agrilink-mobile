import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.verifyOtpUseCase,
    required this.googleSignInUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await signInUseCase.execute(event.data);
        emit(AuthSuccess(authResponse: auth));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await signUpUseCase.execute(event.data);
        emit(AuthMessage(message: message));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await verifyOtpUseCase.execute(event.data);
        emit(AuthSuccess(authResponse: auth));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<GoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final auth = await googleSignInUseCase.execute();
        emit(AuthSuccess(authResponse: auth));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await forgotPasswordUseCase.execute(event.data);
        emit(AuthMessage(message: message));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await resetPasswordUseCase.execute(event.data);
        emit(AuthMessage(message: message));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });
  }
}
