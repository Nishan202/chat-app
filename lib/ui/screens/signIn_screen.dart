import 'package:chat_app/cubit/login/login_cubit.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      body: SafeArea(child: Form(key: signInkey, child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppString.signIn, style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 15),
            Text(AppString.signInSubHeading, style: Theme.of(context).textTheme.bodySmall),
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
            SizedBox(height: 25,),
            TextButton(
              onPressed: () {
                // AppRoutes.navigateTo(RouteName.FORGOT_PASSWORD_SCREEN);
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero,),
              child: Text(
                  AppString.forgotPassword,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)
              ),
            ),
            Spacer(),
            // CustomButton(
            //   btnType: ButtonType.elevated,
            //   title: AppString.signIn,
            //   onClick: () {
            //     // AppRoutes.navigateOffAllTo(RouteName.BOTTOM_NAVIGATION_BAR);
            //
            //   },
            // ),
            BlocConsumer<LoginCubit, LoginState>(builder: (_, state){
              if(state is LoginLoadingState){
                return CustomButton(title: AppString.signUp, loading: true, onClick: (){}, btnType: ButtonType.elevated);
              }
              return CustomButton(
                title: AppString.signIn,
                btnType: ButtonType.elevated,
                onClick: () {
                  // Form validation with region button
                  if (signInkey.currentState!.validate()) {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    BlocProvider.of<LoginCubit>(context).authenticateUser(email, password);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Successful')));
                  }
                  // AppRoutes.navigateOffTo(RouteName.SUBSCRIPTION_SCREEN);
                },
              );
            }, listener: (_, state){
              if(state is LoginFailedState){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.white, content: Text(state.errorMessage, style: TextStyle(color: Colors.red),)));
              } else if(state is LoginSuccessState){
                // Go to Chat list screen
              }
            }),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    AppString.dontHaveAnAccount,
                    style: Theme.of(context).textTheme.bodySmall
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.REGISTRATION_SCREEN_ROUTE);
                  },
                  child: Text(
                      AppString.signUp,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(decoration: TextDecoration.underline, decorationThickness: 2, decorationStyle: TextDecorationStyle.solid,)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),),),
    );
  }
}
