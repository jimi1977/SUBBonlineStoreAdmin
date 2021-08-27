import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/enums/enum_cancellation_reason.dart';
import 'package:subbonline_storeadmin/enums/enum_confirmation.dart';
import 'package:subbonline_storeadmin/enums/order_satges_enum.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/viewmodels/store_oders_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CancelOrderButtonWidget extends StatefulWidget {
  CancelOrderButtonWidget({
    Key key,
    @required this.order,
  }) : super(key: key);

  final Order order;

  @override
  _CancelOrderButtonWidgetState createState() => _CancelOrderButtonWidgetState();
}

class _CancelOrderButtonWidgetState extends State<CancelOrderButtonWidget> {
  GlobalKey<FormState> _orderCancelFormKey = GlobalKey();

  TextEditingController _orderCancelTextController = TextEditingController();

  String _selectedReasonCode;
  String _reasonText;

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

  Future<ConfirmAction> _asyncCancellationReasonDialog(BuildContext context, String header) async {
    assert(header != null);
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
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            updateSelectedReason(String value) {
              setState((){
                _selectedReasonCode = value;
              });
            }
            return AlertDialog(
              title: Text(header, style: kNameTextStyle,),
              content: Form(
                key: _orderCancelFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCancellationReasonDropDown(updateSelectedReason),
                    SizedBox(height: 20,),
                    TextFormField(
                      controller: _orderCancelTextController,
                      enabled: true,
                      minLines: 5,
                      maxLines: 5,
                      validator: (value){
                        if (_selectedReasonCode == null) {
                          return 'Please select reason code.';
                        }
                        else if(value.isEmpty) {
                          return 'Please provide a reason to cancel order.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          isDense: true,
                          hintStyle: kTextInputStyle,
                          contentPadding: EdgeInsets.all(3),
                          enabledBorder: _outlineInputBorder(Colors.grey),
                          border:  _outlineInputBorder(Colors.grey),
                          focusedBorder:  _outlineInputBorder(Colors.blueAccent),
                          hintText: "Please enter reason to cancel order"
                      ),
                    ),
                  ],
                ),
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
                    if (_orderCancelFormKey.currentState.validate()) {
                      _reasonText = _orderCancelTextController.text;
                      Navigator.of(context).pop(ConfirmAction.CONFIRM);
                    }

                  },
                )
              ],
            );
          }
        );
      },
    );
  }
  List<DropdownMenuItem<String>> _getCancellationReasons() {
    List<DropdownMenuItem<String>> items =  [];
    CancellationReasonEnum.values.forEach((reason) {
        items.add(DropdownMenuItem(
          child: Text(getCancellationReasonDescription(reason), style: TextStyle(color: Colors.red),),
          value: reason.toString().split('.')[1],));
    });
    return items;
  }
  Widget buildCancellationReasonDropDown(Function updateParentState) {
    return Container(
      height: 32,
      child: FormField(
        enabled: true,
        builder: (FormFieldState state) {
          return  InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              filled: false,
              hintText: "Choose Cancellation Reason",
              enabledBorder: _outlineInputBorder(Colors.grey.shade400),
              focusedErrorBorder: _outlineInputBorder(Colors.grey),
              errorBorder: _outlineInputBorder(Colors.redAccent),
              focusedBorder:  _outlineInputBorder(Colors.blueAccent),
            ),
            child: Container(
              height: 20,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    elevation: 1,
                    style: kNumberTextStyle,
                    items: _getCancellationReasons(),
                    value: _selectedReasonCode,
                    onChanged: (value) {
                      _selectedReasonCode = value;
                      updateParentState(value);
                    },

                  )
              ),

            ),
          );
        },


      ),
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
        fillColor: widget.order.payment.paymentType == kPaymentTypeCash ? Colors.red : Colors.grey,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(maxWidth: 170, minHeight: 30, minWidth: 80),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: widget.order.payment.paymentType == kPaymentTypeCash ? Colors.red : Colors.grey,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: () async {
          if (widget.order.payment.paymentType != kPaymentTypeCash) {
            return 1;
          }
          try {
            if (await _asyncCancellationReasonDialog(context, "Cancellation Reason") == ConfirmAction.CONFIRM){
              await storeOrderProvider.cancelOrder(widget.order, OrderCancelledEnum.OrderCancelled, _selectedReasonCode, _reasonText);
            }

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
            "Cancel Order",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}