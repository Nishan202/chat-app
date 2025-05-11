import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../services/remote/firebase_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  FirebaseRepository firebaseRepository;
  LoginCubit({required this.firebaseRepository}) : super(LoginInitialState());

  void authenticateUser(String email, String password) async {
    emit(LoginLoadingState());
    try{
      await firebaseRepository.loginUser(email: email, password: password);
      emit(LoginSuccessState());
    } catch (e){
      emit(LoginFailedState(errorMessage: e.toString()));
    }
  }
}
