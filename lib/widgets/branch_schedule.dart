import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:subbonline_storeadmin/viewmodels/branch_schedule_view_model.dart';

import '../constants.dart';
import '../providers_general.dart';
import '../utility/utility_functions.dart';
import 'custom_form_input_field.dart';

class BranchScheduleWidget extends StatefulWidget {
  const BranchScheduleWidget({Key key}) : super(key: key);

  @override
  _BranchScheduleWidgetState createState() => _BranchScheduleWidgetState();
}

class _BranchScheduleWidgetState extends State<BranchScheduleWidget> {
  TimeOfDay selectedTime = TimeOfDay(hour: 18, minute: 00);
  var weekDays = getDaysOfWeek();

  List<TimeOfDay> _fromTime = List.generate(7, (index) => TimeOfDay(hour: 08, minute: 00));
  List<TimeOfDay> _toTime = List.generate(
      7,
      (index) => TimeOfDay(
            hour: 20,
            minute: 00,
          ));
  List<BranchTimings> _branchTimings;

  List<BranchTimings> getDefaultBranchTimings() {
    TimeClass _startTime = TimeClass(hour: 08, minute: 00, period: "AM");
    TimeClass _endTime = TimeClass(hour: 20, minute: 00, period: "PM");

    _branchTimings = List.generate(
        7, (index) => BranchTimings(day: weekDays[index], fromTime: _startTime, toTime: _endTime, openFlag: 'Y'));
    return _branchTimings;
  }

  String _hour, _minute, _time;

  onTimingsChange(int index, TimeOfDay fromTime, TimeOfDay toTime) {
    int hour;
    int minute;
    String period;
    if (index >= 0) {
      if (fromTime != null) {
        final branchScheduleViewModel = context.read(branchScheduleViewProvider);
        hour = fromTime.hour;
        minute = fromTime.minute;
        period = fromTime.period.toString().split(".")[1].toUpperCase();
        if (hour > 12) {
          hour = hour - 12;
        }
        branchScheduleViewModel.fromTime[index] = TimeClass(hour: hour, minute: minute, period: period);
      }
      if (toTime != null) {
        final branchScheduleViewModel = context.read(branchScheduleViewProvider);
        hour = toTime.hour;
        minute = toTime.minute;
        period = toTime.period.toString().split(".")[1].toUpperCase();
        if (hour > 12) {
          hour = hour - 12;
        }
        branchScheduleViewModel.toTime[index] = TimeClass(hour: hour, minute: minute, period: period);
      }
    }
  }

  TimeOfDay convert12HourTimeTo24Hour(TimeClass timeClass) {
    int hour = timeClass.hour;
    int minute = timeClass.minute;

    if (timeClass.period == "PM") {
      hour = hour + 12;
    }
    return TimeOfDay(hour: hour, minute: minute);

  }

