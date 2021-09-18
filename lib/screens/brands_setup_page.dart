import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/brands.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/utility/text_input_formatter.dart';
import 'package:subbonline_storeadmin/viewmodels/brands_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';
import 'package:subbonline_storeadmin/widgets/image_upload_widget.dart';

class BrandsPageSetup extends ConsumerWidget {
  static const id = "brand_setup_page";

  File _imageFile;

  String _brandId;

  String _brandLogo;

  String _brandName;

  String _brandDescription;

  bool isFormChanged = false;

  BrandsPageSetup({Key key}) : super(key: key);

  static final _formKey = GlobalKey<FormState>();

  final TextEditingController brandsEditingController = TextEditingController();
  final TextEditingController brandsDescriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final FocusNode descriptionFocus = FocusNode(canRequestFocus: true);
  final FocusNode brandNameFocus = FocusNode(canRequestFocus: true);

  double _width;

  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ));
  }

  bool enableBrandLogo() {
    return true;
  }

  String validateBrandName(String value) {
    if (value.isEmpty) return "Brand Name cannot be blank.";
    if (value.length < 2) return "Brand name should be more than two characters.";
    return null;
  }

  String validateDescription(String value) {
    if (value.isEmpty) return "Please provided some detail about this brand.";
    return null;
  }

  saveBrandName(String value) {
    _brandName = value;
  }

  saveDescription(String value) {
    _brandDescription = value;
  }

  saveBrand(BuildContext context) {
    final model = context.read(brandViewModelProvider.notifier);
    if (!isFormChanged && !model.isImageChanged() ) {
      displayMessage(context, "There is no change to save");
      return;
    }
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

       //model.state = BrandSave(Brands(brandId: ))
      model.saveBrand(
        _brandId,
        _brandName,
        _brandDescription,
      );
      if (model is BrandsError) {
        //displayMessage(context, model.errorMessage);
      } else {
        displayMessage(context, "Brand saved successfully");
        isFormChanged = false;
      }
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

  initialise(BrandsViewModel model) {
    brandsEditingController.clear();
    brandsDescriptionController.clear();
    _brandName = null;
    _brandDescription = null;
    _imageFile = null;
    model.initialise();

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

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    _width = MediaQuery.of(context).size.width;
    print("Width ${_width * 0.95}");
    final state = watch(brandViewModelProvider);
    final model = watch(brandViewModelProvider.notifier);

    populateScreen(Brands brand) {
      brandsEditingController.text = brand.brand;
      brandsDescriptionController.text = brand.description;
      _brandId = brand.brandId;
      model.populateBrand(brand.brandId, brand.brand, brand.description, brand.imageUrl);
      isFormChanged = false;
    }

    Widget buildBrandsTypeAhead() {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 75, maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
          child: TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: brandsEditingController,
                style: TextStyle(fontSize: 14),
                textInputAction: TextInputAction.next,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [FirstCharUpperTextFormatter()],
                focusNode: brandNameFocus,
                onEditingComplete: () async {
                  // print('Check if Product Exists');
                  // await retrieveIfExists(productNameTextController.text);
                  // var nextFocus = _node.nextFocus;
                  // nextFocus.call();
                  // _nextFieldFocus.requestFocus();
                },
                onSubmitted: (value) async {
                  var brand = await model.getBrandByName(value);
                  if (brand == null) {
                    var confirm = await _asyncConfirmDialog(
                        context: context, header: "New Brand $value", alertMessage: "Band doesn't exist. \nDo you want to create new brand?");

                    if (confirm == ConfirmAction.CANCEL) {
                      brandsEditingController.text = null;
                      brandNameFocus.requestFocus(FocusNode());
                    } else {
                      initialise(model);
                      descriptionFocus.requestFocus(FocusNode());
                    }
                  } else {
                    populateScreen(brand);
                    descriptionFocus.requestFocus(FocusNode());
                  }
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                  disabledBorder: _outlineInputBorder(Colors.grey),
                  enabledBorder: _outlineInputBorder(Colors.yellowAccent.withGreen(10).withOpacity(0.18)),
                  focusedErrorBorder: _outlineInputBorder(Colors.redAccent),
                  errorBorder: _outlineInputBorder(Colors.redAccent),
                  focusedBorder: _outlineInputBorder(Colors.blueAccent),
                  hintText: "Brand Name",
                  hintStyle: TextStyle(fontSize: 14),
                  labelText: "Brand Name",
                  helperText: "Please type brand name.",
                  labelStyle: TextStyle(fontSize: 14),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 0.0),
                    child: Icon(
                      Icons.android,
                      size: 18,
                    ),
                  ),
                )),
            suggestionsCallback: (pattern) async {
              return await model.getBrandsSearchedList(pattern, 5);
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
                        '${suggestion.brand}',
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
              initialise(model);
              populateScreen(suggestion);
              //_isProductExist = true;
            },
            keepSuggestionsOnLoading: true,
            hideSuggestionsOnKeyboardHide: true,
            noItemsFoundBuilder: (context) {
              return null;
            },
            validator: validateBrandName,
            onSaved: saveBrandName,
          ),
        ),
      );
    }

    Widget buildDescriptionInput() {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 180, maxWidth: 450),
        child: CustomInputFormField(
          textEditingController: brandsDescriptionController,
          dbValue: model.brandDescription,
          textInputAction: TextInputAction.next,
          autoFocus: false,
          focusNode: descriptionFocus,
          enable: true,
          width: _width * 0.95,
          height: _width * 0.55,
          hintText: "Description",
          labelText: brandsDescriptionController.text.isEmpty ? null : "Description",
          helperText: "Please enter brand detail.",
          //errorText: storeNameValidationErrorText,
          prefixIcon: Icons.drive_file_rename_outline,
          prefixIconColor: Colors.orange,
          maxLength: 200,
          minLines: 6,
          maxLines: 6,
          validateFunction: validateDescription,
          onSaveFunction: saveDescription,
        ),
      );
    }

    Widget buildImageUploadWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0, top: 5, left: 12, right: 1),
            child: OutlinedButton(
                style: TextButton.styleFrom(
                    primary: enableBrandLogo() ? Colors.blue : Colors.grey,
                    side: BorderSide(color: enableBrandLogo() ? Colors.blue : Colors.grey),
                    minimumSize: Size(60, 28),
                    padding: EdgeInsets.all(4)),
                onPressed: enableBrandLogo()
                    ? () async {
                        final _pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                        if (_pickedImage.path != null) {
                          _imageFile = File(_pickedImage.path);
                          _brandLogo = _pickedImage.path;
                          //storeViewModel.buildState();
                          //isFormChanged = true;
                        } else {}
                      }
                    : null,
                child: Text(
                  "Upload Image",
                  style: TextStyle(color: enableBrandLogo() ? Colors.blue : Colors.grey),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5, left: 12, right: 1),
            child: Container(
              constraints: BoxConstraints(maxWidth: 386, maxHeight: 230),
              width: _width * .95,
              height: _width * .70,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: enableBrandLogo() ? Colors.orange.shade300 : Colors.grey.shade500, width: 1.2),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: model.imageUrl != null
                          ? NetworkImage(model.imageUrl)
                          : _imageFile == null
                              ? AssetImage('images/no-image-available.png')
                              : FileImage(_imageFile))),
            ),
          ),
        ],
      );
    }

    Widget buildImageUploadCustomWidget() {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ImageUploadWidget(
          width: _width * 0.95,
          height: _width * 0.65,
          enable: brandsEditingController.text.length > 1,
        ),
      );
    }

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Brands Maintenance"),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () async {
              if (await canPopScreen(context)) {
                context.read(brandViewModelProvider.notifier).initialise();
                Navigator.pop(context);
              }

            },
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              saveBrand(context);
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
        child: ProviderListener(
          provider: brandViewModelProvider.notifier,
          onChange: (context, state) {
            if (state is BrandsError) {
              displayMessage(context, state.errorMessage);
            }
          },
          child: Container(
            child: Form(
              key: _formKey,
              onChanged: () {
                isFormChanged = true;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBrandsTypeAhead(),
                  buildDescriptionInput(),
                  //buildImageUploadWidget(),
                  buildImageUploadCustomWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  displayMessage(BuildContext context, String message) {
    assert(message != null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.lightBlue,
      duration: Duration(milliseconds: 1000),
    ));
  }
}
