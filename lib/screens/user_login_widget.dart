


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/models/store.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/viewmodels/onboarding_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/progress_bar_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/user_login_view_model.dart';

class UserLoginWidget extends StatefulWidget {


  UserLoginWidget();

  @override
  _StoreSelectionState createState() => _StoreSelectionState();
}

class _StoreSelectionState extends State<UserLoginWidget> {


  _StoreSelectionState();

  static final _formKey = GlobalKey<FormState>();
  final TextEditingController userLoginController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  bool bLogin = false;

  String _userValidationError;

  @override
  Widget build(BuildContext context) {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    return Container(
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 2,
          color: Colors.white,
          margin: EdgeInsets.all(30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: Colors.grey.shade300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, constraint) {
                return Container(
                  height: 35,
                  width: constraint.maxWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      color: Color(0xFFFD7465)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Login.",
                          style: TextStyle(
                              fontFamily: 'Roboto', fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        Text("Store: ${userLoginViewModel.getStoreId()}", style: TextStyle(
                            fontFamily: 'Roboto', fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),),
                        Text("Branch: ${userLoginViewModel.getBranchId()}", style: TextStyle(
                            fontFamily: 'Roboto', fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 10,
              ),
              _inputField(
                  textEditingController: userLoginController,
                  hintText: "User Login",
                  initialValue: userLoginController.text.isEmpty ? userLoginViewModel.getLastLoginId() : userLoginController.text,
                  helperText: "Please enter user login id.",
                  obscureText: false,
                  prefixIcon: Icons.login,
                  suffixIcon: Icons.close,
                  suffixIconFunction: (){
                    userLoginController.clear();
                    userPasswordController.clear();
                  },
                  enable: true,
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
                  validateFunction: _validateUserLogin,

                  ),
              _inputField(
                  textEditingController: userPasswordController,
                  hintText: "Password",
                  helperText: "Please enter password",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_sharp,
                  enable: true,
                  autoFocus: userLoginViewModel.getLastLoginId() != null ? true: false,
                  maxLength: 10,
                  textInputAction: TextInputAction.done,
                  validateFunction: _validateUserPassword,
                  onFieldSubmittedFunction: onLoginSubmitted,
                errortext: _userValidationError
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: bLogin,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
                      child: ElevatedButton(
                          onPressed: () async {
                            await onLoginSubmitted();
                          },
                          child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void>  onLoginSubmitted() async {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    setState(() {
      bLogin = true;
    });
    _formKey.currentState.validate();
    String userId = userLoginController.text;
    String password = userPasswordController.text;
    bool bUserVerified = await userLoginViewModel.verifyUserPassword(userId, password);
    setState(() {
      bLogin = false;
    });
    if (bUserVerified) {
      print("USER LOGIN SUCCESSFUL");
      await userLoginViewModel.saveLastLoginId(userId);
      userLoginViewModel.loginSuccess();
      setState(() {
        _userValidationError = null;
      });
      // final progressBarViewModel = context.read(progressViewModelProvider.notifier);
      // progressBarViewModel.startProgress();
    }
    else {
      print("USER LOGIN NOT-SUCCESSFUL");
      setState(() {
        _userValidationError = 'Invalid User ID or Password.';
      });
    }


  }



  String _validateUserLogin(String value) {
    if (value.isEmpty) return "Please enter login id.";

    return null;
  }

  String _validateUserPassword(String value) {
    if (value.isEmpty) return "Please enter login id.";

    return null;
  }


  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
          topLeft: Radius.circular(5.0),
          topRight: Radius.circular(5.0),
        ));
  }

  Padding _inputField(
      {@required String hintText,
        @required String helperText,
        String dbValue,
        @required IconData prefixIcon,
        IconData suffixIcon,
        String errortext,
        @required TextEditingController textEditingController,
        @required TextInputType textInputType,
        @required bool obscureText,
        @required TextInputAction textInputAction,
        TextAlign textAlign,
        TextDirection textDirection,
        bool autoFocus = false,
        bool enable,
        String initialValue,
        int maxLength,
        @required FocusNode focusNode,
        @required Function validateFunction,
        @required Function onSaveFunction,
        @required Function onFieldSubmittedFunction,
        Function suffixIconFunction,
        EdgeInsetsGeometry padding,
        int minLines,
        int maxLines}) {
    if (initialValue != null) {
      TextEditingController lTextEditingController;
      if (textEditingController != null) {
        textEditingController.text = initialValue;
      }
    }

    return Padding(
      padding: padding == null ? EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30) : padding,
      child: TextFormField(
        enableInteractiveSelection: true,
        initialValue: dbValue,
        textAlign: textAlign == null ? TextAlign.left : textAlign,
        maxLength: maxLength,
        enabled: enable,
        controller: textEditingController,
        keyboardType: textInputType,
        obscureText: obscureText ?? false,
        textDirection: textDirection == null ? TextDirection.ltr : textDirection,
        style: kTextInputStyle,
        textInputAction: textInputAction,
        autofocus: autoFocus,
        minLines: minLines == null ? 1 : minLines,
        maxLines: maxLines == null ? 1 : maxLines,
        decoration: InputDecoration(
          isDense: true,
          counter: SizedBox.shrink(),
          alignLabelWithHint: true,
          labelText: hintText,
          hintText: hintText,
          helperText: helperText,
          errorText: errortext,
          //hintStyle: kLineStyle,
          errorMaxLines: 2,
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          disabledBorder: _outlineInputBorder(Colors.grey),
          enabledBorder: _outlineInputBorder(Colors.yellowAccent.withGreen(10).withOpacity(0.18)),
          focusedErrorBorder: _outlineInputBorder(Colors.redAccent),
          errorBorder: _outlineInputBorder(Colors.redAccent),
          focusedBorder: _outlineInputBorder(Colors.blueAccent),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 0.0),
            child: Icon(
              prefixIcon,
              size: 18,
            ),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 0.0),
            child: InkWell(
              onTap: suffixIconFunction,
              child: Icon(
                suffixIcon,
                size: 18,
                color: Colors.black,
              ),
            ),
          )
              : null,
        ),
        onChanged: (value) {},
        validator: validateFunction,
        onSaved: onSaveFunction,
        onEditingComplete: onFieldSubmittedFunction,
      ),
    );
  }
}
