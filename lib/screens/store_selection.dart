import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/models/store.dart';
import 'package:subbonline_storeadmin/viewmodels/onboarding_view_model.dart';

class StoreSelection extends StatefulWidget {


  StoreSelection();

  @override
  _StoreSelectionState createState() => _StoreSelectionState();
}

class _StoreSelectionState extends State<StoreSelection> {

  bool isStoreExist = true;
  bool isBranchExist = true;
  bool bSave = false;
  bool bValidateStore = false;
  bool bValidateBranch = false;

  String storeId;

  String _storeName;
  String _branchName;

  _StoreSelectionState();

  static final _formKey = GlobalKey<FormState>();
  final TextEditingController storeCodeController = TextEditingController();
  final TextEditingController storeBranchCodeController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Container(
      width: orientation == Orientation.landscape ? 400 : null,
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
                    child: Text(
                      "Store Onboarding.",
                      style: TextStyle(
                          fontFamily: 'Roboto', fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 10,
              ),
              _inputField(
                  textEditingController: storeCodeController,
                  hintText: "Store Code",
                  obscureText: false,
                  prefixIcon: Icons.store,
                  enable: true,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  validateFunction: _validateStoreCode,
                  onFieldSubmittedFunction: onStoreEditingComplete),
              if (_storeName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 30, right: 30),
                  child: Text(_storeName, style: TextStyle( fontFamily: 'Roboto', fontSize: 12,),),
                ),
              _inputField(
                  textEditingController: storeBranchCodeController,
                  hintText: "Branch Code",
                  obscureText: false,
                  prefixIcon: Icons.account_tree_outlined,
                  enable: true,
                  maxLength: 10,
                  textInputAction: TextInputAction.done,
                  validateFunction: _validateBranchCode,
                  onFieldSubmittedFunction: onBranchEditingComplete
              ),
              if (_branchName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 30, right: 30),
                  child: Text(_branchName, style: TextStyle( fontFamily: 'Roboto', fontSize: 12,),),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: bSave,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 30, right: 30),
                      child: ElevatedButton(
                          onPressed: () async {
                            await onPressCompleteButton();
                          },
                          child: Text("Complete", style: TextStyle(color: Colors.white, fontSize: 16))),
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

  Future<void> onStoreEditingComplete() async {
    bValidateStore = true;
    bValidateBranch = false;
    print("Store Editing Complete");
    isStoreExist = true;
    String storeId = storeCodeController.text;
    if (_formKey.currentState.validate()) {
      String _storeExist = await _validateStoreCodeAsync(storeId);
      setState(() {
        if (_storeExist != null) {
          isStoreExist = true;
        } else {
          isStoreExist = false;
        }
        _formKey.currentState.validate();
      });
    }
  }

  Future<void> onBranchEditingComplete() async {
    await onPressCompleteButton();
  }

  String _validateStoreCode(String value) {
    if (!bValidateStore) return null;
    if (value.isEmpty) return "Please enter store code.";
    if (!isStoreExist) {
      return "Store code $value doesn't exist.";
    }
    return null;
  }

  Future<String> _validateStoreCodeAsync(String value) async {
    final onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
    storeId = value;
    _storeName = null;
    Store _store = await onboardingViewModel.getStore(storeId);
    if (_store != null) {
      _storeName = _store.store;
      return _storeName;
    }
    return null;
  }

  String _validateBranchCode(String value) {
    if (!bValidateBranch) return null;
    if (value.isEmpty) return "Please enter branch code.";
    if (!isBranchExist) {
      return "Branch code $value doesn't exist.";
    }

    return null;
  }

  Future<String> _validateStoreBranchAsync(String value) async {
    if (storeId.isEmpty) return null;

    final onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
    StoreBranch _storeBranch = await onboardingViewModel.getStoreBranch(storeId, value);
    _branchName = null;
    if (_storeBranch != null) {
      _branchName = _storeBranch.name;
      return _branchName;
    }

    return null;
  }

  Future<void> onPressCompleteButton() async {
    isStoreExist = true;
    isBranchExist = true;
    bValidateStore = true;
    bValidateBranch = true;
    String storeId = storeCodeController.text;
    if (_formKey.currentState.validate()) {
      String _storeExist = await _validateStoreCodeAsync(storeId);
      setState(() {
        if (_storeExist != null) {
          isStoreExist = true;
        } else {
          isStoreExist = false;
        }
        _formKey.currentState.validate();
      });
      String branchId = storeBranchCodeController.text;
      print("SAVE $storeId");
      String _branchExist = await _validateStoreBranchAsync(branchId);
      setState(() {
        if (_branchExist != null) {
          isBranchExist = true;
        } else {
          isBranchExist = false;
        }
        if (_formKey.currentState.validate()) {
          bSave = true;
        }
      });
      if (bSave) {
        final onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
        await onboardingViewModel.setStoreId(storeId);
        await onboardingViewModel.setBranchId(branchId);
        await onboardingViewModel.completeOnboarding();
      }

      setState(() {
        bSave = false;
      });
    }
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
      String dbValue,
      @required IconData prefixIcon,
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
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          isDense: true,
          counter: SizedBox.shrink(),
          alignLabelWithHint: true,
          labelText: hintText,
          //hintText: hintText,
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
        ),
        onChanged: (value) {},
        validator: validateFunction,
        onSaved: onSaveFunction,
        onEditingComplete: onFieldSubmittedFunction,
      ),
    );
  }
}
