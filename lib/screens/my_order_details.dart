import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/responsive/device_screen_type.dart';
import 'package:subbonline_storeadmin/responsive/ui_utils.dart';
import 'package:subbonline_storeadmin/screens/store_orders_mobile_portrait.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';
import 'package:subbonline_storeadmin/viewmodels/store_oders_view_model.dart';
import 'package:subbonline_storeadmin/widgets/cancel_order_button_widget.dart';

class MyOrderDetails extends StatelessWidget {
  static const id = 'my_order_details';

  final Order order;

  MyOrderDetails({this.order});

  DeviceScreenType deviceType;


  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height - 80;
    deviceType = getDeviceType(MediaQuery.of(context));

    _width = _width - 10; //paddings
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        title: Text(
          "Order ${order.orderId} Details",
          style: kHeaderTextStyle,
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: buildBottomBarWidget(),
      resizeToAvoidBottomInset: true,
      body: Container(
        height: _height,
        child: CustomScrollView(
          slivers: [

            SliverPersistentHeader(
              floating: true,
                pinned: false,
                delegate: StoreOrderPersistentHeader(
              selected: false,
              order: order,
              showTotal: false,
            ) ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  //buildDisplayCustomerDetails(),
                  // StoreOrderHeaderMobile(
                  //   selected: false,
                  //   order: order,
                  //   showTotal: false,
                  // ),
                  Container(
                    height: 1,
                    color: Colors.grey.shade400,
                  ),
                  OrderTimeLineWidget(
                    order: order,
                  ),
                  buildSeparator(context),
                  buildDisplayAddress(),
                  buildSeparator(context),
                  buildCustomerIno(context),
                  // buildCustomerPhone(),
                  // buildSeparator(context),

                ],
              ),
             
            ),

            SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: MyOrdersLabelsPersistentHeader(width: _width)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  //buildSeparator(context),
                  buildOrderDetailList(_height, _width),
                  buildOrderTotals(context, _width),
                ],
              ) ,
            )

           
          ],



        ),
      ),
    );
  }

  Column buildOrderTotals(BuildContext context, double _width) {
    return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSeparator(context),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, right: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: _width * 0.60,
                          child: Text("Total Items  :", style: kNameTextStyle, textAlign: TextAlign.end)),
                      SizedBox(
                          width: _width * 0.30,
                          child: Text('${order.storeOrders.orderDetail.length}',
                              style: kNameTextStyle, textAlign: TextAlign.end))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: _width * 0.60,
                          child: Text("Payment  :", style: kNameTextStyle, textAlign: TextAlign.end)),
                      SizedBox(
                          width: _width * 0.30,
                          child: Text("${order.payment.paymentType} (${order.payment.paymentStatus})",
                              style: kNameTextStyle, textAlign: TextAlign.end))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: _width * 0.60,
                          child: Text(
                            "Total  :",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.end,
                          )),
                      SizedBox(
                          width: _width * 0.30,
                          child: Text('$kGlobalCurrency ${order.storeOrders.storeOrderAmount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 18), textAlign: TextAlign.end))
                    ],
                  ),
                ),
              ],
            );
  }

  ListView buildOrderDetailList(double _height, double _width) {

    return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Divider(
                    color: Colors.grey,
                  ),
                );
              },
              itemCount: order.storeOrders.orderDetail.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: _width * 0.05,
                        child: Text('${index + 1}', style: kNameTextStyle),
                      ),
                      SizedBox(
                        height: deviceType == DeviceScreenType.Tablet ? 35 : 30,
                        width: deviceType == DeviceScreenType.Tablet ? 35 : 30,
                        child: AspectRatio(
                          aspectRatio: 3.0,
                          child: ClipRRect(
                            child: Image(
                              fit: BoxFit.fill,
                               //height:_height *  (orientation == Orientation.landscape ? 0.08 : 0.05),
                               //width: _width * (orientation == Orientation.landscape ? 0.05 : 0.05),
                              image: NetworkImage(order.storeOrders.orderDetail[index].imageUrl),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      SizedBox(
                          width: _width * 0.25,
                          child: Text(
                            order.storeOrders.orderDetail[index].productName,
                            style: kNameTextStyle,
                            textAlign: TextAlign.left,
                          )),
                      SizedBox(
                          width: _width * 0.20,
                          child: Text(
                            order.storeOrders.orderDetail[index].intlName == null
                                ? ''
                                : order.storeOrders.orderDetail[index].intlName,
                            style: kNameTextStyle,
                            textAlign: TextAlign.left,
                          )),
                      SizedBox(
                          width: _width * .15,
                          child: Text(
                            '${order.storeOrders.orderDetail[index].quantity.toStringAsFixed(0)} ${order.storeOrders.orderDetail[index].unit} ',
                            style: kNameTextStyle,
                          )),
                      SizedBox(
                          width: _width * 0.25,
                          child: Text(
                            '$kGlobalCurrency ${order.storeOrders.orderDetail[index].price.toStringAsFixed(2)}',
                            style: kNameTextStyle,
                          )),
                    ],
                  ),
                );
              },
            );
  }

  Widget buildCustomerIno(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    return FutureBuilder(
      future: storeOrderProvider.getCustomerDetails(order.uid),
      builder: (context, AsyncSnapshot<Customer> snapShot) {
        if (!snapShot.hasData) {
          return Container();
        }
        return Column(
          children: [
            buildCustomerPhone(snapShot.data),
            buildSeparator(context),
            buildCustomerEmail(snapShot.data),
            buildSeparator(context),
          ],
        );
      },
    );
  }

  Padding buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget buildDisplayOrderStatusWidget() {
    String _statusChangeDate;
    if (order.storeOrders.orderStage.length == 1) {
      _statusChangeDate =
          formatDateTimeToDayTimeString(Timestamp.fromDate(order.storeOrders.orderStage.last.stageChangeDatetime));
      return Padding(
        padding: const EdgeInsets.all(4),
        child: buildDisplayOrderStatus(_statusChangeDate),
      );
    } else {
      List<OrderStage> orderStages = order.storeOrders.orderStage.reversed.toList();
      return Padding(
        padding: const EdgeInsets.all(4),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          title: Text(
            'Status:',
            style: kTextInputStyle,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          initiallyExpanded: false,
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: orderStages.length,
                itemBuilder: (context, index) {
                  _statusChangeDate = formatDateTimeToDayTimeString(
                      Timestamp.fromDate(order.storeOrders.orderStage[index].stageChangeDatetime));
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.transfer_within_a_station_sharp,
                            color: Color(0xFFFF6D05),
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: Text(
                        "${orderStages[index].stage} $_statusChangeDate",
                        style: kTextInputStyle,
                      ))
                    ],
                  );
                })
          ],
        ),
      );
    }
  }

  Row buildDisplayOrderStatus(String _statusChangeDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.transfer_within_a_station_sharp,
              color: Color(0xFFFF6D05),
            )),
        SizedBox(
          width: 20,
        ),
        Expanded(
            child: Text(
          "${orderStageDescription(orderStageEnumTypeFromString(order.storeOrders.orderStage.last.stage))} - $_statusChangeDate",
          style: kNameTextStyle,
        )),
        Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Icon(
              Icons.history,
              color: Color(0xFFFF6D05),
            )),
      ],
    );
  }

  Widget buildDisplayAddress() {
    String _address = order.deliveryAddress.addressLine1;
    if (order.deliveryAddress.addressLine2 != null) {
      _address = _address + " " + order.deliveryAddress.addressLine2;
    }
    _address = _address + ", " + order.deliveryAddress.suburb;
    _address = _address + ", " + order.deliveryAddress.city;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Icon(
                Icons.location_pin,
                color: Color(0xFFFF6D05),
              )),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child: Text(
            "$_address",
            style: kTextInputStyle,
          ))
        ],
      ),
    );
  }

  Widget buildCustomerPhone(Customer customer) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Icon(
                Icons.phone,
                color: Color(0xFFFF6D05),
              )),
          Expanded(child: Container(margin: EdgeInsets.only(left: 20), child: Text("${customer.mobileNumber}"))),
          buildCallCustomerButton("${customer.mobileNumber}")
        ],
      ),
    );
  }

  Widget buildCallCustomerButton(String mobileNumber) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 8.0),
      child: SizedBox(
        height: 24,
        child: OutlinedButton(
            style: TextButton.styleFrom(
                primary: Colors.deepOrangeAccent,
                side: BorderSide(color: Colors.orange),
                minimumSize: Size(70, 24),
                padding: EdgeInsets.all(4)),
            onPressed: () async {
              await FlutterPhoneDirectCaller.callNumber(mobileNumber);
            },
            child: Text(
              "Call",
              style: TextStyle(fontFamily: kFontFamily, color: Colors.orangeAccent),
            )),
      ),
    );
  }

  Widget buildCustomerEmail(Customer customer) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Icon(
                Icons.email,
                color: Color(0xFFFF6D05),
              )),
          Expanded(child: Container(margin: EdgeInsets.only(left: 20), child: Text("${customer.email}"))),
          buildEmailCustomerButton("${customer.email}")
        ],
      ),
    );
  }

  Widget buildEmailCustomerButton(String email) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 8.0),
      child: SizedBox(
        height: 24,
        child: OutlinedButton(
            style: TextButton.styleFrom(
                primary: Colors.deepOrangeAccent,
                side: BorderSide(color: Colors.orange),
                minimumSize: Size(70, 24),
                padding: EdgeInsets.all(4)),
            onPressed: () async {
              //await FlutterPhoneDirectCaller.callNumber(mobileNumber);
            },
            child: Text(
              "Email",
              style: TextStyle(fontFamily: kFontFamily, color: Colors.orangeAccent),
            )),
      ),
    );
  }

  Widget buildDisplayCustomerDetails() {
    return Card(
      color: Colors.blueGrey,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "${order.deliveryAddress.receiverName}",
            style: kNameTextStyle,
          ),
        ),
        minVerticalPadding: 8,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text("${order.deliveryAddress.addressLine1} ${order.deliveryAddress.addressLine2}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text("${order.deliveryAddress.suburb}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text("${order.deliveryAddress.city}"),
            )
          ],
        ),
      ),
    );
  }

  bool isOrderSettled() {
    if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderCancelled.toString().split(".")[1] ||
        order.storeOrders.orderStage.last.stage == OrderStageEnum.Delivered.toString().split(".")[1]) {
      return true;
    }
    return false;
  }

  Widget buildBottomBarWidget() {
    return isOrderSettled()
        ? OrderStatusDisplayWidget(
            order: order,
          )
        : Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1])
                  CancelOrderButtonWidget(
                    order: order,
                  ),
                if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1])
                  SizedBox(
                    width: 20,
                  ),
                if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1])
                  AcceptOrderButtonWidget(
                    order: order,
                    removeFunction: () {},
                  ),
                if (order.storeOrders.orderStage.last.stage != OrderStageEnum.OrderReceived.toString().split(".")[1])
                  Text("Order Status: "),
                if (order.storeOrders.orderStage.last.stage != OrderStageEnum.OrderReceived.toString().split(".")[1])
                  OrderStatusDropDown(
                    order: order,
                    currentStatus: order.storeOrders.orderStage.last.stage,
                  ),
                if (order.storeOrders.orderStage.last.stage != OrderStageEnum.OrderReceived.toString().split(".")[1])
                  CancelOrderButtonWidget(
                    order: order,
                  ),
              ],
            ),
          );
  }

}

