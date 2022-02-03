
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:models/store.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/screens/store_orders_list.dart';
import 'package:subbonline_storeadmin/viewmodels/progress_bar_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_oders_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_view_model.dart';

class ActiveStoreOrders extends StatefulWidget {
  final String orderType;

  ActiveStoreOrders({this.orderType});

  @override
  _ActiveStoreOrdersState createState() => _ActiveStoreOrdersState();
}

class _ActiveStoreOrdersState extends State<ActiveStoreOrders> with AutomaticKeepAliveClientMixin {
  bool _noOrders = false;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  Order order;
  String _storeId;
  String _branchId;

  List<StoreOrder> storeOrders;

  final orderCache = AsyncCache<List<Order>>(const Duration(minutes: 0));

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    final progressBarViewModel = context.read(progressViewModelProvider.notifier);
    Future<List<Order>> _getOrdersByIdFuture(List<StoreOrder> storeOrders) => orderCache.fetch(() {
      return storeOrderProvider.getOrdersByOrderIds(storeOrders);
    });
    _storeId = storeOrderProvider.getCurrentStoreId();
    _branchId = storeOrderProvider.getCurrentBranchId();

    return _noOrders
        ? _buildNoNewOrderWidget()
        : Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: storeOrderProvider.getStoreOrdersReceivedByStoreId(_storeId, _branchId, widget.orderType),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
                //progressBarViewModel.startProgress();
                EasyLoading.show(
                  status: 'loading...',
                  maskType: EasyLoadingMaskType.clear,
                );
                //CustomLoadingBar.show();
                Future.delayed(
                  Duration(milliseconds: 10),
                ).then((value) => progressBarViewModel.startProgress());
                return Container();
              }

              storeOrders = storeOrderProvider.getStoresOrdersFromSnapShot(snapshot.data);
              if (storeOrders == null || storeOrders.length == 0) {
                Future.delayed(
                  Duration(milliseconds: 100),
                ).then((value) => progressBarViewModel.stopProgress());

                EasyLoading.dismiss();
                return _buildNoNewOrderWidget();
              }
              return FutureBuilder<List<Order>>(
                  future: _getOrdersByIdFuture(storeOrders),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }
                    Future.delayed(
                      Duration(milliseconds: 100),
                    ).then((value) => progressBarViewModel.stopProgress());

                    EasyLoading.dismiss();
                    //progressBarViewModel.stopProgress();
                    return StoreOrderListMobile(
                      orders: snapshot.data,
                      orderType: widget.orderType,
                    );
                  });
            }));
  }

  Widget _buildNoNewOrderWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.yellowAccent.withGreen(10).withOpacity(0.18), width: 2),
            color: Colors.orange.withOpacity(0.2),
            //gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade200, Colors.orange.shade50])
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No New Orders"),
          ),
        ),
      ),
    );
  }
}
