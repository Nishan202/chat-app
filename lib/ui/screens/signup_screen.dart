import 'package:chat_app/cubit/register/register_cubit.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../constant/app_string.dart';
import '../../services/text_field_validation/validation.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GlobalKey<FormState> signUpkey = GlobalKey<FormState>();
  Validator textValidator = Validator();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: signUpkey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.signUp,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 15),
                  Text(
                    AppString.signUpSubHeading,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 30),
                  CustomTextfield(
                    labelText: AppString.fullNameHint,
                    controller: _fullNameController,
                    inputType: TextInputType.name,
                    validate: (value) {
                      return textValidator.validateTextfield(value!);
                    },
                  ),
                  SizedBox(height: 25),
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
                    labelText: AppString.phoneNumberHint,
                    controller: _phoneController,
                    inputType: TextInputType.phone,
                    validate: (value) {
                      return textValidator.validatePhoneNumber(value!);
                    },
                  ),
                  SizedBox(height: 25),
                  CustomTextfield(
                    controller: _passwordController,
                    maximumLine: 1,
                    isobscureText: !isPasswordVisible,
                    labelText: AppString.createPasswordHint,
                    suffixIcon: IconButton(
                      onPressed: () {
                        isPasswordVisible = !isPasswordVisible;
                        setState(() {});
                      },
                      icon:
                          isPasswordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                    ),
                    validate: (value) {
                      return textValidator.validatePassword(value!);
                    },
                  ),
                  SizedBox(height: 25),
                  CustomTextfield(
                    labelText: AppString.confirmPasswordHint,
                    controller: _confirmPassController,
                    maximumLine: 1,
                    isobscureText: !_isPasswordVisible,
                    validate: (value) {
                      return textValidator.validateConfirmPassword(
                        _passwordController.text,
                        _confirmPassController.text,
                      );
                    },
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
                  ),
                  SizedBox(height: 25),
                  BlocConsumer<RegisterCubit, RegisterState>(
                    builder: (_, state) {
                      if (state is RegisterLoadingState) {
                        return CustomButton(
                          title: AppString.signUp,
                          loading: true,
                          onClick: () {},
                          btnType: ButtonType.elevated,
                        );
                      }
                      return CustomButton(
                        title: AppString.signUp,
                        btnType: ButtonType.elevated,
                        // loading: false,
                        onClick: () {
                          // Form validation with region button
                          if (signUpkey.currentState!.validate()) {
                            // if(email.isNotEmpty && password.isNotEmpty){
                            UserModel newUser = UserModel(
                              name: _fullNameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              phoneNo: _phoneController.text,
                              createdAt:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              isOnline: false,
                              status: 1,
                              profilePic: "",
                              profileStatus: 1,
                            );
                            BlocProvider.of<RegisterCubit>(
                              context,
                            ).registerUser(newUser, _passwordController.text);
                            // }
                          }
                          // AppRoutes.navigateOffTo(RouteName.SUBSCRIPTION_SCREEN);
                        },
                      );
                    },
                    listener: (_, state) {
                      if (state is RegisterFailedState) {
                        Get.snackbar(
                          "Error",
                          state.errorMessage,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      } else if (state is RegisterSuccessState) {
                        Get.snackbar(
                          "Success",
                          "User registered successfully",
                          backgroundColor: Colors.greenAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppString.alreadyHaveAnAccount,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppString.signIn,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(
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
      ),
    );
  }
}