class MyOrdersLabelsPersistentHeader extends SliverPersistentHeaderDelegate {


  MyOrdersLabelsPersistentHeader({this.width});

  final double width;
  @override
  double get minExtent => 33;

  @override
  double get maxExtent => 33;

  @override
  Widget build(BuildContext context,double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: width * 0.05,
              ),
              SizedBox(
                width: width * 0.15,
                child: Text(
                  "Items",
                  style: kNameTextStyle,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              SizedBox(
                width: width * 0.20,
              ),
              SizedBox(
                width: width * 0.20,
              ),
              SizedBox(
                width: width * .15,
                child: Text(
                  "Qty",
                  style: kNameTextStyle,
                ),
              ),
              SizedBox(
                width: width * 0.25,
                child: Text(
                  "Price",
                  style: kNameTextStyle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey.shade300,
            ),
          )
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  
}

class OrderStatusDisplayWidget extends StatelessWidget {
  const OrderStatusDisplayWidget({Key key, this.order, this.rowAlign}) : super(key: key);

  String getOrderStatusDisplayText(Order order) {
    return "Order Status: " +
        orderStageDescription(orderStageEnumTypeFromString(order.storeOrders.orderStage.last.stage));
  }

  TextStyle getTextStyle() {
    if (orderStageEnumTypeFromString(order.storeOrders.orderStage.last.stage) == OrderStageEnum.OrderCancelled) {
      return kOrderStatusTextStyleR;
    }
    return kOrderStatusTextStyleG;
  }

  final Order order;
  final MainAxisAlignment rowAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: rowAlign == null ? MainAxisAlignment.center : rowAlign,
        children: [
          Text(
            "${getOrderStatusDisplayText(order)}",
            style: getTextStyle(),
          ),
        ],
      ),
    );
  }
}

