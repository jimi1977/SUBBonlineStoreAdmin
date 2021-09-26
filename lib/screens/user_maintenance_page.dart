import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/repository/user_level_repository.dart';
import 'package:subbonline_storeadmin/screens/user_list_page.dart';
import 'package:subbonline_storeadmin/utility/text_input_formatter.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';
import 'package:subbonline_storeadmin/viewmodels/user_login_view_model.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';
import 'package:subbonline_storeadmin/widgets/store_branch_selection_widget.dart';

class UserMaintenancePage extends StatefulWidget {
  static const id = "user_maintenance_page";

  const UserMaintenancePage({Key key}) : super(key: key);

  @override
  _UserMaintenancePageState createState() => _UserMaintenancePageState();
}

class _UserMaintenancePageState extends State<UserMaintenancePage> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();
  double _width;
  var _currentIndex = 0;

  var _selectedRole;

  StoreUsers user;
  String _userId;
  String _userName;
  String _roleValidationErrorText;
  String userValidationErrorText;
  String _status;
  DateTime _dateCreated;
  DateTime _dateInactivated;

  StoreUsers loggedInUser;

  bool _isProcessing = false;
  bool userRetrieved = false;
  bool _formChanged = false;

  List<DropdownMenuItem<int>> getUserLevelDropDownItems() {
    List<DropdownMenuItem<int>> items = [];
    //items.add(DropdownMenuItem(child: Text(""), value: null,));
    userLevels.forEach((element) {
      items.add(DropdownMenuItem(
          child: Visibility(
            visible: element['level'] as int < 99 || loggedInUser.roleCode == 99,
            child: Text(
              element['name'],
              style: kTextInputStyle,
            ),
          ),
          value: element['level']));
    });
    if (loggedInUser.roleCode == 99) {}
    return items;
  }

  @override
  void initState() {
    initialise();
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    _storeId = userLoginViewModel.getStoreId();
    _branchId = userLoginViewModel.getBranchId();
    loggedInUser = userLoginViewModel.storeUsers;

    if (loggedInUser.roleCode < 99) {
      user = loggedInUser;
      populateUserScreen(loggedInUser);
    }

    super.initState();
  }

  bool allowUserList() {
    if (loggedInUser.roleCode >= 3) {
      return true;
    }
    return false;
  }

  bool allowUserIdChange() {
    if ((loggedInUser.roleCode >= 3 && (user != null && loggedInUser.uid != user.uid)) || loggedInUser.roleCode == 99) {
      return true;
    }
    return false;
  }

  bool allowUserNameChange() {
    if (loggedInUser.roleCode >= 3) {
      return true;
    }
    return false;
  }

  bool allowUserRoleChange() {
    if (loggedInUser.roleCode >= 3 && (user != null && loggedInUser.uid != user.uid)) {
      return true;
    }
    return false;
  }

  bool allowInactivateUser() {
    if (loggedInUser.roleCode >= 3 && (user != null && loggedInUser.uid != user.uid) && _status != "I") {
      return true;
    }
    return false;
  }

  bool allowResetPassword() {
    if (loggedInUser.roleCode >= 3 && _status != "I" || (user != null && loggedInUser.uid == user.uid)) {
      return true;
    }
    return false;
  }

  bool enableSaveButton() {
    if (_status != "I") {
      return true;
    }
    return false;
  }
  bool isSuperUser(StoreUsers user) {
    if (user.roleCode == 99) {
      return true;
    }
    return false;
  }

  initialise() {
    user = StoreUsers();
    _userId = null;
    _userName = null;
    _selectedRole = null;
    _roleValidationErrorText = null;
    userValidationErrorText = null;
    _status = null;
    _dateCreated = null;
    _dateInactivated = null;
    _formChanged = false;
    userRetrieved = false;
    //setState(() {});
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

  String _storeId;
  String _branchId;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;

    CustomDropDownWidget roleDropDown = CustomDropDownWidget(
      key: _formKey,
      hintText: "User Level",
      errorText: _roleValidationErrorText,
      helperText: "Please select user level.",
      prefixIcon: Icons.account_circle_outlined,
      prefixIconColor: Colors.orange,
      dropDownValues: getUserLevelDropDownItems(),
      selectedValue: _selectedRole,
      validatorFunction: validateUserRole,
      setValueFunction: userRoleSave,
      onChangeFunction: (value) {
        _formChanged = true;
      },
      width: _width * 0.70,
      focusNode: _node.enclosingScope,
      enable: _status != "I" && allowUserRoleChange(),
    );

    void initialiseForm() {
      userIdController.clear();
      userNameController.clear();
    }

    final storeSelectionConsumer = SliverToBoxAdapter(
      child: Consumer(builder: (context, watch, _) {
        final storeBranchSelectionModel = watch(storeBranchSelectionProvider.notifier);
        print("Consumer Build...");
        if (storeBranchSelectionModel.storeId != _storeId || storeBranchSelectionModel.branchId != _branchId) {
          _storeId = storeBranchSelectionModel.storeId;
          _branchId = storeBranchSelectionModel.branchId;
          Future.delayed(
              Duration(
                milliseconds: 5,
              ), () {
            initialise();
            initialiseForm();
          });
        }

        return Container();
      }),
    );
    return SafeArea(
        child: _isProcessing
            ? showProgressIndicator()
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: Text("User Maintenance"),
                  centerTitle: true,
                  leading: InkWell(
                      onTap: () async {
                        if (await canPopScreen(context)) {
                          Navigator.pop(context);
                        } else {
                          return;
                        }
                      },
                      child: Icon(Icons.arrow_back_ios)),
                  actions: [
                    Visibility(
                      visible: allowUserList(),
                      child: InkWell(
                          splashColor: Colors.deepOrange,
                          child: IconButton(
                            icon: Icon(
                              Icons.list,
                              size: 30,
                            ),
                            splashColor: Colors.deepOrange,
                            splashRadius: 24,
                            onPressed: () async {
                              user = await Navigator.pushNamed(context, UsersListPage.id);
                              if (user != null) {
                                setState(() {
                                  populateUserScreen(user);
                                });
                              }
                            },
                          )),
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  splashColor: Colors.orangeAccent,
                  elevation: 3,
                  //mini: true,

                  onPressed: () async {
                    if (_formChanged) {
                      if (await _asyncConfirmDialog(
                              context: context,
                              header: "Cancel Change",
                              alertMessage: "Are you sure you want to cancel changes?") !=
                          ConfirmAction.CONFIRM) {
                        return;
                      }
                    }
                    initialise();
                    initialiseForm();
                  },
                  backgroundColor: Colors.deepOrange,
                  child: const Icon(Icons.add),
                  tooltip: 'Create',
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                bottomNavigationBar: BottomAppBar(
                  elevation: 2,
                  color: Colors.orangeAccent,
                  shape: CircularNotchedRectangle(),
                  child: Row(
                    children: [
                      IconButton(
                          disabledColor: Colors.grey,
                          splashRadius: 24,
                          splashColor: Colors.deepOrange,
                          tooltip: 'In Activate user.',
                          icon: Icon(
                            Icons.person_add_disabled_outlined,
                            color: !allowInactivateUser() ? Colors.grey : Colors.white,
                          ),
                          onPressed: !allowInactivateUser()
                              ? null
                              : () {
                                  inActivateUser(context);
                                }),
                      Text(
                        "Inactivate",
                        style: TextStyle(color: !allowInactivateUser() ? Colors.grey : Colors.white),
                      ),
                      //Spacer(),

                      IconButton(
                          tooltip: 'Reset Password',
                          splashRadius: 24,
                          splashColor: Colors.deepOrange,
                          icon: Icon(
                            Icons.engineering,
                            color: !allowResetPassword() ? Colors.grey : Colors.white,
                          ),
                          onPressed: !allowResetPassword()
                              ? null
                              : () {
                                  //Reset Password
                                  resetUserPassword(context, user);
                                }),
                      Text(
                        "Reset Password",
                        style: TextStyle(color: _status == "I" ? Colors.grey : Colors.white),
                      ),
                    ],
                  ),
                ),
                body: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Visibility(
                          visible: isSuperUser(loggedInUser),
                          child: StoreBranchSelectionWidget()),
                    ),
                    storeSelectionConsumer,
                    SliverToBoxAdapter(
                      child: Container(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomInputFormField(
                                      hintText: "User Id",
                                      labelText: "User Id",
                                      helperText: "Please enter user id.",
                                      errorText: userValidationErrorText,
                                      prefixIcon: Icons.account_box,
                                      prefixIconColor: Colors.orange,
                                      textEditingController: userIdController,
                                      textInputAction: TextInputAction.next,
                                      textInputFormatter: [LowerCaseTextFormatter()],
                                      maxLength: 40,
                                      autoFocus: true,
                                      enable: _status != "I" && allowUserIdChange(),
                                      width: _width * 0.60,
                                      onChangeFunction: (value) {
                                        if (value != null) {
                                          _formChanged = true;
                                          _userId = value.toString().toLowerCase();
                                        }

                                        //_formChanged = true;
                                      },
                                      validateFunction: validateUserId,
                                      onSaveFunction: userIdSave,
                                      onFieldSubmittedFunction: () async {
                                        final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
                                        user = await userLoginViewModel.getUserById(
                                            storeId: _storeId, branchId: _branchId, userId: userIdController.text);
                                        if (user != null) {
                                          setState(() {
                                            userRetrieved = true;
                                            userValidationErrorText = null;
                                            populateUserScreen(user);
                                            _formChanged = false;
                                          });
                                        }
                                      },
                                    ),
                                    if (_status != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 0),
                                        child: Text(
                                          "${_status == "A" ? "Active" : "Inactive"}",
                                          style: _status == "A" ? k14BoldBlue : k14BoldRed,
                                        ),
                                      ),
                                  ],
                                ),
                                CustomInputFormField(
                                  hintText: "Name",
                                  labelText: "Name",
                                  helperText: "Please enter user name.",
                                  prefixIcon: Icons.drive_file_rename_outline,
                                  prefixIconColor: Colors.orange,
                                  textEditingController: userNameController,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 25,
                                  autoFocus: false,
                                  enable: _status != "I" && allowUserNameChange(),
                                  width: _width * 0.95,
                                  validateFunction: validateUserName,
                                  onSaveFunction: userNameSave,
                                  onChangeFunction: (value) {
                                    if (value != null) {
                                      _formChanged = true;
                                      _userName = value;
                                    }
                                  },
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,

                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: roleDropDown,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if (_dateCreated != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                FittedBox(
                                                  child: Text(
                                                    "Creation Date:",
                                                    style: kNameTextStyle,
                                                    softWrap: true,
                                                  ),
                                                  fit: BoxFit.scaleDown,
                                                ),
                                                SizedBox(width: 10,),
                                                Text("${formatDateTimeDDMMYYYYString(_dateCreated)}")
                                              ],
                                            ),
                                          if (_dateInactivated != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "InActivation Date:",
                                                  style: kNameTextStyle,
                                                ),
                                                SizedBox(width: 10,),
                                                Text("${formatDateTimeDDMMYYYYString(_dateInactivated)}")
                                              ],
                                            )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    children: [
                                      ButtonBar(
                                        children: [
                                          RawMaterialButton(
                                            elevation: 1,
                                            hoverElevation: 3,
                                            focusElevation: 3,
                                            fillColor: Colors.blue,
                                            padding: EdgeInsets.all(4),
                                            constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
                                            shape: RoundedRectangleBorder(
                                                side:
                                                    BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid),
                                                borderRadius: BorderRadius.all(Radius.circular(4))),
                                            child: Text("Save",
                                                style: !enableSaveButton() ? kTextInputStyleGrey : kTextInputStyle),
                                            onPressed: !enableSaveButton()
                                                ? null
                                                : () {
                                                    saveUserDetails(context);
                                                  },
                                          ),
                                          RawMaterialButton(
                                            elevation: 1,
                                            hoverElevation: 3,
                                            focusElevation: 3,
                                            fillColor: Colors.blue,
                                            padding: EdgeInsets.all(4),
                                            constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
                                            shape: RoundedRectangleBorder(
                                                side:
                                                    BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid),
                                                borderRadius: BorderRadius.all(Radius.circular(4))),
                                            child: Text(
                                              "Clear",
                                              style: kTextInputStyle,
                                            ),
                                            onPressed: () async {
                                              print("_formChanged $_formChanged");
                                              if (_formChanged) {
                                                if (await _asyncConfirmDialog(
                                                        context: context,
                                                        header: "Cancel Change",
                                                        alertMessage: "Are you sure you want to cancel changes?") ==
                                                    ConfirmAction.CONFIRM) {
                                                  initialise();
                                                  initialiseForm();
                                                  setState(() {});
                                                }
                                              } else {
                                                initialise();
                                                initialiseForm();
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ));
  }

  Widget showProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }

  void populateUserScreen(StoreUsers user) {
    userIdController.text = user.userId;
    userNameController.text = user.name;
    _userId = user.userId;
    _userName = user.name;
    _selectedRole = user.roleCode;
    _dateCreated = user.dateCreated;
    _dateInactivated = user.dateInactivated;
    _status = user.status;
    userRetrieved = true;
  }

  String validateUserId(String value) {
    if (value.isEmpty) return "User Id cannot be empty.";
    return null;
  }

  String validateUserName(String value) {
    if (value.isEmpty) return "User name cannot be empty.";
    return null;
  }

  String validateUserRole(dynamic value) {
    if (value == null) {
      _roleValidationErrorText = "User role cannot be empty.";

      return _roleValidationErrorText;
    } else if (_roleValidationErrorText != null) {
      setState(() {
        _roleValidationErrorText = null;
      });
    }
    return null;
  }

  void userIdSave(String value) {
    if (value.isNotEmpty) {
      _userId = value.toLowerCase();
    } else
      _userId = null;
  }

  void userNameSave(String value) {
    if (value.isNotEmpty) {
      _userName = value;
    } else
      _userName = null;
  }

  void userRoleSave(dynamic value) {
    print("Save Role Code $value");
    if (value != null) {
      _selectedRole = value as int;
    }
  }

  saveUserDetails(BuildContext context) async {
    final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
    setState(() {
      _isProcessing = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      userValidationErrorText = null;
      if (!userRetrieved) {
        print("Not Retrieved.....");
        user = await userLoginViewModel.checkIfUserExists(storeId: _storeId, branchId: _branchId, userId: _userId);
        if (user != null) {
          setState(() {
            userValidationErrorText = "User Id $_userId already exists";
            _isProcessing = false;
          });
          return;
        }
      }
      if (user != null && user.uid != null) {
        StoreUsers _user = StoreUsers(
          uid: user.uid,
          userId: _userId.toLowerCase(),
          name: _userName,
          roleCode: _selectedRole,
          password: user.password,
          dateCreated: user.dateCreated,
          status: user.status,
          branchId: user.branchId,
          storeId: user.storeId,
          dateInactivated: user.dateInactivated,
        );

        if (user == _user) {
          displayMessage(context, "No change to save.");
        } else {
          bool _result = await userLoginViewModel.updateUser(_user);
          if (!_result) {
            displayMessage(context, userLoginViewModel.errorMessage);
          } else {
            _formChanged = false;
            displayMessage(context, "User updated successfully.");
          }
        }
      } else {
        bool _result = await userLoginViewModel.createNewUser(
            storeId: _storeId,
            branchId: _branchId,
            userId: _userId.toLowerCase(),
            userName: _userName,
            roleCode: _selectedRole as int,
            password: _userId);
        if (!_result) {
          displayMessage(context, userLoginViewModel.errorMessage);
        } else {
          _formChanged = false;
          userRetrieved = false;
          displayMessage(context, "User created successfully.");
        }
      }
    }

    setState(() {
      _isProcessing = false;
    });
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

  Future<bool> canPopScreen(BuildContext context) async {
    if (_formChanged) {
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

  Future<void> inActivateUser(BuildContext context) async {
    if (user.uid == null) return;
    ConfirmAction action = await _asyncConfirmDialog(
        context: context, header: "Inactivate User", alertMessage: "Do you want to Inactivate this user?");
    if (action == ConfirmAction.CONFIRM) {
      _status = "I";
      _dateInactivated = DateTime.now();
      final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
      bool result = await userLoginViewModel.inactivateUser(user.uid, _dateInactivated);
      if (!result) {
        displayMessage(context, "${userLoginViewModel.errorMessage}");
      } else {
        displayMessage(context, "User In Activated.");
      }

      return;
    }
  }

  resetUserPassword(BuildContext context, StoreUsers user) async {
    if (user == null || user.userId == null) return;
    ConfirmAction action = await _asyncConfirmDialog(
        context: context,
        header: "Reset Password",
        alertMessage: "Do you want to Reset password of user ${user.userId}?");
    if (action == ConfirmAction.CONFIRM) {
      final userLoginViewModel = context.read(userLoginViewModelProvider.notifier);
      bool result = await userLoginViewModel.resetPassword(user);
      if (!result) {
        displayMessage(context, "${userLoginViewModel.errorMessage}");
      } else {
        displayMessage(context, "User Password Reset.");
      }
    }
  }
}
