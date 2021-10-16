import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:models/category.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/utility/text_input_formatter.dart';
import 'package:subbonline_storeadmin/viewmodels/category_view_model.dart';
import 'package:subbonline_storeadmin/widgets/image_upload_widget.dart';

class CategorySetupPage extends ConsumerWidget {
  static const id = "category_setup_page";


  CategorySetupPage();

  double _width;
  bool isFormChanged = false;
  String _categoryId;
  String _mainCategoryId;
  String _category;
  String _mainCategoryName;

  int noOfDeals;
  int noOfProducts;

  static final _formKey = GlobalKey<FormState>();

  final TextEditingController categoryEditingController = TextEditingController();
  final TextEditingController mainCategoryEditingController = TextEditingController();

  final FocusScopeNode _categoryFocusNode = FocusScopeNode();
  final FocusScopeNode _mainCategoryFocusNode = FocusScopeNode();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(categoryViewModelProvider);
    final model = watch(categoryViewModelProvider.notifier);
    _width = MediaQuery.of(context).size.width;

    Future<ConfirmAction> _asyncConfirmDialog({BuildContext context, String header, String alertMessage}) async {
      assert(header != null);
      assert(alertMessage != null);
      return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              header,
              style: k16BoldBlack,
            ),
            content: Text(
              alertMessage,
              style: kTextInputStyle,
            ),
            buttonPadding: EdgeInsets.only(left: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.CANCEL);
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.CONFIRM);
                },
              )
            ],
          );
        },
      );
    }
    Future<bool> showAlertDialog({
      @required BuildContext context,
      @required String title,
      @required String content,
      String  cancelActionText,
      @required String defaultActionText,
    }) async {
      if (!Platform.isIOS) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              if (cancelActionText != null)
                TextButton(
                  child: Text(cancelActionText),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              TextButton(
                child: Text(defaultActionText),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      }
    }
    Future<void> showExceptionAlertDialog({
      @required BuildContext context,
      @required String title,
      @required String exception,
    }) =>
        showAlertDialog(
          context: context,
          title: title,
          content: exception,
          defaultActionText: 'OK',
        );

    initialise() {
      _categoryId = null;
      _mainCategoryId = null;
      _category = null;
      _mainCategoryName = null;
      categoryEditingController.clear();
      mainCategoryEditingController.clear();
      isFormChanged = false;
      model.initialise();
    }
    populateScreen(Category category) async {
      _categoryId = category.id;
      _mainCategoryId = category.mainCategory;
      _category = category.category;
      categoryEditingController.text = category.category;
      _mainCategoryName = await model.getMainCategoryName(_mainCategoryId);
      mainCategoryEditingController.text = _mainCategoryName;
      model.populateCategory(category);
      noOfDeals = category.noOfDeals;
      noOfProducts = category.noOfProducts;
      isFormChanged = false;
    }

    saveCategory() async {
      if (!isFormChanged && !model.isImageChanged()) {
        displayMessage(context, "There is no change to save");
        return;
      }
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        await EasyLoading.show(
          status: 'Saving...',
          maskType: EasyLoadingMaskType.clear,
        );
        try {
          await model.saveCategory(
              id: _categoryId,
              category: _category,
              mainCategory: _mainCategoryId
          );
        } on Exception catch (e) {
          EasyLoading.dismiss();
          displayMessage(context, e.toString());
          return;
        }
        EasyLoading.dismiss();
        if (state is CategoryError) {
          print('State is Error');

          //Error should be handled by ProviderListener.
        }
        else {
          displayMessage(context, "Category saved successfully");
          isFormChanged = false;
        }
      }
    }

    Widget buildCategoryTypeAhead() {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 75, maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
          child: TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: categoryEditingController,
                style: TextStyle(fontSize: 14),
                textInputAction: TextInputAction.next,
                autofocus: true,
                focusNode: _categoryFocusNode,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [FirstCharUpperTextFormatter()],
                onSubmitted: (value) async {
                  var category = await model.getCategoryByName(value);
                  if (category == null) {
                    var confirm = await _asyncConfirmDialog(
                        context: context,
                        header: "New Category $value",
                        alertMessage: "Category doesn't exist. \nDo you want to create new Category?");
                    if (confirm == ConfirmAction.CANCEL) {
                      categoryEditingController.clear();
                      _categoryFocusNode.requestFocus(FocusNode());
                    }
                    else {
                      initialise();
                      categoryEditingController.text = value;
                      _mainCategoryFocusNode.requestFocus(FocusNode());
                    }
                  }
                  else {
                     await populateScreen(category);
                     _mainCategoryFocusNode.requestFocus(FocusNode());
                  }
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                    border: outlineInputBorder(Colors.grey),
                    enabledBorder: outlineInputBorder(Colors.orangeAccent),
                    focusedBorder: outlineInputBorder(Colors.blue),
                    errorBorder: outlineInputBorder(Colors.red),
                    disabledBorder: outlineInputBorder(Colors.grey),
                    hintText: "Name",
                    hintStyle: TextStyle(fontSize: 14),
                    labelText: " Name",
                    helperText: "Please type category name.",
                    labelStyle: TextStyle(fontSize: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 0.0),
                      child: Icon(
                        Icons.android,
                        size: 18,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        initialise();
                        model.rebuildWidget();
                      },
                      child: Icon(Icons.clear),
                    ))),
            suggestionsCallback: (pattern) async {
              return await model.getCategories(pattern);
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },

            itemBuilder: (context, suggestion) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      dense: true,
                      leading: suggestion.imageUrl != null && suggestion.imageUrl.length > 0
                          ? SizedBox(width: 30, height: 30, child: Image.network(suggestion.imageUrl))
                          : SizedBox(
                        width: 30,
                        height: 30,
                      ),
                      title: Text(
                        '${suggestion.category}',
                        style: TextStyle(fontSize: 14),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Divider(
                      height: 1,
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  )
                ],
              );
            },
            onSuggestionSelected: (suggestion) async {
              initialise();
              await populateScreen(suggestion);
              //_isProductExist = true;
            },
            keepSuggestionsOnLoading: true,
            hideSuggestionsOnKeyboardHide: true,
            noItemsFoundBuilder: (context) {
              return null;
            },
            validator: validateCategoryName,
            onSaved: saveCategoryName,
          ),
        ),
      );
    }
    Widget buildMainCategoryTypeAhead() {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 75, maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {

              }
            },
            child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: mainCategoryEditingController,
                  style: TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.next,
                  autofocus: false,
                  focusNode: _mainCategoryFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [FirstCharUpperTextFormatter()],
                  onSubmitted: (value) async {
                    var mainCategory = await model.getMainCategoryByName(value);
                    if (mainCategory == null) {
                      showExceptionAlertDialog(context: context, title: "Error", exception: "Main Category doesn't exist. Please select from the dropdowm.");
                      _mainCategoryFocusNode.requestFocus(FocusNode());
                    }
                    else {
                      //populateScreen(mainCategory);
                      //_intCatCodeFocusNode.requestFocus(FocusNode());
                    }
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                      border: outlineInputBorder(Colors.grey),
                      enabledBorder: outlineInputBorder(Colors.orangeAccent),
                      focusedBorder: outlineInputBorder(Colors.blue),
                      errorBorder: outlineInputBorder(Colors.red),
                      disabledBorder: outlineInputBorder(Colors.grey),
                      hintText: "Main Category",
                      hintStyle: TextStyle(fontSize: 14),
                      labelText: " Main Category",
                      helperText: "Please type/select main category name.",
                      labelStyle: TextStyle(fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 0.0),
                        child: Icon(
                          Icons.android,
                          size: 18,
                        ),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          // initialise();
                          // model.rebuildWidget();
                        },
                        child: Icon(Icons.clear),
                      ))),
              suggestionsCallback: (pattern) async {
                return await model.getMainCategories(pattern);
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              itemBuilder: (context, suggestion) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                        dense: true,
                        leading: suggestion.imageUrl != null && suggestion.imageUrl.length > 0
                            ? SizedBox(width: 30, height: 30, child: Image.network(suggestion.imageUrl))
                            : SizedBox(
                          width: 30,
                          height: 30,
                        ),
                        title: Text(
                          '${suggestion.name}',
                          style: TextStyle(fontSize: 14),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Divider(
                        height: 1,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    )
                  ],
                );
              },
              onSuggestionSelected: (suggestion) {
                mainCategoryEditingController.text = suggestion.name;
                _mainCategoryId = suggestion.id;
                //initialise();

                //populateScreen(suggestion);
                //_isProductExist = true;
              },
              keepSuggestionsOnLoading: true,
              hideSuggestionsOnKeyboardHide: true,
              noItemsFoundBuilder: (context) {
                return null;
              },
               validator: validateMainCategoryName,
               onSaved: saveMainCategoryName,
            ),
          ),
        ),
      );
    }
    Widget buildImageUploadCustomWidget() {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ImageUploadWidget(
            width: _width * 0.95,
            height: _width * 0.48,
            enable: categoryEditingController.text.length > 1,
          ),
        ),
      );
    }
    Future<bool> canPopScreen(BuildContext context) async {
      if (isFormChanged) {
        ConfirmAction action = await _asyncConfirmDialog(
            context: context, header: "Exit Screen", alertMessage: "Do you want to leave screen without save?");
        if (action == ConfirmAction.CONFIRM) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    }

    return ProviderListener(
      provider: categoryViewModelProvider,
      onChange: (context, model) {
        if (state is CategoryError) {
          displayMessage(context, state.errorMessage);
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("Category Maintenance")),
            leading: InkWell(
              child: Icon(Icons.arrow_back),
              onTap: () async {
                 if (await canPopScreen(context)) {
                    context.read(categoryViewModelProvider.notifier).initialise();
                    Navigator.pop(context);
                }
              },
            ),
            actions: [
              InkWell(
                onTap: () async {
                  await saveCategory();
                  return;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tooltip(
                      message: "Save",
                      child: Icon(
                        Icons.save,
                        color: Colors.blue,
                        size: 28,
                      )),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Form(
                key: _formKey,
                onChanged: () {
                  isFormChanged = true;
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildCategoryTypeAhead(),
                    buildMainCategoryTypeAhead(),
                    buildImageUploadCustomWidget(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (noOfDeals != null && noOfDeals > 0)
                          Text("Number of Deals $noOfDeals"),
                          if (noOfProducts != null && noOfProducts > 0)
                          Text("Number of Products $noOfProducts")
                        ],
                      ),
                    )
                  ],
                ),
              ),

            ),
          ),

        ),

      ),
    );
  }

  String formatException(String exception) {
    if (exception.contains("Exception:")) {
      int idx = exception.indexOf("Exception:");
      if (idx >= 0) {
        return exception.substring(idx + "Exception:".length).trim();
      }
    }
    return exception;
  }

  displayMessage(BuildContext context, String message) {
    assert(message != null);
    print(message);
    message = formatException(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        formatException(message),
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(milliseconds: 2000),
    ));
  }

  String validateCategoryName(String value) {
    if (value.isEmpty) return "Category Name cannot be blank.";
    if (value.length < 2) return "Name should be more than two characters.";
    return null;
  }

  void saveCategoryName(String newValue) {
    _category = newValue;
  }

  String validateMainCategoryName(String value) {
    if (value.isEmpty) return "Main Category cannot be blank.";
    return null;
  }

  void saveMainCategoryName(String newValue) {
    _mainCategoryId = _mainCategoryId;
  }

}