class OrderTimeLineWidget extends StatefulWidget {
  const OrderTimeLineWidget({Key key, @required this.order}) : super(key: key);

  final Order order;

  @override
  _OrderTimeLineWidgetState createState() => _OrderTimeLineWidgetState();
}

class _OrderTimeLineWidgetState extends State<OrderTimeLineWidget> {
  Order order;
  bool historyAvailable = false;
  bool showHistory = false;

  @override
  Widget build(BuildContext context) {
    order = widget.order;
    assert(order != null);
    String _statusChangeDate;

    if (order.storeOrders.orderStage.length > 1) {
      historyAvailable = true;
    }
    List<OrderStage> orderStages = order.storeOrders.orderStage.reversed.toList();
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          buildDisplayOrderStatus(order.storeOrders.orderStage.last, historyAvailable, false),
          Visibility(
            visible: showHistory,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: orderStages.length,
                itemBuilder: (context, index) {
                  if (index == 0) return Container();
                  return buildDisplayOrderStatus(orderStages[index], false, true);
                }),
          )
        ],
      ),
    );
  }

  Row buildDisplayOrderStatus(OrderStage stage, bool historyAvailable, bool isHistory) {
    String _statusChangeDate = formatDateTimeToDayTimeString(Timestamp.fromDate(stage.stageChangeDatetime));
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 20,
              child: isHistory
                  ? Icon(
                      Icons.arrow_upward,
                      color: Color(0xFFFF6D05),
                      size: 20,
                    )
                  : Icon(
                      Icons.transfer_within_a_station_sharp,
                      color: Color(0xFFFF6D05),
                    ),
            )),
        SizedBox(
          width: 20,
        ),
        Expanded(
            child: Text(
          "${orderStageDescription(orderStageEnumTypeFromString(stage.stage))} - $_statusChangeDate",
          style: isHistory ? kTextInputStyle : kNameTextStyle,
        )),
        Visibility(
          visible: historyAvailable,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: IconButton(
                constraints: BoxConstraints(maxHeight: 26, maxWidth: 26),
                padding: EdgeInsets.all(2),
                icon: Icon(Icons.history),
                color: showHistory ? Colors.grey : Color(0xFFFF6D05),
                splashColor: Colors.deepOrange,
                splashRadius: 13,
                onPressed: () {
                  setState(() {
                    showHistory = !showHistory;
                  });
                },
              )),
        ),
      ],
    );
  }
}


class StoreOrderPersistentHeader extends SliverPersistentHeaderDelegate {

  final bool selected;
  final Order order;
  final bool showTotal;


  StoreOrderPersistentHeader({this.selected, this.order, this.showTotal});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;
  @override
  bool shouldRebuild(StoreOrderPersistentHeader oldDelegate) {
    return false;
  }
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: StoreOrderHeaderMobile(
        selected: selected,
        order: order,
        showTotal: showTotal,
      ),
    );
  }


}