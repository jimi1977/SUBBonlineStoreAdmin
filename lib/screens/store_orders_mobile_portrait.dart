import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/customer.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/screens/my_order_details.dart';
import 'package:subbonline_storeadmin/utility/utility_functions.dart';
import 'package:subbonline_storeadmin/viewmodels/store_oders_view_model.dart';
import 'package:subbonline_storeadmin/widgets/rider_selection_widget.dart';

class StoreOrdersMobilePortrait extends StatefulWidget {
  final Order order;
  final int index;
  final Function removeFunction;

  StoreOrdersMobilePortrait({
    this.order,
    this.index,
    this.removeFunction,
  });

  @override
  _StoreOrdersMobilePortraitState createState() => _StoreOrdersMobilePortraitState();
}

class _StoreOrdersMobilePortraitState extends State<StoreOrdersMobilePortrait> {
  double _width;
  bool selected;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width * 0.95;
    if (widget.order.storeOrders == null) {
      return Container();
    }
    return Consumer(builder: (context, watch, _) {
      final orderWidgetSelectIndex = watch(orderWidgetSelectProvider);
      if (orderWidgetSelectIndex.state == widget.index) {
        selected = true;
      } else
        selected = false;
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          width: _width,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StoreOrderHeaderMobile(
                selected: selected,
                order: widget.order,
                showTotal: true,
              ),
              Container(
                height: 1,
                color: Colors.grey.shade400,
              ),
              _detail(order: widget.order, width: _width),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1.5),
                child: Container(
                  height: 1,
                  color: Colors.grey.shade400,
                ),
              ),
              _footer(context: context, order: widget.order, width: _width)
            ],
          ),
        ),
      );
    });
  }

  Widget _detail({Order order, double width}) {
    String _statusChangeDate =
        formatDateTimeToDayTimeString(Timestamp.fromDate(order.storeOrders.orderStage.last.stageChangeDatetime));
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Status: ${orderStageDescription(orderStageEnumTypeFromString(order.storeOrders.orderStage.last.stage))}",
                  style: kOrderTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0, top: 4, bottom: 4),
                child: Text(
                  "on $_statusChangeDate",
                  style: kOrderTextStyle,
                ),
              ),
            ],
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: order.storeOrders.orderDetail.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: width * 0.40,
                          child: Text(
                            order.storeOrders.orderDetail[index].productName,
                            style: kTextInputStyle,
                          )),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              width: _width * 0.10,
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${order.storeOrders.orderDetail[index].quantity.toString()}",
                                textAlign: TextAlign.left,
                                style: kNumberTextStyle,
                              )),
                          SizedBox(
                            width: 2,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: _width * 0.15,
                            child: Text(
                              "${order.storeOrders.orderDetail[index].unit}",
                              style: kNumberTextStyle,
                            ),
                          ),
                        ],
                      ),
                      Container(
                          width: width * .20,
                          alignment: Alignment.centerRight,
                          child: Text(
                            kGlobalCurrency + order.storeOrders.orderDetail[index].price.toStringAsFixed(2),
                            style: kNumberTextStyle,
                          )),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _footer({BuildContext context, Order order, double width}) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    var stage = order.storeOrders.orderStage.last.stage;
    bool orderSettled = stage == OrderStageEnum.Delivered.toString().split(".")[1] ||
        stage == OrderStageEnum.OrderCancelled.toString().split(".")[1];
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Visibility(visible: !orderSettled, child: callCustomerButton(storeOrderProvider, order, context)),
          Visibility(visible: orderSettled,child: Expanded(child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: OrderStatusDisplayWidget(order: order, rowAlign: MainAxisAlignment.start,),
          ))),
          OrderViewDetailButton(context: context, order: order),
          // if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1])
          // cancelOrderButton(order),
          if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderReceived.toString().split(".")[1])
            Expanded(
                child: AcceptOrderButtonWidget(
              order: order,
              removeFunction: this.widget.removeFunction,
            )),
          //acceptOrderButton(storeOrderProvider, order, context)),
          if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OrderConfirmed.toString().split(".")[1])
            Expanded(child: OrderInProgressButton(order: order)),
          if (order.storeOrders.orderStage.last.stage == OrderStageEnum.InProgress.toString().split(".")[1])
            Expanded(child: OrderOutForDeliveryButton(order: order)),
          if (order.storeOrders.orderStage.last.stage == OrderStageEnum.OutForDelivery.toString().split(".")[1])
            Expanded(
                child: OrderDeliveredButton(
              order: order,
            )),
        ],
      ),
    );
  }

  Padding callCustomerButton(StoreOrdersViewModel storeOrderProvider, Order order, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OutlinedButton(
          style: TextButton.styleFrom(
              primary: Colors.deepOrangeAccent,
              side: BorderSide(color: Colors.orange),
              minimumSize: Size(70, 28),
              padding: EdgeInsets.all(4)),
          onPressed: () async {
            Customer customer = await storeOrderProvider.getCustomerDetails(order.uid);
            if (customer == null || customer.mobileNumber == null) {
              print("No Mobile Number");
              return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Customer has not provided Phone number."),
                backgroundColor: Colors.blue,
                duration: Duration(milliseconds: 4000),
              ));
            } else {
              await FlutterPhoneDirectCaller.callNumber(customer.mobileNumber);
            }
          },
          child: Text(
            "Call Customer",
            style: TextStyle(fontFamily: kFontFamily, color: Colors.orangeAccent),
          )),
    );
  }
}

