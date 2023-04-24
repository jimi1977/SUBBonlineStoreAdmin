import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/responsive/orientation_layout.dart';
import 'package:subbonline_storeadmin/responsive/screen_type_layout.dart';
import 'package:subbonline_storeadmin/screens/store_orders_mobile_landscape.dart';
import 'package:subbonline_storeadmin/screens/store_orders_mobile_portrait.dart';
import 'package:subbonline_storeadmin/viewmodels/progress_bar_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_oders_view_model.dart';
import 'package:subbonline_storeadmin/widgets/orders_list_filter.dart';

class StoreOrderListMobile extends StatelessWidget {
  StoreOrderListMobile({@required this.orders, @required this.orderType});

  final List<Order> orders;
  final String orderType;

  List<StoreOrder> storeOrdersState;

  int _selected;
  int indexOffSet = 0;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Order order;
  bool shouldBeKeptAlive = true;

  AsyncMemoizer<Order> _memoizer = AsyncMemoizer();
  final orderCache = AsyncCache<List<Order>>(const Duration(minutes: 30));
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    final progressBarViewModel = context.read(progressViewModelProvider.notifier);
    final orderWidgetSelectIndexProvider = context.read(orderWidgetSelectProvider);

    //indexOffSet = storeOrdersState.length - widget.storeOrders.length;
    return CustomScrollView(
      controller: scrollController,
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      slivers: [
        SliverToBoxAdapter(
          child: Visibility(
              visible: orderType == "PastOrders",
              child: OrderListFilter()),
        ),
        SliverToBoxAdapter(
          child: Visibility(
            visible: orders == null || orders.length == 0,
            child: _buildNoNewOrderWidget(context),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            child: Scrollbar(
              showTrackOnHover: true,
              thickness: 6,
              child: AnimatedList(
                controller: scrollController,
                key: listKey,
                //physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                initialItemCount: orders.length,
                itemBuilder: (context, index, animation) {
                  order = orders[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index == 0)
                        ScreenTypeLayout(
                          mobile: OrientationLayout(
                            landscape: StoreOrdersHeaderLandscape(textStyle: kNameTextStyle,),
                            portrait: Container(),
                          ),
                          tablet: OrientationLayout(
                            landscape: StoreOrdersHeaderLandscape(textStyle: kNameTextStyle15,),
                            portrait: Container(),
                          ),
                        ),
                      GestureDetector(
                          onTap: () {
                            indexOffSet = 0;
                            orderWidgetSelectIndexProvider.state = index;
                            print("SELECTED INDEX $index");
                            // setState(() {
                            //   indexOffSet = 0;
                            //   _selected = index;
                            // });
                          },
                          child: slideIt(context, order, index, animation)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 40,),
        )
      ],

    );
  }

  Widget _buildNoNewOrderWidget(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height/2,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Container(
              height: 37,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: Colors.yellowAccent.withGreen(10).withOpacity(0.18), width: 2),
                color: Colors.orange.withOpacity(0.2),
                //gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade200, Colors.orange.shade50])
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No order exists for selected date"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _acceptOrder(
    Order order,
    int index,
  ) {
    listKey.currentState.removeItem(index, (context, animation) => slideIt(context, order, index, animation),
        duration: const Duration(milliseconds: 500));
    orders.removeAt(index);
    indexOffSet = 0;
    print("Accept Order");
  }

  Widget slideIt(BuildContext context, Order order, int index, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-2, 0),
        end: Offset(0, 0),
      ).animate(CurvedAnimation(parent: animation, curve: Curves.bounceIn, reverseCurve: Curves.bounceOut)),
      child: ScreenTypeLayout(
          mobile: OrientationLayout(
              portrait: StoreOrdersMobilePortrait(
                order: order,
                index: index,
                removeFunction: _acceptOrder,
              ),
              landscape: StoreOrdersMobileLandscape(
                order: order,
                index: index,
                removeFunction: _acceptOrder,
              )),
          tablet: OrientationLayout(
            portrait: StoreOrdersMobilePortrait(
              order: order,
              index: index,
              removeFunction: _acceptOrder,
            ),
            landscape: StoreOrdersMobileLandscape(
              order: order,
              index: index,
              removeFunction: _acceptOrder,
            ),
          ),
          desktop: StoreOrdersMobilePortrait(
            order: order,
            index: index,
            removeFunction: _acceptOrder,
          )),
    );
  }
}
