part of 'register_cubit.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitialState extends RegisterState {}
final class RegisterLoadingState extends RegisterState {}
final class RegisterSuccessState extends RegisterState {}
final class RegisterFailedState extends RegisterState {
  String errorMessage;
  RegisterFailedState({required this.errorMessage});
}
