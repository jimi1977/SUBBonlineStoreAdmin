import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:subbonline_storeadmin/constants.dart';
import 'package:subbonline_storeadmin/viewmodels/order_list_filter_view_model.dart';

import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/widgets/order_filter_input_widget.dart';

final orderListFilterProvider =
ChangeNotifierProvider<OrderListFilterViewModel>((ref) => OrderListFilterViewModel());




class OrderListFilter extends StatefulWidget {
  @override
  _OrderListFilterState createState() => _OrderListFilterState();
}

class _OrderListFilterState extends State<OrderListFilter> {
  int _selectedValue = 10;
  DateTime selectedDate = DateTime.now().toLocal();
  DateTime _previousSelectedDate;
  String displayDate;
  bool showFilters = false;
  bool filterApplied = false;

  String getValueText(int value) {
    String _valueText = value.toString();
    if (value == 99) {
      _valueText = "All";
    }
    return _valueText;
  }

  String getDisplayDate() {
    if (DateFormat.yMd().format(selectedDate) == DateFormat.yMd().format(DateTime.now().toLocal())) {
      displayDate = "Today";
    } else {
      displayDate = DateFormat('EEE, MMM d, ' 'yyyy').format(selectedDate);
    }
    return displayDate;
  }
  Widget buildShowDate() {
    getDisplayDate();
    final pastOrdersViewModel = context.read(pastOrdersProvider);
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: GestureDetector(
          onTap: () async {
            await _selectDate(context);
            getDisplayDate();
              if (_previousSelectedDate != selectedDate) {
                _previousSelectedDate = selectedDate;
                pastOrdersViewModel.orderDateTime = selectedDate;
              }
          },
          child: Row(
            children: [
              Tooltip(
                message: "Tap here to change date",
                showDuration: Duration(seconds: 1),
                textStyle: kTextInputStyle,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            //color: Colors.blue.shade200,
                          border: Border.all(color: Colors.orangeAccent, width: 2)
                        ),

                    child: Text(
                      "$displayDate",
                      style: kTextInputStyle,
                    )),
              ),
            ],
          ),
        ));
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      currentDate: DateTime.now(),

      context: context,
      initialDate: selectedDate,
      // Refer step 1
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 2021,
              maximumYear: DateTime.now().year,
            ),
          );
        });
  }

  Widget buildShowTick(String noOfRecs) {
    if (noOfRecs == _selectedValue.toString()) {
      return Padding(padding: EdgeInsets.only(right: 3),
        child: Icon(Icons.done_sharp, size: 16,),
      );
    }
    else {
      return Padding(padding: EdgeInsets.symmetric(horizontal: 10));
    }
  }
  Widget buildShowRecordsWidget() {
    final pastOrdersViewModel = context.read(pastOrdersProvider);
    return PopupMenuButton(
      child: Row(
        children: [
          Icon(Icons.list),
          Text(
            "Showing ${getValueText(_selectedValue)} Orders",
            style: kTextInputStyle,
          ),
        ],
      ),

      //icon: Icon(Icons.list),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildShowTick("10"),
              Text(
                "Show 10 Records",
                style: kNumberTextStyle,
              ),
            ],
          ),
          value: 10,
        ),
        PopupMenuItem(
          child: Row(
            children: [
              buildShowTick("20"),
              Text(
                "Show 20 Records",
                style: kNumberTextStyle,
              ),
            ],
          ),
          value: 20,
        ),
        PopupMenuItem(
          child: Row(
            children: [
              buildShowTick("30"),
              Text(
                "Show 30 Records",
                style: kNumberTextStyle,
              ),
            ],
          ),
          value: 30,
        ),
        PopupMenuItem(
          child: Row(
            children: [
              buildShowTick("99"),
              Text(
                "Show All Records",
                style: kNumberTextStyle,
              ),
            ],
          ),
          value: 99,
        ),
      ],

      onSelected: (value) {
        setState(() {
          _selectedValue = value;
          pastOrdersViewModel.recordsLimit = value;
        });
        print("Selected Value $value");
      },
      enabled: true,
      elevation: 2,
    );
  }

  Widget buildShowNoOfOrders() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          buildShowRecordsWidget(),
        ],
      ),
    );
  }

  Widget buildAddFilterButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (filterApplied) {
              filterApplied = false;
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Filter Cleared", style: TextStyle(color: Colors.black),),

                backgroundColor: Colors.lightBlue,
                duration: Duration(milliseconds: 1000),
              ));
            }
            else {
              showFilters = !showFilters;
            }

          });
          print("Filter");
        },
        child: Text(
          "${filterApplied ? "- Clear Filter" : "+ Add Filter"}",
          style: k14BoldBlue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: buildShowDate()),
              buildShowNoOfOrders(),

              //Expanded(child: buildAddFilterButton(context)),
            ],
          ),
          Visibility(
              visible: showFilters,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilterInputWidget(
                  applyFilterFunction: () {
                    // setState(() {
                    //   showFilters = false;
                    //   if (orderListFilterViewModel.filterApplied) {
                    //     filterApplied = true;
                    //   }
                    //
                    // });
                  },

                ),
              ))
        ],
      ),
    );
  }
}


