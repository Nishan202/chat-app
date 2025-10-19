import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String labelText;
  final String? placeholder;
  final int? minimuLine;
  final int? maximumLine;
  final int? maximumLength;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool isobscureText;
  final String? obscureCharacter;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlignment;
  final Color? hintColor;
  final Function()? onClick;
  final String? Function(String?)? validate;

  const CustomTextfield({
    super.key,
    this.validate,
    required this.labelText,
    this.placeholder,
    this.minimuLine,
    this.maximumLine,
    this.inputType = TextInputType.text,
    this.isobscureText = false,
    this.obscureCharacter = "*",
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.textAlignment = TextAlign.start,
    this.maximumLength,
    this.hintColor,
    this.onClick});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validate,
      minLines: minimuLine,
      maxLines: maximumLine,
      maxLength: maximumLength,
      textAlign: textAlignment,
      keyboardType: inputType,
      obscureText: isobscureText,
      obscuringCharacter: obscureCharacter!,
      controller: controller,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(), // when tap outside the textfield then virtual keyboard will off
      decoration: InputDecoration(
        hintText: placeholder,
        label: Text(labelText, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),),
        hintStyle: Theme.of(context).textTheme.bodySmall,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      onTap: onClick,
    );
  }
}