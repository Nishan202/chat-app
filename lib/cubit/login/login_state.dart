part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitialState extends LoginState {}
final class LoginLoadingState extends LoginState {}
final class LoginSuccessState extends LoginState {}
final class LoginFailedState extends LoginState {
  String errorMessage;
  LoginFailedState({required this.errorMessage});
}
