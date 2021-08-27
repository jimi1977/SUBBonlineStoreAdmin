import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/repository/cities_repository.dart';
import 'package:subbonline_storeadmin/viewmodels/branch_view_model.dart';
import 'package:subbonline_storeadmin/widgets/branch_schedule.dart';

import '../constants.dart';
import '../enums/enum_confirmation.dart';
import '../models/store.dart';
import '../models/strore_users.dart';
import '../utility/text_input_formatter.dart';
import '../utility/utility_functions.dart';
import '../viewmodels/user_login_view_model.dart';
import '../widgets/custom_form_input_field.dart';

class BranchSetupPage extends StatefulWidget {
  const BranchSetupPage({Key key}) : super(key: key);

  @override
  _BranchSetupPageState createState() => _BranchSetupPageState();
}

class _BranchSetupPageState extends State<BranchSetupPage> {
  static final _formKey = GlobalKey<FormState>();

  String branchCodeValidationErrorText;
  String branchNameValidationErrorText;
  String branchAddressValidationErrorText;
  String branchSuburbValidationErrorText;
  String branchCityValidationErrorText;

  final TextEditingController branchCodeEditController = TextEditingController();

  final TextEditingController branchNameEditController = TextEditingController();

  final TextEditingController branchAddressEditController = TextEditingController();
  final TextEditingController suburbAboutEditController = TextEditingController();
  final TextEditingController cityAboutEditController = TextEditingController();

  StoreUsers loggedInUser;

  double _width;

  bool isRetrieved = false;

  String _branchName;
  String _branchAddress;
  String _branchSuburb;
  String _city;
  String _status;
  bool _mainBranch = false;
  bool storeSelected = false;

  StoreBranch _storeBranch;

  @override
  void initState() {
    loadFromDB();
    super.initState();
  }

  loadFromDB() async {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    final branchViewModel = context.read(branchViewModelProvider);
    loggedInUser = userLoginViewModel.storeUsers;
    if (!isSuperUser(loggedInUser)) {
      _storeBranch  = await branchViewModel.getCurrentBranchId();
      populateScreen(_storeBranch, branchViewModel);
    }
  }

  bool isSuperUser(StoreUsers user) {
    if (user.roleCode == 99) {
      return true;
    }
    return false;
  }

  Widget buildMainCheckBox(BranchViewModel model) {
    return Row(
      children: [
        Text("Main Branch"),
        Checkbox(
            value: model.mainBranch == "Y",
            onChanged: !enableName() ? null :  (value) {
              setState(() {
                if (value) {
                  model.mainBranch = "Y";
                }
                else {
                  model.mainBranch = "N";
                }
              });
            }),
      ],
    );
  }

  Widget buildActiveInactiveWidget(BranchViewModel model) {
    return Row(
      children: [
        Text("${_status == "A" ? "Active" : "Inactive"}"),
        Switch(
          value: _status == "A",
          onChanged: (value) async {
            if (!enableName()) return;
             if (!value) {
               var _confirm = await _asyncConfirmDialog(
                context: context,
                header: "Inactivate Branch",
                alertMessage: "Are you sure that you want to Inactivate this branch?");
               if (_confirm == ConfirmAction.CONFIRM) {
                  _status = "I";
               }
             } else if (_status == "I") {
               _status = "A";
             }
             model.buildState();

          },
        )
      ],
    );
  }

  List<Widget> buildStoreTimings() {
    var weekDays = getDaysOfWeek();
    return List.generate(weekDays.length, (index) {
      return Row(
        children: [
          SizedBox(width: 100, child: Text("${weekDays[index]}")),
          ConstrainedBox(
            constraints: BoxConstraints.tight(Size(60, 30)),
            child: Switch(splashRadius: 15, value: true, onChanged: (value) {}),
          )
        ],
      );
    });
  }

  List<DropdownMenuItem<String>> getCitiesDropDown() {
    List<DropdownMenuItem<String>> items = [];
    cities.forEach((city) {
      items.add(DropdownMenuItem(
        child: Text("$city"),
        value: city,
      ));
    });
    return items;
  }