class OrderOutForDeliveryButton extends StatelessWidget {
  const OrderOutForDeliveryButton({
    Key key,
    @required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);

    buildRiderPicker() {
      return showModalBottomSheet(
        context: context,
          isDismissible: true,
          isScrollControlled: false,
          enableDrag: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return Container(
            child: RiderSelectionWidget(),
          );
        }

      );



    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RawMaterialButton(
        elevation: 1,
        hoverElevation: 3,
        focusElevation: 3,
        fillColor: Colors.green,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: () async {
          try {
            await buildRiderPicker();
            if (storeOrderProvider.getSelectedRider() != null) {
              print("Selected Rider ${storeOrderProvider.getSelectedRider()}");
              storeOrderProvider.updateOrderStatusWithRider(order, OrderStageEnum.OutForDelivery,storeOrderProvider.getSelectedRider() );
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please select Rider before setting status OutForDeliver."),
                backgroundColor: Colors.blue,
                duration: Duration(milliseconds: 4000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ));
            }
            //this.widget.removeFunction(order, 0, this.selected);
            //storeOrderProvider.updateState();
          } on Exception catch (e) {
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("${storeOrderProvider.errorMessage}"),
              backgroundColor: Colors.blue,
              duration: Duration(milliseconds: 4000),
            ));
          }
        },
        child: Text(
          "Send Delivery",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );


  }

}

class OrderInProgressButton extends StatelessWidget {
  const OrderInProgressButton({
    Key key,
    @required this.order,
  }) : super(key: key);


  final Order order;


  @override
  Widget build(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: RawMaterialButton(
        elevation: 1,
        hoverElevation: 3,
        focusElevation: 3,
        fillColor: Colors.green,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: () {
          try {
            storeOrderProvider.startProcessingOrder(order);
            //this.widget.removeFunction(order, 0, this.selected);
            //storeOrderProvider.updateState();
          } on Exception catch (e) {
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("${storeOrderProvider.errorMessage}"),
              backgroundColor: Colors.blue,
              duration: Duration(milliseconds: 4000),
            ));
          }
        },
        child: Text(
          "Start Progress",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class OrderViewDetailButton extends StatelessWidget {
  const OrderViewDetailButton({
    Key key,
    @required this.context,
    @required this.order,
  }) : super(key: key);

  final BuildContext context;
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OutlinedButton(
          style: TextButton.styleFrom(
              primary: Colors.deepOrangeAccent,
              side: BorderSide(color: Colors.orange),
              minimumSize: Size(60, 28),
              padding: EdgeInsets.all(4)),
          onPressed: () {
            Navigator.pushNamed(context, MyOrderDetails.id, arguments: order);
          },
          child: Text(
            "View Details",
            style: TextStyle(color: Colors.orangeAccent),
          )),
    );
  }
}

