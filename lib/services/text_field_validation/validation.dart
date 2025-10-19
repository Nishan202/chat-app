import '../../constant/app_string.dart';

class Validator {
  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  RegExp emailValid = RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,8})+$');

  String? validateEmail(String? emailText) {
    if (emailText != null) {
      String email = emailText.trim();
      if (email.isEmpty) {
        return AppString.emptyEmail;
      } else if (email.length < 3) {
        return AppString.smallEmail;
      }
      // else if (!emailValid.hasMatch(email)) {
      //   return AppString.strongEmail;
      // }
      else {
        return null;
      }
    }
    return null;
  }

  String? validatePhoneNumber(String phoneNo, {String? customMsg}){
    if(phoneNo.isEmpty){
      return customMsg ?? AppString.empty;
    } else if (phoneNo.length < 4 && phoneNo.length > 12) {
      return AppString.invalidPhoneNo;
    } else {
      return null;
    }
  }

  String? validateTextfield(String text, {String? customMsg}) {
    if (text.isEmpty) {
      return customMsg ?? AppString.emptyDropdown;
    } else {
      return null;
    }
  }

  String? validateDropdown(String text, {String? customMsg}) {
    if (text.isEmpty) {
      return customMsg ?? AppString.empty;
    } else {
      return null;
    }
  }

  String? validatePassword(String pass, {String? customMessage}) {
    pass = pass.trim();
    if (pass.isEmpty) {
      return customMessage ?? AppString.emptyPassMessage;
    }
    //  else if (pass.length < 6) {
    //   return AppString.smallPassMessage;
    // }
    // else if (!passValid.hasMatch(pass)) {
    //   return AppString.strongPassMessage;
    // }
    else {
      return null;
    }
  }

  String? validateConfirmPassword(String password, String confirmPass,
      {String? customMessage}) {
    confirmPass = confirmPass.trim();
    if (password.isEmpty) {
      return customMessage ?? AppString.emptyPassMessage;
    }
    // else if (password.length < 9) {
    //   return AppString.smallPassMessage;
    // }

    if (password != confirmPass) {
      return AppString.matchPassword;
    } else {
      return null;
    }
  }
}
