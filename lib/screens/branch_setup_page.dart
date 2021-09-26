import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
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
  BranchSetupPageState createState() => BranchSetupPageState();
}

class BranchSetupPageState extends State<BranchSetupPage> with AutomaticKeepAliveClientMixin {
  static final _formKey = GlobalKey<FormState>();

  String branchCodeValidationErrorText;
  String branchNameValidationErrorText;
  String branchAddressValidationErrorText;
  String branchSuburbValidationErrorText;
  String branchCityValidationErrorText;
  String flatChargesValidationErrorText;
  String freeDeliveryValidationErrorText;
  String deliveryThresholdValidationErrorText;


  final TextEditingController branchCodeEditController = TextEditingController();

  final TextEditingController branchNameEditController = TextEditingController();

  final TextEditingController branchAddressEditController = TextEditingController();
  final TextEditingController suburbAboutEditController = TextEditingController();
  final TextEditingController cityAboutEditController = TextEditingController();
  final TextEditingController flatChargesController = TextEditingController();
  final TextEditingController freeDeliveryController = TextEditingController();
  final TextEditingController deliveryThresholdController = TextEditingController();

  StoreUsers loggedInUser;

  double _width;

  bool isRetrieved = false;
  bool isFormChanged = false;

  String _branchCode;
  String _branchName;
  String _branchAddress;
  String _branchSuburb;
  String _city;
  String _status;
  bool storeSelected = false;
  bool _mainBranch = false;
  GeoPoint _geoPoints;
  double _flatCharges;
  double _freeDeliveryAmount;
  double _deliveryThresholdHrs;

  StoreBranch _storeBranch;
  StoreDeliveryCharges _deliveryCharges;

  Future<StoreBranch> branchFuture;

