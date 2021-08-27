import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/responsive/device_screen_type.dart';
import 'package:subbonline_storeadmin/responsive/ui_utils.dart';
import 'package:subbonline_storeadmin/screens/my_order_details.dart';
import 'package:subbonline_storeadmin/screens/store_orders_mobile_portrait.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';

class StoreOrdersMobileLandscape extends StatefulWidget {
  StoreOrdersMobileLandscape({this.order, this.index, this.removeFunction});

  final Order order;
  final int index;
  final Function removeFunction;

  bool selected = false;
  @override
  _StoreOrdersMobileLandscapeState createState() => _StoreOrdersMobileLandscapeState();
}

class _StoreOrdersMobileLandscapeState extends State<StoreOrdersMobileLandscape> {
  double _width;


  Color orderLineColor;

  @override
  Widget build(BuildContext context) {
    if (widget.order.storeOrders == null) {
      return Container();
    }
    if (widget.index % 2 == 0) {
      orderLineColor = Colors.white;
    } else {
      orderLineColor = Colors.black12;
    }
    _width = MediaQuery.of(context).size.width * 0.98;
    String _address = widget.order.deliveryAddress.addressLine1;
    if (widget.order.deliveryAddress.addressLine2 != null) {
      _address = _address + " " + widget.order.deliveryAddress.addressLine2;
    }
    _address = _address + ", " + widget.order.deliveryAddress.suburb;
    _address = _address + ", " + widget.order.deliveryAddress.city;

    return Consumer(builder: (context, watch, _) {
      final orderWidgetSelectIndex = watch(orderWidgetSelectProvider);
      if (orderWidgetSelectIndex.state == widget.index) {
        widget.selected = !widget.selected;
      } else
        widget.selected = false;

      String _statusChangeDate = formatDateTimeToDayTimeString(
          Timestamp.fromDate(widget.order.storeOrders.orderStage.last.stageChangeDatetime));

      var deviceType = getDeviceType(MediaQuery.of(context));
      return Padding(
          padding: const EdgeInsets.all(2.0),
          child: LayoutBuilder(builder: (context, constraint) {
            return Container(
              constraints: BoxConstraints(minHeight: 27),
              width: _width,
              decoration: BoxDecoration(
                  color: widget.selected ? Colors.blue.shade200:orderLineColor,
                  border: Border.all(color: widget.selected ? Colors.blue.shade200: orderLineColor),
                  borderRadius: BorderRadius.circular(4)),
              child: InkWell(
                onTap: () {
                  orderWidgetSelectIndex.state = widget.index;
                },
                onDoubleTap: () {
                  Navigator.pushNamed(context, MyOrderDetails.id, arguments: widget.order);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: _width * geColumnWidthRatio("orderId", deviceType),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.order.orderId,
                                style: kOrderTextStyle,
                              ),
                            ),
                            if (deviceType == DeviceScreenType.Mobile)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  orderStageDescription(
                                      orderStageEnumTypeFromString(widget.order.storeOrders.orderStage.last.stage)),
                                  style: kOrderTextStyle,
                                ),
                              ),
                          ],
                        )),

                    SizedBox(
                        width: _width * geColumnWidthRatio("name", deviceType),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.order.deliveryAddress.receiverName),
                            if (deviceType == DeviceScreenType.Mobile)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(_statusChangeDate, style: kNumberTextStyle,),
                                  )),
                          ],
                        )),

                    SizedBox(width: _width * geColumnWidthRatio("address", deviceType),
                        child: Text(_address)),
                    SizedBox(
                        width: _width * geColumnWidthRatio("items", deviceType),
                        child: Text(
                          widget.order.storeOrders.orderDetail.length.toString(),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                        width: _width * geColumnWidthRatio("amount", deviceType),
                        child: Text(widget.order.storeOrders.storeOrderAmount.toStringAsFixed(2), textAlign: TextAlign.right), ),
                    SizedBox(width: 6,),
                    if (deviceType == DeviceScreenType.Tablet)
                      SizedBox(
                        width: _width * geColumnWidthRatio("status", deviceType),
                        child: Text(
                          orderStageDescription(
                              orderStageEnumTypeFromString(widget.order.storeOrders.orderStage.last.stage)).toUpperCase(),
                          style:  orderStageEnumTypeFromString(widget.order.storeOrders.orderStage.last.stage) == OrderStageEnum.OrderCancelled ? k14BoldRed : kOrderTextStyle,
                        ),
                      ),
                    if (deviceType == DeviceScreenType.Tablet)
                      SizedBox(
                        width: _width * geColumnWidthRatio("statusDayTime", deviceType),
                        child: Text(
                          _statusChangeDate,
                        ),
                      ),


                    //OrderViewDetailButton(context: context, order: widget.order),
                    if (widget.order.storeOrders.orderStage.last.stage ==
                        OrderStageEnum.OrderReceived.toString().split(".")[1])
                      Expanded(
                          child: AcceptOrderButtonWidget(
                        order: widget.order,
                        removeFunction: this.widget.removeFunction,
                      )),
                    if (widget.order.storeOrders.orderStage.last.stage ==
                        OrderStageEnum.OrderConfirmed.toString().split(".")[1])
                      Expanded(child: OrderInProgressButton(order: widget.order)),
                    if (widget.order.storeOrders.orderStage.last.stage ==
                        OrderStageEnum.InProgress.toString().split(".")[1])
                      Expanded(child: OrderOutForDeliveryButton(order: widget.order)),
                    if (widget.order.storeOrders.orderStage.last.stage ==
                        OrderStageEnum.OutForDelivery.toString().split(".")[1])
                      Expanded(
                          child: OrderDeliveredButton(
                        order: widget.order,
                      )),
                  ],
                ),
              ),
            );
          }));
    });
  }
}

