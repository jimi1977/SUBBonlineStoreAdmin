import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/screens/active_store_orders_mobile.dart';
import 'package:subbonline_storeadmin/screens/order_search_page.dart';
import 'package:subbonline_storeadmin/screens/past_store_orders.dart';
import 'package:subbonline_storeadmin/widgets/orders_tabbar_widget.dart';

class StoreOrdersMain extends StatefulWidget {
  static const id = "store_orders";

  final int pageIndex;

  StoreOrdersMain({this.pageIndex});

  @override
  _StoreOrdersMainState createState() => _StoreOrdersMainState();
}

class _StoreOrdersMainState extends State<StoreOrdersMain> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setPreferredOrientations([
      //DeviceOrientation.landscapeLeft
      //DeviceOrientation.portraitDown,
    ]);
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, OrderSearchPage.id);
                    },
                    child: Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.orangeAccent,
                    )),
              )
            ],
            title: Text("Our Orders", style: TextStyle(color: Colors.black),),
            //backgroundColor: kMainPalette,
            centerTitle: true,
            bottom: OrdersTabBarWidget()),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height - 56 - 130,
                child: TabBarView(
                  children: <Widget>[
                    ActiveStoreOrders(
                      orderType: "New",
                    ),
                    ActiveStoreOrders(
                      orderType: "InProgress",
                    ),
                    PastStoreOrders(
                      orderType: "PastOrders",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

