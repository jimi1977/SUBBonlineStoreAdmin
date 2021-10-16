import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/screens/branch_setup_page.dart';
import 'package:subbonline_storeadmin/widgets/store_branches_tabbar.dart';

import '../constants.dart';
import 'store_setup_page.dart';

class StoreBranchesMain extends StatefulWidget {
  const StoreBranchesMain({Key key}) : super(key: key);

  static const id = "store_branches_main";

  @override
  _StoreBranchesMainState createState() => _StoreBranchesMainState();
}

class _StoreBranchesMainState extends State<StoreBranchesMain> with AutomaticKeepAliveClientMixin {
  GlobalKey<StoreSetupPageState> _storeKey = GlobalKey();
  GlobalKey<BranchSetupPageState> _branchKey = GlobalKey();

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

  bool isFormChanged() {
    return _storeKey.currentState.isFormChanged || _branchKey.currentState == null ? false : _branchKey.currentState.isFormChanged;
  }

  Future<bool> canPopScreen(BuildContext context) async {
    if (isFormChanged()) {
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
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Store Maintenance"),
              //backgroundColor: kMainPalette,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Icon(Icons.arrow_back),
                  onTap: () async {
                    if (await canPopScreen(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              actions: [
                InkWell(
                  splashColor: Colors.blue.shade100,
                  radius: 30,
                  onTap: () async {
                    bool isSuccessful = true;
                    bool storeChanged = false;
                    bool branchChanged = false;
                    await EasyLoading.show(
                      status: 'Saving...',
                      maskType: EasyLoadingMaskType.clear,
                    );
                    if (_storeKey.currentState.isFormChanged) {
                      storeChanged = true;
                      isSuccessful = await _storeKey.currentState.saveStoreInformation();
                    }
                    if (isSuccessful && _branchKey!= null && _branchKey.currentState.isFormChanged) {
                      branchChanged = true;
                      isSuccessful = await _branchKey.currentState.saveBranchInformation();
                    }
                    await EasyLoading.dismiss();
                    if (!storeChanged && !branchChanged) {
                      displayMessage(context, "No Changes to save.");
                    } else if (isSuccessful) {
                      displayMessage(context, "Changes saved successfully.");
                    }
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
              bottom: StoreBranchesTabBar()),
          body: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height - 56 - 80,
                  child: TabBarView(
                    children: <Widget>[
                      StoreSetupPage(
                        key: _storeKey,
                      ),
                      BranchSetupPage(
                        key: _branchKey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }
}
