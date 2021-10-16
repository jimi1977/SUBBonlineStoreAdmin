import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/shelf.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/utility/text_input_formatter.dart';
import 'package:subbonline_storeadmin/viewmodels/branch_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';

import '../constants.dart';

import '../viewmodels/user_login_view_model.dart';

class StoreSetupPage extends StatefulWidget {
  static const id = "store_setup_page";



  StoreSetupPage({Key key}) : super(key: key);

  @override
  StoreSetupPageState createState() => StoreSetupPageState();
}

class StoreSetupPageState extends State<StoreSetupPage> with AutomaticKeepAliveClientMixin {
  String storeCodeValidationErrorText;

  String storeNameValidationErrorText;

  String storeAboutValidationErrorText;

  static final _formKey = GlobalKey<FormState>();

  final TextEditingController storeCodeEditController = TextEditingController();

  final TextEditingController storeNameEditController = TextEditingController();

  final TextEditingController storeAboutEditController = TextEditingController();

  FocusNode nameFocusNode;

  final ImagePicker _picker = ImagePicker();

  double _width;

  File _imageFile;
  String _storeLogo;

  Store _store;

  bool bEdit = false;
  bool bInsert = false;
  bool isRetrieved = false;
  bool isFormChanged = false;

  StoreUsers loggedInUser;

  String _storeName;

  String _aboutStore;

  @override
  Future<void> initState() {
    loadFromDB();
    nameFocusNode = FocusNode();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    nameFocusNode.dispose();
  }

  initialise(BuildContext context) {
    final storeViewModel = context.read(storeViewModelProvider);
    _storeName = null;
    _aboutStore = null;
    _imageFile = null;
    _storeLogo = null;
    isRetrieved = false;
    storeNameEditController.clear();
    storeAboutEditController.clear();
    storeViewModel.initialise();
    storeViewModel.buildState();
    isFormChanged = false;
  }

  bool enableStoreCode() {
    if (loggedInUser.roleCode >= 99) {
      return true;
    } else
      return false;
  }

  bool enableName() {
    if (bInsert || loggedInUser.roleCode >= 4) {
      return true;
    } else
      return false;
  }

  bool enableAboutStore() {
    if (bInsert || loggedInUser.roleCode >= 4) {
      return true;
    } else
      return false;
  }

  bool enableStoreLogo() {
    if (bInsert || loggedInUser.roleCode >= 4) {
      return true;
    } else
      return false;
  }

  bool isSuperUser(StoreUsers user) {
    if (user.roleCode == 99) {
      return true;
    }
    return false;
  }

  loadFromDB() async {
    final storeViewModel = context.read(storeViewModelProvider);
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    loggedInUser = userLoginViewModel.storeUsers;
    if (!isSuperUser(loggedInUser)) {
      _store = await storeViewModel.getMyStore();
      populateScreen(_store, storeViewModel);
    }
  }

  populateScreen(Store store, StoreViewModel model) {
    storeCodeEditController.text = store.storeCode;
    storeNameEditController.text = store.store;
    storeAboutEditController.text = store.aboutStore;

    model.setStoreId(store.storeCode);
    model.setName(store.store);
    model.setAboutStore(store.aboutStore);
    model.setStatus(store.status);
    model.setStoreLogo(store.storeLogo);
    model.setCreatedDate(store.createDate);
    setState(() {
      isFormChanged = false;
    });
  }

  String validateStoreName(String value) {
    if (value.isEmpty) return "Store name cannot be blank.";
    return null;
  }

  void saveStoreName(String value) {
    if (value.isNotEmpty) {
      _storeName = value;
    } else
      _storeName = null;
  }

  void saveAboutStore(String value) {
    if (value.isNotEmpty) {
      _aboutStore = value;
    } else
      _aboutStore = null;
  }


  Future<bool> saveStoreInformation() async {
    if (!isFormChanged) {
      //displayMessage(context, "No changes to save");
    }
    else if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final model = context.read(storeViewModelProvider);
      model.setName(_storeName);
      model.setAboutStore(_aboutStore);
      model.setImageFile(_imageFile);
      //model.setStoreLogo(_storeLogo);
      model.setImageFile(_imageFile);

      if (model.getStatus() == null) {
        model.setStatus("A");
      }
      if (model.getCreateDate() == null) {
        model.setCreatedDate(DateTime.now());
      }
      bool _isSave = await model.saveStore();
      if (!_isSave) {
        displayMessage(context, "${model.errorMessage}");
        return false;
      }
    }
    isFormChanged = false;
    return true;
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

  @override
  bool get wantKeepAlive => true;

