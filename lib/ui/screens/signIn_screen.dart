import 'package:chat_app/cubit/login/login_cubit.dart';
import 'package:chat_app/cubit/register/register_cubit.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../constant/app_string.dart';
import '../../services/text_field_validation/validation.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  GlobalKey<FormState> signInkey = GlobalKey<FormState>();
  Validator textValidator = Validator();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: signInkey,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppString.signIn,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 15),
                Text(
                  AppString.signInSubHeading,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 30),
                CustomTextfield(
                  labelText: AppString.emailAddressHint,
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  validate: (value) {
                    return textValidator.validateEmail(value!);
                  },
                ),
                SizedBox(height: 25),
                CustomTextfield(
                  controller: _passwordController,
                  maximumLine: 1,
                  isobscureText: !_isPasswordVisible,
                  labelText: AppString.passwordHintText,
                  suffixIcon: IconButton(
                    onPressed: () {
                      _isPasswordVisible = !_isPasswordVisible;
                      setState(() {});
                    },
                    icon:
                        _isPasswordVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                  ),
                  validate: (value) {
                    return textValidator.validatePassword(value!);
                  },
                ),
                SizedBox(height: 25),
                // TextButton(
                //   onPressed: () {
                //     // AppRoutes.navigateTo(RouteName.FORGOT_PASSWORD_SCREEN);
                //   },
                //   style: TextButton.styleFrom(padding: EdgeInsets.zero,),
                //   child: Text(
                //       AppString.forgotPassword,
                //       style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)
                //   ),
                // ),
                // Spacer(),
                BlocConsumer<LoginCubit, LoginState>(
                  builder: (_, state) {
                    if (state is LoginLoadingState) {
                      // isLoading = true;
                      // setState(() {});
                      return CustomButton(
                        title: AppString.signUp,
                        loading: true,
                        onClick: () {},
                        btnType: ButtonType.elevated,
                      );
                    }
                    return CustomButton(
                      loading: isLoading,
                      title: AppString.signIn,
                      btnType: ButtonType.elevated,
                      onClick: () {
                        // Form validation with region button
                        if (signInkey.currentState!.validate()) {
                          String email = _emailController.text;
                          String password = _passwordController.text;
                          BlocProvider.of<LoginCubit>(
                            context,
                          ).authenticateUser(email, password);
                        }
                      },
                    );
                  },
                  listener: (_, state) {
                    if (state is LoginFailedState) {
                      // isLoading = false;
                      // setState(() {});
                      Get.snackbar(
                        "Error",
                        state.errorMessage,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    } else if (state is LoginSuccessState) {
                      // Go to Chat list screen
                      // isLoading = false;
                      // setState(() {});
                      Get.snackbar(
                        "Success",
                        "User Login successfully",
                        backgroundColor: Colors.greenAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.CONTACTS_SCREEN,
                      );
                    }
                  },
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppString.dontHaveAnAccount,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigator.pushNamed(
                        //   context,
                        //   AppRoutes.REGISTRATION_SCREEN_ROUTE,
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RepositoryProvider(
                                  create: (context) => FirebaseRepository(),
                                  child: BlocProvider(
                                    create:
                                        (context) => RegisterCubit(
                                          firebaseRepository:
                                              RepositoryProvider.of<
                                                FirebaseRepository
                                              >(context),
                                        ),
                                    child: SignupScreen(),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: Text(
                        AppString.signUp,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 2,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