  List<Widget> buildStoreTimings(BranchScheduleViewModel model) {
    _branchTimings = model.getBranchTimings();

    return List.generate(_branchTimings.length, (index) {
      TimeOfDay _fromTime =
          TimeOfDay(hour: convert12HourTimeTo24Hour(_branchTimings[index].fromTime).hour, minute: convert12HourTimeTo24Hour(_branchTimings[index].fromTime).minute,);
      TimeOfDay _toTime =
      TimeOfDay(hour: convert12HourTimeTo24Hour(_branchTimings[index].toTime).hour, minute: convert12HourTimeTo24Hour(_branchTimings[index].toTime).minute,);
      return Row(
        children: [
          SizedBox(
            width: 72,
              child: Text("${_branchTimings[index].day}")),
          Expanded(
            flex: 2,
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(60, 25)),
              child: Switch(
                  splashRadius: 15,
                  value: model.openFlag[index] == "Y",
                  onChanged: (value) {
                    if (value) {
                      model.openFlag[index] = "Y";
                    } else {
                      model.openFlag[index] = "N";
                    }
                    model.buildState();
                  }),
            ),
          ),
          Expanded(
            flex: 7,
            child: OpenCLoseTimingWidget(
              index: index,
              fromTime: _fromTime,
              toTime: _toTime,
              enable: model.openFlag[index] == "Y",
              onChangeFunction: onTimingsChange,
            ),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final branchScheduleViewModel = watch(branchScheduleViewProvider);
      return Container(
        child: CustomScrollView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Store Open/Close Timings",
                  style: kNameTextStyle15,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: buildStoreTimings(branchScheduleViewModel),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
enum BranchTimingEnum {FromTime, ToTime}

class OpenCLoseTimingWidget extends StatefulWidget {
  final index;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final Function onChangeFunction;
  final bool enable;

  OpenCLoseTimingWidget({Key key, this.index, this.fromTime, this.toTime, this.onChangeFunction, this.enable})
      : super(key: key);

  @override
  _OpenCLoseTimingWidgetState createState() => _OpenCLoseTimingWidgetState();
}

class _OpenCLoseTimingWidgetState extends State<OpenCLoseTimingWidget> {
  final TextEditingController fromTimeController = TextEditingController();

  final TextEditingController toTimeController = TextEditingController();

  TimeOfDay selectedFromTime;
  TimeOfDay selectedToTime;

  @override
  void initState() {
    super.initState();
    selectedFromTime = widget.fromTime;
    selectedToTime = widget.toTime;
  }


  @override
  void didUpdateWidget(OpenCLoseTimingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromTime != widget.fromTime) {
      selectedFromTime = widget.fromTime;
    }
    else if  (oldWidget.toTime != widget.toTime) {
      selectedToTime = widget.toTime;
    }

  }

  Future<void> _selectTime(BuildContext context, TextEditingController timeController, TimeOfDay selectedTime, BranchTimingEnum branchTimingEnum) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime, initialEntryMode: TimePickerEntryMode.input);
    if (picked != null)
      setState(() {
        selectedTime = picked;
        timeController.text = formatTime(selectedTime);
        if (branchTimingEnum == BranchTimingEnum.FromTime) {
          widget.onChangeFunction(widget.index,selectedTime, null );
        }
        else if (branchTimingEnum == BranchTimingEnum.ToTime) {
          widget.onChangeFunction(widget.index,null, selectedTime);
        }
      });
  }

  String formatTime(TimeOfDay timeOfDay) {
    String hour;
    String minute;
    String time;

    int intHour = timeOfDay.hour;
    if (intHour > 12) {
      intHour = intHour - 12;
    }

    hour = intHour.toString().padLeft(2, '0');
    minute = timeOfDay.minute.toString().padLeft(2, '0');
    time = hour + ' : ' + minute + ' ' + "${timeOfDay.period.toString().split(".")[1].toUpperCase()}";

    return time;
  }

  buildOpenCloseTimeWidget(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //Container(width: 40, child: Text("Time")),
        InkWell(
          onTap: () async {
            await _selectTime(context, fromTimeController, selectedFromTime, BranchTimingEnum.FromTime);
            setState(() {});
          },
          child: Container(
            child: IgnorePointer(
              child: CustomInputFormField(
                  textEditingController: fromTimeController,
                  //textInputType: TextInputType.,
                  textInputType: TextInputType.numberWithOptions(),
                  hintText: "From Time",
                  //initialValue: "00 : 00",
                  //helperText: "Please enter user login id.",
                  obscureText: false,
                  dbValue: formatTime(selectedFromTime),
                  enable: true,
                  maxLength: 25,
                  autoFocus: false,
                  textInputAction: TextInputAction.none,
                  // onSaveFunction: () async {
                  //   await _selectTime(context,fromTimeController);
                  // },
                  contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  height: 35,
                  width: 76),
            ),
          ),
        ),

        InkWell(
          onTap: () async {
            await _selectTime(context, toTimeController, selectedToTime, BranchTimingEnum.ToTime);
            setState(() {});
          },
          child: Container(
            child: IgnorePointer(
              child: CustomInputFormField(
                  textEditingController: toTimeController,
                  textInputType: TextInputType.numberWithOptions(),
                  hintText: "To Time",
                  //helperText: "Please enter user login id.",
                  obscureText: false,
                  //prefixIcon: Icons.login,
                  //suffixIcon: Icons.close,
                  dbValue: formatTime(selectedToTime),
                  enable: true,
                  autoFocus: false,
                  maxLength: 25,
                  textInputAction: TextInputAction.next,
                  contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  height: 35,
                  width: 76),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enable == null || widget.enable == false) {
      return Padding(
        padding: const EdgeInsets.all(14.5),
        child: Text(
          "Branch Close",
          style: k14BoldRed,
        ),
      );
    } else {
      return buildOpenCloseTimeWidget(widget.index);
    }
  }
}
