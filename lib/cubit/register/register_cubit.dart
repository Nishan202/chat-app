import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  FirebaseRepository firebaseRepository;
  RegisterCubit({required this.firebaseRepository}) : super(RegisterInitialState());

  void registerUser(UserModel user, String password) async {
    emit(RegisterLoadingState());
    try{
      await firebaseRepository.createUser(user: user, password: password);
      emit(RegisterSuccessState());
    } catch (e){
      emit(RegisterFailedState(errorMessage: e.toString()));
    }
  }
}