  Widget buildStatus(String status) {
    return Text(
      "${status == "A" ? "Active" : "Inactive"}",
      style: status == "A" ? k14BoldBlue : k14BoldGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _width = MediaQuery.of(context).size.width;

    return Consumer(
      builder: ((context, watch, _) {
        final storeViewModel = watch(storeViewModelProvider);
        final branchViewModel = context.read(branchViewModelProvider);
        //branchViewModel.initialise();
        populateIfExists(String storeId) async {
          Store _store = await storeViewModel.getStoreById(storeId);
          if (_store != null) {
            isRetrieved = true;
            populateScreen(_store, storeViewModel);
          } else {
            initialise(context);
          }
          nameFocusNode.requestFocus();
        }

        return SafeArea(
            child: Scaffold(
          // floatingActionButton: FloatingActionButton(
          //     elevation: 3,
          //     splashColor: Colors.orangeAccent,
          //     isExtended: true,
          //     onPressed: () {
          //       saveStoreInformation();
          //     },
          //     //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          //     child: Icon(Icons.save),
          //     backgroundColor: Colors.deepOrange),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Form(
                  onWillPop: () {
                    storeViewModel.initialise();
                    return Future.value(true);
                  },
                  onChanged: () {
                    isFormChanged = true;
                  },
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomInputFormField(
                              textEditingController: storeCodeEditController,
                              dbValue: storeViewModel.getStoreId(),
                              textInputAction: TextInputAction.next,
                              textInputFormatter: [UpperCaseTextFormatter()],
                              autoFocus: true,
                              enable: enableStoreCode(),
                              width: _width * 0.40,
                              hintText: "Store Code",
                              labelText: storeCodeEditController.text.isEmpty ? null : "Store Code",
                              helperText: "Please enter store code.",
                              errorText: storeCodeValidationErrorText,
                              prefixIcon: Icons.account_balance_outlined,
                              prefixIconColor: Colors.orange,
                              maxLength: 6,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8) ,
                              onChangeFunction: (value) {
                                isRetrieved = false;
                              },
                              onFieldSubmittedFunction: () async {
                                if (storeCodeEditController.text.isNotEmpty && !isRetrieved) {
                                  populateIfExists(storeCodeEditController.text);
                                }
                                return;
                              }),
                          if (storeViewModel.getStatus() != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildStatus(storeViewModel.getStatus()),
                            ),
                        ],
                      ),
                      Focus(
                        child: CustomInputFormField(
                          textEditingController: storeNameEditController,
                          dbValue: storeViewModel.getStoreName(),
                          textInputAction: TextInputAction.next,
                          autoFocus: true,
                          focusNode: nameFocusNode,
                          enable: enableName(),
                          width: _width * 0.95,
                          hintText: "Name",
                          labelText: storeNameEditController.text.isEmpty ? null : "Name",
                          helperText: "Please enter store name.",
                          errorText: storeNameValidationErrorText,
                          prefixIcon: Icons.drive_file_rename_outline,
                          prefixIconColor: Colors.orange,
                          maxLength: 60,
                          validateFunction: validateStoreName,
                          onSaveFunction: saveStoreName,
                        ),
                        onFocusChange: (hasFocus) async {
                          if (hasFocus && !isRetrieved && storeCodeEditController.text.isNotEmpty) {
                            await populateIfExists(storeCodeEditController.text);
                          }
                        },
                      ),
                      CustomInputFormField(
                        textEditingController: storeAboutEditController,
                        dbValue: storeViewModel.getAboutStore(),
                        textInputAction: TextInputAction.next,
                        autoFocus: true,
                        enable: enableAboutStore(),
                        width: _width * 0.95,
                        height: 120,
                        hintText: "About Store",
                        labelText: storeAboutEditController.text.isEmpty ? null : "About Store",
                        helperText: "Please enter some details about store.",
                        errorText: storeAboutValidationErrorText,
                        prefixIcon: Icons.add_business_outlined,
                        prefixIconColor: Colors.orange,
                        maxLength: 150,
                        minLines: 6,
                        maxLines: 6,
                        onSaveFunction: saveAboutStore,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
                            child: Container(
                              width: _width * .30,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: enableStoreLogo() ? Colors.orange.shade300 : Colors.grey.shade500,
                                      width: 1.2),
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: storeViewModel.getStoreLogo() != null
                                          ? NetworkImage(storeViewModel.getStoreLogo())
                                          : _imageFile == null
                                              ? AssetImage('images/no-image-available.png')
                                              : FileImage(_imageFile))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: OutlinedButton(
                                style: TextButton.styleFrom(
                                    primary: enableStoreLogo() ? Colors.blue : Colors.grey,
                                    side: BorderSide(color: enableStoreLogo() ? Colors.blue : Colors.grey),
                                    minimumSize: Size(60, 28),
                                    padding: EdgeInsets.all(4)),
                                onPressed: enableStoreLogo()
                                    ? () async {
                                        final _pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                        if (_pickedImage.path != null) {
                                          _imageFile = File(_pickedImage.path);
                                          _storeLogo = _pickedImage.path;
                                          storeViewModel.buildState();
                                          isFormChanged = true;
                                        } else {
                                        }
                                      }
                                    : null,
                                child: Text(
                                  "Upload Image",
                                  style: TextStyle(color: enableStoreLogo() ? Colors.blue : Colors.grey),
                                )),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ));
      }),
    );
  }
}
