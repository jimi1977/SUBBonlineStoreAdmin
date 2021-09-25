import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/models/main_category.dart';
import 'package:subbonline_storeadmin/repository/main_category_codes.dart';
import 'package:subbonline_storeadmin/utility/text_input_formatter.dart';
import 'package:subbonline_storeadmin/viewmodels/main_category_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';
import 'package:subbonline_storeadmin/widgets/image_upload_widget.dart';

class MainCategorySetupPage extends StatelessWidget {
  static const id = "main_category_setup_page";

  String _mainCategoryId;
  bool _advertise = false;

  String _intCategoryValidationErrorText;

  String _advertisingText;

  String _selectedIntCategory;

  String _advertisingTextColour = 'White';

  String _mainCategoryName;

  bool isFormChanged = false;

  int _displaySequence;

  MainCategorySetupPage({Key key}) : super(key: key);

  static final _formKey = GlobalKey<FormState>();

  final TextEditingController mainCategoryEditingController = TextEditingController();
  final TextEditingController advertisingTextEditingController = TextEditingController();

  final FocusScopeNode _intCatCodeFocusNode = FocusScopeNode();
  final FocusNode _mainCategoryNameFocus = FocusNode(canRequestFocus: true);


  double _width = 0;

  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ));
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

  String validateMainCategoryName(String value) {
    if (value.isEmpty) return "Name cannot be blank.";
    if (value.length < 2) return "Name should be more than two characters.";
    return null;
  }

  saveMainCategoryName(String value) {
    _mainCategoryName = value;
  }

  String validateIntCategoryCode(String value) {
    _intCategoryValidationErrorText = null;
    if (value.isEmpty) {
      _intCategoryValidationErrorText = "Internal Category Code cannot be blank";
    }
    return _intCategoryValidationErrorText;
  }

  saveIntCategoryCode(String value) {
    _selectedIntCategory = value;
  }

  saveAdvertisingText(String value) {
    _advertisingText = value;
  }

  saveDisplaySequence(dynamic value) {
    if (value != null) {
      _displaySequence = value as int;
    }
  }


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

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _)
    {
      final state = watch(mainCategoryViewModelProvider);
      final model = watch(mainCategoryViewModelProvider.notifier);
      _width = MediaQuery
          .of(context)
          .size
          .width;

      populateScreen(MainCategory mainCategory) {
        _mainCategoryId = mainCategory.id;
        mainCategoryEditingController.text = mainCategory.name;
        advertisingTextEditingController.text = mainCategory.advertText;
        _advertisingTextColour = mainCategory.textColor;
        _advertise = mainCategory.advertise == 'Y';
        _selectedIntCategory = mainCategory.type;
        _displaySequence = mainCategory.displaySequence;
        model.populateMainCategory(mainCategory);
        isFormChanged = false;
      }

      initialise() {
        mainCategoryEditingController.clear();
        advertisingTextEditingController.clear();
        _mainCategoryId = null;
        _advertisingTextColour = null;
        _advertise = false;
        _selectedIntCategory = "";
        _intCategoryValidationErrorText = null;
        _mainCategoryName = null;
        _advertisingTextColour = 'White';
        _advertisingText = null;
        _displaySequence = null;
        isFormChanged = false;
        model.initialise();
      }

      saveMainCategory() async {
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
            await model.saveMainProduct(
                id: _mainCategoryId,
                name: _mainCategoryName,
                advertText: _advertisingText,
                advertise: _advertise ? "Y" : "N",
                textColor: _advertisingTextColour,
                type: _selectedIntCategory,
                displaySequence: _displaySequence
            );
          } on Exception catch (e) {
            EasyLoading.dismiss();
            displayMessage(context, e.toString());
            return;
          }

          EasyLoading.dismiss();
          if (state is MainCategoryError) {
            print('State is Error');

            //Error should be handled by ProviderListener.
          }
          else {
            displayMessage(context, "Main Category saved successfully");
            isFormChanged = false;
          }
        }
      }

      Widget buildMainCategoryTypeAhead() {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 75, maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
            child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: mainCategoryEditingController,
                  style: TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [FirstCharUpperTextFormatter()],
                  onSubmitted: (value) async {
                    var mainCategory = await model.getMainCategory(value);
                    if (mainCategory == null) {
                      var confirm = await _asyncConfirmDialog(
                          context: context,
                          header: "New Main Category $value",
                          alertMessage: "Main Category doesn't exist. \nDo you want to create new Main Category?");
                      if (confirm == ConfirmAction.CANCEL) {
                        mainCategoryEditingController.clear();
                        _mainCategoryNameFocus.requestFocus(FocusNode());
                      }
                      else {
                        initialise();
                        mainCategoryEditingController.text = value;
                        _intCatCodeFocusNode.requestFocus(FocusNode());
                      }
                    }
                    else {
                      populateScreen(mainCategory);
                      _intCatCodeFocusNode.requestFocus(FocusNode());
                    }
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                      border: _outlineInputBorder(Colors.grey),
                      enabledBorder: _outlineInputBorder(Colors.orangeAccent),
                      focusedBorder: _outlineInputBorder(Colors.blue),
                      errorBorder: _outlineInputBorder(Colors.red),
                      disabledBorder: _outlineInputBorder(Colors.grey),
                      hintText: "Name",
                      hintStyle: TextStyle(fontSize: 14),
                      labelText: " Name",
                      helperText: "Please type main category name.",
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
                initialise();
                populateScreen(suggestion);
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
        );
      }

      Widget buildAdvertiseTextWidget() {
        return CustomInputFormField(
          textEditingController: advertisingTextEditingController,
          // dbValue: model.brandDescription,
          textInputAction: TextInputAction.next,
          autoFocus: false,
          //focusNode: descriptionFocus,
          enable: true,
          width: _width * 0.95,
          //height: _width * 0.50,
          hintText: "Advertising Text",
          labelText: advertisingTextEditingController.text.isEmpty ? null : "Advertising text",
          helperText: "Text to display on banner.",
          //errorText: storeNameValidationErrorText,
          prefixIcon: Icons.drive_file_rename_outline,
          prefixIconColor: Colors.orange,
          maxLength: 100,
          minLines: 1,
          maxLines: 1,
          //validateFunction: validateDescription,
          onSaveFunction: saveAdvertisingText,
        );
      }

      Widget buildAdvertisingTextColor() {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 77, maxWidth: 397),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
            child: Container(
              width: _width * 0.95,
              child: InputDecorator(
                decoration: InputDecoration(
                    border: _outlineInputBorder(Colors.grey),
                    enabledBorder: _outlineInputBorder(Colors.orangeAccent),
                    focusedBorder: _outlineInputBorder(Colors.blue),
                    errorBorder: _outlineInputBorder(Colors.red),
                    disabledBorder: _outlineInputBorder(Colors.grey),
                    labelText: "Banner Text Colour"),
                child: MainCategoryColorSelection(
                  selectedColor: _advertisingTextColour,
                  onSelectColor: (value) {
                    _advertisingTextColour = value;
                    isFormChanged = true;
                    model.rebuildWidget();
                  },
                ),
              ),
            ),
          ),
        );
      }

      Widget buildAdvertiseYesNo() {
        return Container(
          width: 180,
          child: CheckboxListTile(
            value: _advertise,
            title: Text('Advertise'),
            onChanged: (value) {
              _advertise = value;
              isFormChanged = true;
              model.rebuildWidget();
            },
          ),
        );
      }

      List<DropdownMenuItem<String>> getIntCategoryCodesDropDownItems() {
        List<DropdownMenuItem<String>> items = [];
        items.add(DropdownMenuItem(child: Text(""), value: "",));
        categoryCodes.forEach((element) {
          items.add(DropdownMenuItem(
              child: Text(
                element['name'],
                style: kTextInputStyle,
              ),
              value: element['type']));
        });
        return items;
      }

      List<DropdownMenuItem<int>> getDisplaySequenceDropDownItems() {
        List<int> displaySequences = List.generate(10, (index) => index+1);
        List<DropdownMenuItem<int>> items = [];
        items.add(DropdownMenuItem(child: Text(""), value: null,));
        displaySequences.forEach((element) {
          items.add(DropdownMenuItem(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "$element",
                  style: kTextInputStyle,
                ),
              ),
              value: element));
        });
        return items;
      }


      Widget buildInternalCategoryDropDown() {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 8, right: 1),
          child: CustomDropDownWidget(
            key: _formKey,
            hintText: "Internal Category Code",
            errorText: _intCategoryValidationErrorText,
            helperText: "Please select Internal Category Code.",
            labelText: "Internal Category Code",
            prefixIcon: Icons.qr_code_sharp,
            prefixIconColor: Colors.orange,
            dropDownValues: getIntCategoryCodesDropDownItems(),
            selectedValue: _selectedIntCategory,
            validatorFunction: validateIntCategoryCode,
            setValueFunction: saveIntCategoryCode,
            onChangeFunction: (value) {
              //_formChanged = true;
            },
            width: _width * 0.70,
            height: 67,
            focusNode: _intCatCodeFocusNode,
            enable: true,
          ),
        );
      }

      Widget buildDisplayAdvertisingText() {
        Color textColor;
        if (_advertisingTextColour == 'White') {
          textColor = Colors.white;
        } else if (_advertisingTextColour == "Black") {
          textColor = Colors.black;
        } else if (_advertisingTextColour == "Red") {
          textColor = Colors.red;
        }

        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 30, top: 30, bottom: 20),
            child: Text(
              advertisingTextEditingController.text,
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }

      Widget buildDisplaySequence() {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 8, right: 1),
          child: CustomDropDownWidget(
            key: _formKey,
            hintText: "Display Sequence",
            helperText: "Display Sequence.",
            //labelText: "Display Sequence",
            prefixIconColor: Colors.orange,
            dropDownValues: getDisplaySequenceDropDownItems(),
            selectedValue: _displaySequence,
            setValueFunction: saveDisplaySequence,
            onChangeFunction: (value) {
              //_formChanged = true;
            },
            width: _width * 0.30,
            height: 70,
            focusNode: _intCatCodeFocusNode,
            enable: _advertise,
            validatorFunction: (value){},
            underLineInputBorder: true,
          ),
        );
      }

      Widget buildImageUploadCustomWidget() {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment.center,
                child: ImageUploadWidget(
                  width: _width * 0.95,
                  height: _width * 0.48,
                  enable: mainCategoryEditingController.text.length > 1,
                ),
              ),
              buildDisplayAdvertisingText()
            ],
          ),
        );
      }

      return ProviderListener(
        provider: mainCategoryViewModelProvider,
        onChange: (context, model) {
          if (state is MainCategoryError) {
            displayMessage(context, state.errorMessage);
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Main Category Maintenance"),
              leading: InkWell(
                child: Icon(Icons.arrow_back),
                onTap: () async {
                  if (await canPopScreen(context)) {
                    context.read(mainCategoryViewModelProvider.notifier).initialise();
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                InkWell(
                  onTap: () async {
                    await saveMainCategory();
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
                      buildMainCategoryTypeAhead(),
                      buildInternalCategoryDropDown(),
                      buildAdvertiseTextWidget(),
                      buildAdvertisingTextColor(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildAdvertiseYesNo(),
                          buildDisplaySequence()
                        ],
                      ),
                      buildImageUploadCustomWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
  String formatException(String exception) {
    if (exception.contains("Exception:")) {
      int idx = exception.indexOf("Exception:");
      if (idx >= 0) {
        return exception.substring(idx+"Exception:".length).trim();
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
}

class MainCategoryColorSelection extends StatefulWidget {
  final String selectedColor;
  final Function onSelectColor;

  MainCategoryColorSelection({Key key, this.onSelectColor, this.selectedColor}) : super(key: key);

  @override
  _MainCategoryColorSelectionState createState() => _MainCategoryColorSelectionState(this.selectedColor);
}

class _MainCategoryColorSelectionState extends State<MainCategoryColorSelection> {
  final String selectedColor;

  _MainCategoryColorSelectionState(this.selectedColor);

  String _selectedColor;

  @override
  void initState() {
    _selectedColor = selectedColor;
    if (_selectedColor == null) _selectedColor = 'White';
    super.initState();
  }

  @override
  void didUpdateWidget(MainCategoryColorSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      _selectedColor = widget.selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Passed Color  $_selectedColor");
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio(
                groupValue: _selectedColor,
                value: 'White',
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value;
                    widget.onSelectColor(value);
                  });
                },
              ),
              Container(
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    //boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, spreadRadius: 6,)]

//                  shape: BoxShape.circle
                  )),
            ],
          ),
          Row(
            children: [
              Radio(
                groupValue: _selectedColor,
                value: 'Black',
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value;
                    widget.onSelectColor(value);
                  });
                },
              ),
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 13,
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                groupValue: _selectedColor,
                value: 'Red',
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value;
                    widget.onSelectColor(value);
                  });
                },
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
