import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_4_login/login/models/password.dart';
import 'package:bloc_4_login/login/models/username.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository,
  super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }
  final AuthenticationRepository _authenticationRepository;

  void _onUsernameChanged(
      LoginUsernameChanged event, Emitter<LoginState> emit) {
    final username = Username.dirty(event.username);
    emit(state.copyWitch(
        username: username,
        isValid: Formz.validate([state.password, username])));
  }

  void _onPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWitch(
        password: password,
        isValid: Formz.validate([password, state.username])));
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.isValid) {
      emit(state.copyWitch(status: FormzSubmissionStatus.inProgress));
      try {
        await _authenticationRepository.logIn(
            username: state.username.value, password: state.password.value);
        emit(state.copyWitch(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWitch(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