double geColumnWidthRatio(String label, DeviceScreenType deviceScreenType) {
  switch(label) {
    case "orderId":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.10 : 0.16;
    case "name":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.13 : 0.18;
    case "address":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.25 : 0.25;
    case "items":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.04 : 0.07;
    case "amount":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.08 : 0.10;
    case "status":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.13 : 0.18;
    case "statusDayTime":
      return deviceScreenType == DeviceScreenType.Tablet ? 0.13 : 0.18;

    default:
      return 0.10;
  }

}

class StoreOrdersHeaderLandscape extends StatelessWidget {
  StoreOrdersHeaderLandscape({Key key, this.textStyle}) : super(key: key);

  TextStyle textStyle;


  @override
  Widget build(BuildContext context) {
    double _width;
    _width = MediaQuery.of(context).size.width * 0.98;
    var deviceType = getDeviceType(MediaQuery.of(context));
    return Container(
      width: _width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: _width * geColumnWidthRatio("orderId", deviceType),
                  child: Text(
                    "Order Id",
                    style: textStyle,
                  )),
              SizedBox(
                  width: _width * geColumnWidthRatio("name", deviceType),
                  child: Text(
                    "Name",
                    style: textStyle,
                  )),
              SizedBox(
                  width: _width * geColumnWidthRatio("address", deviceType),
                  child: Text(
                    "Address",
                    style: textStyle,
                  )),
              SizedBox(
                  width: _width * geColumnWidthRatio("items", deviceType),
                  child: Text(
                    "Items",
                    style: textStyle,
                  )),
              SizedBox(
                  width: _width * geColumnWidthRatio("amount", deviceType),
                  child: Text(
                    "Amount",
                    style: textStyle,
                      textAlign: TextAlign.right
                  )),
              SizedBox(width: 6,),
              if (deviceType == DeviceScreenType.Tablet)
                SizedBox(
                    width: _width * geColumnWidthRatio("status", deviceType),
                    child: Text(
                      "Status",
                      style: textStyle,
                    )),
              if (deviceType == DeviceScreenType.Tablet)
                SizedBox(
                    width: _width * geColumnWidthRatio("statusDayTime", deviceType),
                    child: Text(
                      "Status Day/Time",
                      style: textStyle,
                    )),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            height: 1,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
