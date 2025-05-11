import 'package:flutter/material.dart';

// Define the enum
enum ButtonType { elevated, outlined }
class CustomButton extends StatelessWidget {
  final String title;
  final bool isThereIcon;
  final IconData? leadingIcon;
  final bool? isLeadingIcon;
  final IconData? trailingIcon;
  final bool? isTrailingIcon;
  final bool loading;
  final ButtonType btnType;
  final VoidCallback? onClick;
  const CustomButton({super.key, required this.title, this.loading=false, required this.onClick, required this.btnType, this.trailingIcon, this.leadingIcon, this.isThereIcon = false, this.isLeadingIcon, this.isTrailingIcon});

  @override
  Widget build(BuildContext context) {
    return btnType == ButtonType.elevated ? ElevatedButton(
      onPressed: onClick,
      child: loading == true ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.white,) : isThereIcon == true ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLeadingIcon == true ? Icon(leadingIcon, color: Colors.white, size: 22,) : Container(),
          SizedBox(width: 5,),
          Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white,),),
          SizedBox(width: 5,),
          isTrailingIcon == true ? Icon(trailingIcon, color: Colors.white, size: 22,) : Container()
        ],
      ) : Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white,),),
    ) : OutlinedButton(onPressed: onClick, child: loading == true ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.lightGreen,) : Text(title, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.lightGreen),),);
  }
}