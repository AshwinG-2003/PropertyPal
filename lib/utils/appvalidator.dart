class AppValidator{
  String? validateName(value){
    if (value!.isEmpty){
      return "Please enter a name";
    }
    return null;
  }

  String? validateEmail(value){
    if (value!.isEmpty){
      return "Please enter an email";
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)){
      return "Please enter a value email";
    }
    return null;
  }

  String? validatePassword(value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? isEmptyCheck(value){
    if (value!.isEmpty){
      return "Please fill details";
    }
    return null;
  }
}