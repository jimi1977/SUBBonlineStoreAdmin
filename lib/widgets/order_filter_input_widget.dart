import 'package:flutter/material.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterInputWidget extends StatefulWidget {
  FilterInputWidget({Key key, this.applyFilterFunction}) : super(key: key);
  double _width;
  final Function applyFilterFunction;

  @override
  _FilterInputWidgetState createState() => _FilterInputWidgetState();
}

class _FilterInputWidgetState extends State<FilterInputWidget> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();
  final TextEditingController fromTimeController = TextEditingController();
  final TextEditingController toTimeController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  String _setTime;

  String _hour, _minute, _time;

  get orderListFilterProvider => null;

  @override
  Widget build(BuildContext context) {
    widget._width = MediaQuery.of(context).size.width * 0.95;
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildNameFilterWidget(),
            buildPriceFilterWidget(),
            buildTimeFilterWidget(context),
            buildApplyFilterWidget()
          ],
        ),
      ),
    );
  }

  applyFilter(BuildContext context) {
    final orderListFilterViewModel = context.read(orderListFilterProvider);

    if (receiverNameController.text == null || receiverNameController.text.length == 0) {
      orderListFilterViewModel.receiverName =  null;
    }
    else {
      orderListFilterViewModel.receiverName =  receiverNameController.text;
    }

    if (fromPriceController.text == null || (fromPriceController.text.length) == 0) {
      orderListFilterViewModel.fromPrice = null;
    }
    else {
      orderListFilterViewModel.fromPrice = double.parse(fromPriceController.text?? "0.0" );
    }

    if (toPriceController.text == null || toPriceController.text.length == 0) {
      orderListFilterViewModel.toPrice = null;
    }
    else {
      orderListFilterViewModel.toPrice = double.parse(toPriceController.text == null? '0.0' :toPriceController.text );
    }
    if (fromTimeController.text == null || (fromTimeController.text.length == 0)) {
      orderListFilterViewModel.fromTime = null;
    }
    else {
      orderListFilterViewModel.fromTime = TimeOfDay(hour: int.parse(fromTimeController.text.split(":")[0]), minute: int.parse(fromTimeController.text.split(":")[1]));
    }
    if (toTimeController.text == null || (toTimeController.text.length == 0)) {
      orderListFilterViewModel.toTime = null;
    }
    else {
      orderListFilterViewModel.toTime = TimeOfDay(hour: int.parse(toTimeController.text.split(":")[0]), minute: int.parse(toTimeController.text.split(":")[1]));
    }

    if (orderListFilterViewModel.filterValuesProvided()) {
      print("Filter Value Provided");
      orderListFilterViewModel.setFilterApplied();
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController timeController) async {

    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.input

    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        timeController.text = _time;
      });
  }

  Widget buildNameFilterWidget() {
    return Row(
      children: [
        Container(width: widget._width * 0.27, child: Text("Receiver's Name")),
        _inputField(
          textEditingController: receiverNameController,
          //hintText: "R",
          //helperText: "Please enter user login id.",
          obscureText: false,
          //prefixIcon: Icons.login,
          suffixIcon: Icons.close,
          suffixIconFunction: () {
            receiverNameController.clear();
          },
          enable: true,
          maxLength: 25,
          textInputAction: TextInputAction.next,
          width: widget._width * 0.70,
        ),
      ],
    );
  }

  Widget buildPriceFilterWidget() {
    return Row(
      children: [
        Container(width: widget._width * 0.27, child: Text("Price")),
        _inputField(
            textEditingController: fromPriceController,
            textInputType: TextInputType.numberWithOptions(),
            hintText: "From Price",
            //helperText: "Please enter user login id.",
            obscureText: false,
            //prefixIcon: Icons.login,
            //suffixIcon: Icons.close,
            // suffixIconFunction: (){
            //   receiverNameController.clear();
            // },
            enable: true,
            maxLength: 25,
            textInputAction: TextInputAction.next,
            width: widget._width * 0.30),
        _inputField(
            textEditingController: toPriceController,
            textInputType: TextInputType.numberWithOptions(),
            hintText: "To Price",
            //helperText: "Please enter user login id.",
            obscureText: false,
            //prefixIcon: Icons.login,
            //suffixIcon: Icons.close,
            enable: true,
            maxLength: 25,
            textInputAction: TextInputAction.next,
            width: widget._width * 0.30),
      ],
    );
  }

  buildTimeFilterWidget(BuildContext context) {
    return Row(
      children: [
        Container(width: widget._width * 0.27, child: Text("Time")),
        InkWell(
          onTap: () async {
            print("Inkwell onTap");
            await _selectTime(context,fromTimeController);
            setState(() {

            });
          },
          child: Container(
            child: IgnorePointer(
              child: _inputField(
                  textEditingController: fromTimeController,
                  textInputType: TextInputType.numberWithOptions(),
                  hintText: "From Time",
                  //initialValue: "00 : 00",
                  //helperText: "Please enter user login id.",
                  obscureText: false,
                  //prefixIcon: Icons.login,
                  //suffixIcon: Icons.close,
                  // suffixIconFunction: (){
                  //   receiverNameController.clear();
                  // },
                  enable: true,
                  maxLength: 25,
                  textInputAction: TextInputAction.next,
                  // onSaveFunction: () async {
                  //   await _selectTime(context,fromTimeController);
                  // },
                  width: widget._width * 0.30),
            ),
          ),
        ),



        InkWell(
          onTap: () async {
            print("Inkwell onTap");
            await _selectTime(context, toTimeController);
            setState(() {

            });
          },
          child: Container(
            child: IgnorePointer(
              child: _inputField(
                  textEditingController: toTimeController,
                  textInputType: TextInputType.numberWithOptions(),
                  hintText: "To Time",
                  //helperText: "Please enter user login id.",
                  obscureText: false,
                  //prefixIcon: Icons.login,
                  //suffixIcon: Icons.close,
                  enable: true,
                  maxLength: 25,
                  textInputAction: TextInputAction.next,
                  width: widget._width * 0.30),
            ),
          ),
        ),
      ],
    );
  }
  Widget buildApplyFilterWidget() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              style: TextButton.styleFrom(
                //primary: Colors.deepOrangeAccent,
                //side: BorderSide(color: Colors.orange),
                  minimumSize: Size(70, 24),
                  padding: EdgeInsets.all(4)),
              child: Text("Apply"),
              onPressed: (){
                applyFilter(context);
                widget.applyFilterFunction();
              })
        ],

      ),
    );

  }

  Padding _inputField(
      {@required String hintText,
        @required String helperText,
        String dbValue,
        @required IconData prefixIcon,
        IconData suffixIcon,
        String errortext,
        @required TextEditingController textEditingController,
        @required TextInputType textInputType,
        @required bool obscureText,
        @required TextInputAction textInputAction,
        TextAlign textAlign,
        TextDirection textDirection,
        bool autoFocus = false,
        bool enable,
        String initialValue,
        int maxLength,
        @required FocusNode focusNode,
        @required Function validateFunction,
        @required Function onSaveFunction,
        @required Function onFieldSubmittedFunction,
        @required Function onTapFunction,
        Function suffixIconFunction,
        EdgeInsetsGeometry padding,
        int minLines,
        int maxLines,
        double width}) {
    if (initialValue != null) {
      TextEditingController lTextEditingController;
      if (textEditingController != null) {
        textEditingController.text = initialValue;
      }
    }

    return Padding(
      padding: padding == null ? EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5) : padding,
      child: ConstrainedBox(
        constraints: BoxConstraints.tight(Size(width, 30)),
        child: TextFormField(
          enableInteractiveSelection: true,
          initialValue: dbValue,
          textAlign: textAlign == null ? TextAlign.left : textAlign,
          maxLength: maxLength,
          enabled: enable,
          controller: textEditingController,
          keyboardType: textInputType,
          obscureText: obscureText ?? false,
          style: kTextInputStyle,
          textInputAction: textInputAction,
          autofocus: autoFocus,
          minLines: minLines == null ? 1 : minLines,
          maxLines: maxLines == null ? 1 : maxLines,
          decoration: InputDecoration(
            isDense: true,
            counter: SizedBox.shrink(),
            alignLabelWithHint: true,
            //labelText: hintText,
            hintText: hintText,
            // helperText: helperText,
            errorText: errortext,
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, style: BorderStyle.solid)),
            //hintStyle: kLineStyle,
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 1, vertical: 8),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, style: BorderStyle.solid)),
            // prefixIcon: Padding(
            //   padding: const EdgeInsetsDirectional.only(start: 0.0),
            //   child: Icon(
            //     prefixIcon,
            //     size: 18,
            //   ),
            // ),
            suffixIcon: suffixIcon != null
                ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 0.0),
              child: InkWell(
                onTap: suffixIconFunction,
                child: Icon(
                  suffixIcon,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            )
                : null,
          ),
          onChanged: (value) {},
          //validator: validateFunction,
          //onSaved: onSaveFunction,
          //onEditingComplete: onFieldSubmittedFunction,
          onTap: onTapFunction,
        ),
      ),
    );
  }


}