  populateScreen(StoreBranch storeBranch, BranchViewModel model) {
    branchCodeEditController.text = storeBranch.branchId;
    branchNameEditController.text = storeBranch.name;
    branchAddressEditController.text = storeBranch.address;
    suburbAboutEditController.text = storeBranch.suburb;
    cityAboutEditController.text = storeBranch.city;
    _mainBranch = storeBranch.mainBranch == "Y";
    _status = storeBranch.status;

    model.branchId = storeBranch.branchId;
    model.name = storeBranch.name;
    model.address = storeBranch.address;
    model.suburb = storeBranch.suburb;
    model.city = storeBranch.city;
    _city = storeBranch.city;
    print("Branch City ${storeBranch.city}" );
    model.mainBranch = storeBranch.mainBranch;
    model.status = storeBranch.status;
    model.createdDate = storeBranch.createDate;
    model.buildState();
    // setState(() {
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Consumer(builder: ((context, watch, _) {
      final branchViewModel = watch(branchViewModelProvider);
      storeSelected = branchViewModel.isStoreSelected();

      populateIfExists(String storeId, String branchId) async {
        print("Branch retrieve $storeId $branchId ");
        _storeBranch = await branchViewModel.getStoreBranch(storeId, branchId);
        if (_storeBranch != null) {
          isRetrieved = true;
          populateScreen(_storeBranch, branchViewModel);
        }
      }

      return SafeArea(
          child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomInputFormField(
                          textEditingController: branchCodeEditController,
                          dbValue: branchViewModel.branchId,
                          textInputAction: TextInputAction.next,
                          textInputFormatter: UpperCaseTextFormatter(),
                          autoFocus: true,
                          enable: enableBranchCode(),
                          width: _width * 0.40,
                          hintText: "Branch Code",
                          labelText: branchCodeEditController.text.isEmpty ? null : "Branch Code",
                          helperText: "Please enter store code.",
                          errorText: branchCodeValidationErrorText,
                          prefixIcon: Icons.account_balance_outlined,
                          prefixIconColor: Colors.orange,
                          maxLength: 10,
                          onChangeFunction: (value) {
                            isRetrieved = false;
                          },
                          onFieldSubmittedFunction: () async {
                            if (branchCodeEditController.text.isNotEmpty && !isRetrieved) {
                              await populateIfExists(
                                  branchViewModel.getSelectedStoreId(), branchCodeEditController.text);
                            }
                          }),
                      buildActiveInactiveWidget(branchViewModel)
                    ],
                  ),
                  CustomInputFormField(
                    textEditingController: branchNameEditController,
                    dbValue: branchViewModel.name,
                    textInputAction: TextInputAction.next,
                    autoFocus: true,
                    enable: enableName(),
                    width: _width * 0.95,
                    hintText: "Name",
                    labelText: branchNameEditController.text.isEmpty ? null : "Name",
                    helperText: "Please enter branch name.",
                    errorText: branchNameValidationErrorText,
                    prefixIcon: Icons.drive_file_rename_outline,
                    prefixIconColor: Colors.orange,
                    maxLength: 60,
                    validateFunction: validateBranchName,
                    onSaveFunction: saveBranchName,
                  ),
                  CustomInputFormField(
                    textEditingController: branchAddressEditController,
                    dbValue: branchViewModel.address,
                    textInputAction: TextInputAction.next,
                    autoFocus: true,
                    enable: enableName(),
                    width: _width * 0.95,
                    hintText: "Address",
                    labelText: branchAddressEditController.text.isEmpty ? null : "Address",
                    helperText: "Please enter branch street address.",
                    errorText: branchAddressValidationErrorText,
                    prefixIcon: Icons.location_pin,
                    prefixIconColor: Colors.orange,
                    maxLength: 60,
                    validateFunction: validateAddressName,
                    onSaveFunction: saveBranchAddress,
                  ),
                  CustomInputFormField(
                    textEditingController: suburbAboutEditController,
                    dbValue: branchViewModel.name,
                    textInputAction: TextInputAction.next,
                    autoFocus: true,
                    enable: enableName(),
                    width: _width * 0.50,
                    hintText: "Area/Suburb",
                    labelText: suburbAboutEditController.text.isEmpty ? null : "Area/Suburb",
                    helperText: "Please enter branch area.",
                    errorText: branchSuburbValidationErrorText,
                    prefixIcon: Icons.location_pin,
                    prefixIconColor: Colors.orange,
                    maxLength: 30,
                    validateFunction: validateSuburb,
                    onSaveFunction: saveSuburbAddress,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomDropDownWidget(
                        enable: enableName(),
                        hintText: "City",
                        //helperText: "Select a store.",
                        labelText: "City",
                        selectedValue: _city,
                        width: 180,
                        height: 45,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        dropDownValues: getCitiesDropDown(),
                        setValueFunction: citySave,
                        validatorFunction: validateCity,
                        onChangeFunction: citySave,
                      ),
                      buildMainCheckBox(branchViewModel),
                    ],
                  ),
                  BranchScheduleWidget()
                ],
              ),
            ),
          ),
        ),
      ));
    }));
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

  bool enableBranchCode() {
    if (loggedInUser.roleCode >= 99 && storeSelected && _status != "I") {
      return true;
    } else
      return false;
  }

  bool enableName() {
    if (loggedInUser.roleCode >= 4 && storeSelected && _status != "I") {
      return true;
    } else
      return false;
  }

  String validateBranchName(String value) {
    if (value.isEmpty) return "Branch name cannot be blank.";
    return null;
  }

  void saveBranchName(String value) {
    if (value.isNotEmpty) {
      _branchName = value;
    } else
      _branchName = null;
  }

  String validateAddressName(String value) {
    if (value.isEmpty) return "Branch Address cannot be blank.";
    return null;
  }

  void saveBranchAddress(String value) {
    if (value.isNotEmpty) {
      _branchAddress = value;
    } else
      _branchAddress = null;
  }

  String validateSuburb(String value) {
    if (value.isEmpty) return "Branch Address Area/Suburb cannot be blank.";
    return null;
  }

  void saveSuburbAddress(String value) {
    if (value.isNotEmpty) {
      _branchSuburb = value;
    } else
      _branchSuburb = null;
  }

  String validateCity(dynamic value) {
    if (value == null) {
      branchCityValidationErrorText = "City cannot be empty.";

      return branchCityValidationErrorText;
    } else if (branchCityValidationErrorText != null) {
      setState(() {
        branchCityValidationErrorText = null;
      });
    }
    return null;
  }

  citySave(dynamic value) {
    if (value.isNotEmpty) {
      _city = value;
    }
  }
}