  double _deliveryRange = kDefaultDeliveryRange;



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadFromDB();
    super.initState();
  }

  loadFromDB() async {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    final branchViewModel = context.read(branchViewModelProvider);
    loggedInUser = userLoginViewModel.storeUsers;
    print("loadFromDB");
    if (!isSuperUser(loggedInUser)) {
      branchFuture = branchViewModel.getCurrentBranchId();
      //populateScreen(_storeBranch, branchViewModel);
    }
  }

  initialise() {
    final branchViewModel = context.read(branchViewModelProvider);
    isRetrieved = false;
    isFormChanged = false;
    _branchCode = null;
    _branchName = null;
    _branchAddress = null;
    _branchSuburb = null;
    _city = null;
    _status = null;
    _mainBranch = false;
    _storeBranch = null;
    _flatCharges = null;
    _freeDeliveryAmount = null;
    _deliveryThresholdHrs = null;

    branchCodeEditController.clear();

    branchNameEditController.clear();
    branchAddressEditController.clear();
    suburbAboutEditController.clear();
    cityAboutEditController.clear();
    branchViewModel.initialise();
  }

  bool isSuperUser(StoreUsers user) {
    if (user.roleCode == 99) {
      return true;
    }
    return false;
  }

  Widget buildMainCheckBox() {
    final model = context.read(branchViewModelProvider);
    return Row(
      children: [
        Text("Main Branch"),
        Checkbox(
            value: _mainBranch,
            onChanged: !enableName()
                ? null
                : (value) {
                    setState(() {
                      isFormChanged = true;
                      _mainBranch = value;
                    });
                  }),
      ],
    );
  }

  Widget buildActiveInactiveWidget() {
    final model = context.read(branchViewModelProvider);
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
              } else {
                return;
              }
            } else if (_status == "I") {
              _status = "A";
            }
            isFormChanged = true;
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
    _status = storeBranch.status;
    _mainBranch = storeBranch.mainBranch == "Y";
    _geoPoints = storeBranch.geoPoints;
    _deliveryRange = storeBranch.deliveryRange == null ? kDefaultDeliveryRange : storeBranch.deliveryRange;
    _deliveryCharges =
        storeBranch.storeDeliveryCharges == null ? StoreDeliveryCharges() : storeBranch.storeDeliveryCharges;
    model.branchId = storeBranch.branchId;
    model.name = storeBranch.name;
    model.address = storeBranch.address;
    model.suburb = storeBranch.suburb;
    model.city = storeBranch.city;
    _city = storeBranch.city;
    model.mainBranch = storeBranch.mainBranch;
    model.status = storeBranch.status;
    model.createdDate = storeBranch.createDate;
    model.deliveryRange = _deliveryRange;
    model.flatCharges = storeBranch.storeDeliveryCharges != null ? storeBranch.storeDeliveryCharges.flatCharges : null;
    model.freeDeliveryAmount = storeBranch.storeDeliveryCharges != null ? storeBranch.storeDeliveryCharges.freeDeliveryAmount : null;
    model.deliveryThreshold = storeBranch.deliveryThreshold;

    //model.buildState();
    // setState(() {
    //   _city = storeBranch.city;
    // });
    isFormChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Consumer(builder: ((context, watch, _) {
      final branchViewModel = watch(branchViewModelProvider.notifier);
      storeSelected = branchViewModel.isStoreSelected();
      if (!storeSelected) {
        print("Store is Not Selected");
        initialise();
      }
      populateIfExists(String storeId, String branchId) async {
        _storeBranch = await branchViewModel.getStoreBranch(storeId, branchId);
        if (_storeBranch != null) {
          branchCodeValidationErrorText = null;
          isRetrieved = true;
          populateScreen(_storeBranch, branchViewModel);
        } else {
          if (!isSuperUser(loggedInUser)) {
            setState(() {
              initialise();
              populateScreen(StoreBranch(branchId: (branchId)), branchViewModel);
              branchCodeValidationErrorText = "Branch doesn't exist.";
            });
          }
        }
      }

      return SafeArea(
          child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8),
            child: FutureBuilder<StoreBranch>(
                future: branchFuture,
                builder: (context, snapshot) {
                  print("${snapshot.connectionState} ${snapshot.hasData}");
                  if (snapshot.connectionState != ConnectionState.none &&
                      (!snapshot.hasData && snapshot.connectionState != ConnectionState.done)) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.connectionState != ConnectionState.none && snapshot.hasData) {
                    _storeBranch = snapshot.data;
                    isRetrieved = true;
                    branchFuture = null;
                    populateScreen(_storeBranch, branchViewModel);
                  }

                  return Form(
                    key: _formKey,
                    onChanged: () {
                      isFormChanged = true;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomInputFormField(
                                textEditingController: branchCodeEditController,
                                dbValue: _branchCode,
                                textInputAction: TextInputAction.next,
                                textInputFormatter: [UpperCaseTextFormatter()],
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
                                validateFunction: validateBranchCode,
                                onSaveFunction: saveBranchCode,
                                onFieldSubmittedFunction: () async {
                                  if (branchCodeEditController.text.isNotEmpty && !isRetrieved) {
                                    await populateIfExists(
                                        branchViewModel.getSelectedStoreId(), branchCodeEditController.text);
                                  }
                                }),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                buildMainCheckBox(),
                                buildActiveInactiveWidget(),
                              ],
                            )
                          ],
                        ),
                        Focus(
                          child: CustomInputFormField(
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
                          onFocusChange: (hasFocus) async {
                            if (branchCodeEditController.text.isNotEmpty && !isRetrieved) {
                              await populateIfExists(
                                  branchViewModel.getSelectedStoreId(), branchCodeEditController.text);
                            }
                          },
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
                          width: _width * 0.95,
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
                        CustomDropDownWidget(
                          enable: enableName(),
                          hintText: "City",
                          //helperText: "Select a store.",
                          labelText: "City",
                          selectedValue: _city,
                          width: 210,
                          height: 45,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          dropDownValues: getCitiesDropDown(),
                          setValueFunction: citySave,
                          validatorFunction: validateCity,
                          onChangeFunction: citySave,
                        ),


                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Divider(height: 3, thickness: 3,),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomInputFormField(
                              textEditingController: flatChargesController,
                              dbValue: branchViewModel.flatCharges != null ? branchViewModel.flatCharges.toString() : '0',
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.number,
                              textAlign: TextAlign.end,
                              textInputFormatter: [FilteringTextInputFormatter.digitsOnly],
                              autoFocus: false,
                              enable: true,
                              width: _width * 0.40,
                              hintText: "Flat Charges",
                              labelText: flatChargesController.text.isEmpty ? null : "Flat Charges",
                              helperText:"Flat Delivery charges amount.",
                              errorText: flatChargesValidationErrorText,
                              prefixIcon: Icons.attach_money,
                              prefixIconColor: Colors.orange,
                              maxLength: 6,
                              validateFunction: (value){},
                              onSaveFunction: saveFlatCharges,
                            ),
                            deliveryThresholdHours(branchViewModel)
                          ],
                        ),
                        CustomInputFormField(
                          textEditingController: freeDeliveryController,
                          dbValue: branchViewModel.freeDeliveryAmount != null ? branchViewModel.freeDeliveryAmount.toString() : '0',
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.number,
                          textAlign: TextAlign.end,
                          textInputFormatter: [FilteringTextInputFormatter.digitsOnly],
                          autoFocus: false,
                          enable: true,
                          width: 200,
                          hintText: "Free Delivery >",
                          labelText: freeDeliveryController.text.isEmpty ? null : "Free Delivery >",
                          helperText: "Free delivery amount minimum limit.",
                          errorText: freeDeliveryValidationErrorText,
                          prefixIcon: Icons.attach_money,
                          prefixIconColor: Colors.orange,
                          maxLength: 10,
                          validateFunction: (value){},
                          onSaveFunction: saveFreeDeliveryAmount,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 4, left: 8, right: 8),
                              child: Text(
                                "Delivery Range ${_deliveryRange} Km.",
                                style: kNameTextStyle,
                              ),
                            ),
                            Slider(
                              value: _deliveryRange,
                              min: 0,
                              max: 50,
                              divisions: 10,
                              label: _deliveryRange.toString(),
                              onChanged: !enableName()
                                  ? null
                                  : (double value) {
                                      setState(() {
                                        isFormChanged = true;
                                        _deliveryRange = value;
                                      });
                                    },
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                                textStyle: const TextStyle(fontSize: 14),
                            ),
                            child: const Text("Trading Hours"),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              showBranchTradingHours();
                            },

                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ),
      ));
    }));
  }

  Widget deliveryThresholdHours(BranchViewModel branchViewModel) {
    return CustomInputFormField(
      textEditingController: deliveryThresholdController,
      dbValue: branchViewModel.deliveryThreshold == null?null : branchViewModel.deliveryThreshold.toString(),
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.number,
      textAlign: TextAlign.end,
      textInputFormatter: [FilteringTextInputFormatter.digitsOnly],
      autoFocus: true,
      enable: enableName(),
      width: _width * 0.40,
      hintText: "Delivery Hrs.",
      labelText: deliveryThresholdController.text.isEmpty ? null : "Delivery Hrs.",
      helperText: "Delivery Threshold Hrs.",
      errorText: deliveryThresholdValidationErrorText,
      prefixIcon: Icons.timer_sharp,
      prefixIconColor: Colors.orange,
      maxLength: 3,
      //validateFunction: (){},
      onSaveFunction: saveDeliveryThresholdHours,
    );
  }
  showBranchTradingHours() {
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: BranchScheduleWidget(),
                ),
                SizedBox(height: 50,)
              ],
            ),
          );
        });
  }

  onDeliverChargesChange(double flatCharges, double freeDeliveryAmount) {
    _deliveryCharges = StoreDeliveryCharges(flatCharges: flatCharges, freeDeliveryAmount: freeDeliveryAmount);
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
    if (loggedInUser.roleCode >= 5 && storeSelected && _status != "I") {
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

  String validateBranchCode(String value) {
    if (value.isEmpty) return "Branch code cannot be blank.";
    if (value.length < 4) {
      return "Branch code cannot be less than 4 characters.";
    }
    return null;
  }

  void saveBranchCode(String value) {
    if (value.isNotEmpty) {
      _branchCode = value;
    } else
      _branchCode = null;
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

  void saveFlatCharges(String value) {
    if (value.isNotEmpty) {
      _flatCharges = double.parse(value);
    } else
      _flatCharges = null;
  }
  void saveFreeDeliveryAmount(String value) {
    if (value.isNotEmpty) {
      _freeDeliveryAmount = double.parse(value);
    } else
      _freeDeliveryAmount = null;
  }
  void saveDeliveryThresholdHours(String value) {
    if (value.isNotEmpty) {
      _deliveryThresholdHrs = double.parse(value);
    } else
      _deliveryThresholdHrs = null;
  }



  bool isAddressChanged() {
    if (_storeBranch == null) {
      return true;
    }
    if (_storeBranch.address != _branchAddress || _storeBranch.suburb != _branchSuburb || _storeBranch.city != _city) {
      return true;
    }
    return false;
  }

  Future<bool> saveBranchInformation() async {
    if (!isFormChanged) {
      //displayMessage(context, "No changes to save");
    } else if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final model = context.read(branchViewModelProvider);
      model.branchId = _branchCode;
      model.name = _branchName;
      model.address = _branchAddress;
      model.suburb = _branchSuburb;
      model.city = _city;
      model.status = _status;
      if (_mainBranch) {
        model.mainBranch = "Y";
      } else {
        model.mainBranch = "N";
      }
      model.updateBranchTimings();
      model.branchTimings = model.getBranchTimings();
      if (model.createdDate == null) {
        model.createdDate = DateTime.now();
      }
      print("Deliver Range $_deliveryRange");
      model.deliveryRange = _deliveryRange;

      if (_geoPoints == null || isAddressChanged()) {
        String _address =
            branchAddressEditController.text + " " + suburbAboutEditController.text + " " + _city + " , " + "Pakistan";
        List<Location> locations;
        try {
          locations = await model.verifyAddress(_address);
        } on Exception catch (e) {
          displayMessage(context, model.errorMessage);
          return false;
        }
        if (locations != null && locations.isNotEmpty) {
          _geoPoints = GeoPoint(locations.first.latitude, locations.first.longitude);
          for (var location in locations) {
            var addresses = await model.getAddressFromGeoCodes(location);
            if (addresses.isNotEmpty) {
              for (var address in addresses) {
                print("Address ${address.toString()}");
              }
            }
          }
        }
      }
      model.geoPoints = _geoPoints;
      model.flatCharges = _flatCharges;
      model.freeDeliveryAmount = _freeDeliveryAmount;
      model.deliveryThreshold = _deliveryThresholdHrs;
      bool _isSave = await model.branchSave();
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
}
