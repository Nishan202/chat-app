import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Define the enum
enum ButtonType { elevated, outlined }

class CustomButton extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final bool loading;
  final ButtonType btnType;
  final VoidCallback? onClick;
  const CustomButton({
    super.key,
    required this.title,
    this.loading = false,
    required this.onClick,
    required this.btnType,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return btnType == ButtonType.elevated
        ? ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
            foregroundColor: Colors.white,
            fixedSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onClick,
          child:
              loading == true
                  ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  )
                  : Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  ),
        )
        : OutlinedButton(
          onPressed: onClick,
          child:
              loading == true
                  ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.lightGreen,
                  )
                  : Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: Colors.lightGreen),
                  ),
        );
  }
}