class OrderDeliveredButton extends StatelessWidget {
  const OrderDeliveredButton({Key key, @required this.order}) : super(key: key);
  final Order order;

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context, String header, String alertMessage) async {
    assert(header != null);
    assert(alertMessage != null);
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: Text(
            alertMessage,
            style: kTextInputStyle,
          ),
          buttonPadding: EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CONFIRM);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RawMaterialButton(
        elevation: 1,
        hoverElevation: 3,
        focusElevation: 3,
        fillColor: Color(0xFFFF6D05),
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFFF6D05), style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: () async {
          try {
            if (await _asyncConfirmDialog(context, "Has it been delivered?",
                    "Please make sure that order has been delivered as App will send alert message to customer.") ==
                ConfirmAction.CONFIRM) {
              storeOrderProvider.updateOrderStatus(order, OrderStageEnum.Delivered);
            }

            //storeOrderProvider.updateState();
          } on Exception catch (e) {
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("${storeOrderProvider.errorMessage}"),
              backgroundColor: Colors.blue,
              duration: Duration(milliseconds: 4000),
            ));
          }
        },
        child: Text(
          "Delivered",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class OrderStatusDropDown extends StatefulWidget {
  const OrderStatusDropDown({Key key, @required this.order, @required this.currentStatus}) : super(key: key);

  final Order order;
  final String currentStatus;

  @override
  _OrderStatusDropDownState createState() => _OrderStatusDropDownState();
}

class _OrderStatusDropDownState extends State<OrderStatusDropDown> {
  String _selectedStatus;

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context, String header, String alertMessage) async {
    assert(header != null);
    assert(alertMessage != null);
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: Text(
            alertMessage,
            style: kTextInputStyle,
          ),
          buttonPadding: EdgeInsets.only(left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CONFIRM);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.currentStatus != null);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 130,
        height: 32,
        child: FormField(
          enabled: true,
          validator: (value) {},
          builder: (FormFieldState state) {
            return InputDecorator(
              expands: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                filled: false,
                hintText: "Choose Status",
                enabledBorder: _outlineInputBorder(Colors.grey.shade400),
                focusedErrorBorder: _outlineInputBorder(Colors.grey.shade400),
                errorBorder: _outlineInputBorder(Colors.redAccent),
                focusedBorder: _outlineInputBorder(Colors.grey.shade400),
              ),
              child: Container(
                height: 20,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    elevation: 1,
                    style: kNumberTextStyle,
                    items: _getAvailAbleStatus(),
                    value: _selectedStatus == null ? _selectedStatus = widget.currentStatus : _selectedStatus,
                    onChanged: (value) async {
                      print("Old Status: $_selectedStatus New Status: $value");
                      if (_selectedStatus == value) return;
                      _selectedStatus = value;
                      var stage = orderStageEnumTypeFromString(_selectedStatus);
                      if (stage == OrderStageEnum.Delivered) {
                        if (await _asyncConfirmDialog(context, "Has it been delivered?",
                                "Please make sure that order has been delivered as App will send alert message to customer.") !=
                            ConfirmAction.CONFIRM) {
                          return;
                        }
                      }
                      setState(() {
                        if (_selectedStatus != value) {
                          final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
                          try {
                            storeOrderProvider.updateOrderStatus(widget.order, stage);
                          } on Exception catch (e) {
                            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("${storeOrderProvider.errorMessage}"),
                              backgroundColor: Colors.blue,
                              duration: Duration(milliseconds: 4000),
                            ));
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getAvailAbleStatus() {
    List<DropdownMenuItem<String>> items = [];
    OrderStageEnum.values.forEach((stage) {
      if (getOrderStageEnumIndex(stage) >= getOrderStageEnumIndex(orderStageEnumTypeFromString(widget.currentStatus)) &&
          stage != OrderStageEnum.OrderCancelled) {
        items.add(DropdownMenuItem(
          child: Text(
            orderStageDescription(stage),
            style: TextStyle(color: Color(0xFFFF6D05)),
          ),
          value: stage.toString().split('.')[1],
        ));
      }
    });
    return items;
  }

  OutlineInputBorder _outlineInputBorder(Color borderColor) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
          topLeft: Radius.circular(5.0),
          topRight: Radius.circular(5.0),
        ));
  }
}

class StoreOrderHeaderMobile extends StatelessWidget {
  const StoreOrderHeaderMobile({Key key, @required this.selected, @required this.order, this.showTotal})
      : super(key: key);

  final bool selected;
  final Order order;
  final bool showTotal;

  @override
  Widget build(BuildContext context) {
    String _orderDateTime = formatDateTimeToDayTimeString(Timestamp.fromDate(order.orderDateTime));
    return Container(
      color: this.selected ? Colors.blue.shade700.withOpacity(0.5) : Colors.blue.shade100.withOpacity(0.5),
      //width: 300,

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 190,
            height: 60,
            child: ListTile(
              dense: true,
              enabled: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              horizontalTitleGap: 8,
              //contentPadding: EdgeInsets.symmetric(horizontal: 1),
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              title: Text(order.deliveryAddress.receiverName, style: kNameTextStyle),
              subtitle: Text(
                _orderDateTime,
                style: kNumberTextStyle,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "Order Id: ${order.orderId}",
                    style: kOrderTextStyle,
                  ),
                ),
                if (showTotal)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "Total: $kGlobalCurrency${order.storeOrders.storeOrderAmount.toStringAsFixed(2)}",
                      style: kNumberTextStyle,
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AcceptOrderButtonWidget extends StatelessWidget {
  final Order order;
  final Function removeFunction;

  AcceptOrderButtonWidget({this.order, this.removeFunction});

  @override
  Widget build(BuildContext context) {
    final storeOrderProvider = context.read(storeOrderViewModelProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RawMaterialButton(
        elevation: 1,
        hoverElevation: 3,
        focusElevation: 3,
        fillColor: Colors.green,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.green, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: () {
          try {
            storeOrderProvider.acceptOrder(order);
            removeFunction(order, 0);
            //storeOrderProvider.updateState();
          } on Exception catch (e) {
            return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("${storeOrderProvider.errorMessage}"),
              backgroundColor: Colors.blue,
              duration: Duration(milliseconds: 4000),
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Text(
            "Accept Order",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
