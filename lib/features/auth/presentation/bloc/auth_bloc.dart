import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/core/services/notification_service.dart';
import 'package:agrilink/injector.dart';
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
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await signInUseCase.execute(event.data);
      await _registerFcmToken(auth.user.role);
      emit(AuthSuccess(authResponse: auth));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final message = await signUpUseCase.execute(event.data);
      emit(AuthMessage(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final auth = await verifyOtpUseCase.execute(event.data);
      await _registerFcmToken(auth.user.role);
      emit(AuthSuccess(authResponse: auth));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final auth = await googleSignInUseCase.execute();
      await _registerFcmToken(auth.user.role);
      emit(AuthSuccess(authResponse: auth));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await forgotPasswordUseCase.execute(event.data);
      emit(AuthMessage(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final message = await resetPasswordUseCase.execute(event.data);
      emit(AuthMessage(message: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _unregisterFcmToken();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // ==================== FCM TOKEN METHODS ====================

  Future<void> _registerFcmToken(String role) async {
    try {
      final notificationService = sl<NotificationService>();
      final token = await notificationService.getSavedToken();

      if (token != null) {
        await notificationService.registerDeviceToken(token);

        // Subscribe to topics based on user role
        await notificationService.subscribeToTopic('all_users');
        await notificationService.subscribeToTopic(
          'role_${role.toLowerCase()}',
        );
      }
    } catch (e) {
      // Silent fail - don't block login flow
    }
  }

  Future<void> _unregisterFcmToken() async {
    try {
      final notificationService = sl<NotificationService>();
      await notificationService.unregisterDeviceToken();
    } catch (e) {
      // Silent fail
    }
  }
}
