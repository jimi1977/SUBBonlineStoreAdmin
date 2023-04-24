import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/viewmodels/rider_view_model.dart';

class RiderSelectionWidget extends ConsumerWidget {
  RiderSelectionWidget({Key key}) : super(key: key);

  double _width = 0 ;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(riderViewProvider.notifier);
    _width = MediaQuery.of(context).size.width - 10;

    buildSelectRiderButton(String riderUid) {
      return   RawMaterialButton(
        elevation: 1,
        hoverElevation: 3,
        focusElevation: 3,
        fillColor: Colors.blue,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 100, minHeight: 25, minWidth: 80, maxHeight: 30),
        onPressed: () {
          print("Index $riderUid");
          model.selectedRiderUid = riderUid;
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
            side:
            BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: Text("Select",),
      );
    }

    return Container(
      child: FutureBuilder(
        future: model.getAvailableRiders(model.getStoreId(), model.getBranchId()),
        builder: (BuildContext context, AsyncSnapshot<List<StoreUsers>> snapShot) {
          if (snapShot.connectionState != ConnectionState.done) {
            EasyLoading.show(
              status: 'loading...',
              maskType: EasyLoadingMaskType.clear,
            );
            return Container();
          } else {
            EasyLoading.dismiss();
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListView.builder(
                    itemCount: snapShot.data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: _width * 0.40,
                                child: Text("${snapShot.data[index].name}", style: kNameTextStyle15,)),
                            SizedBox(
                              width: _width * 0.25,
                                child: Text("${snapShot.data[index].ordersInQueue} orders")),
                            buildSelectRiderButton(snapShot.data[index].uid)
                          ],
                        ),
                      );
                    }));
          }
        },
      ),
    );
  }
}
