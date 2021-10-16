import 'package:flutter/foundation.dart';
import 'package:models/shelf.dart';

import '../utility/utility_functions.dart';

class BranchScheduleViewModel extends ChangeNotifier {
  List<BranchTimings> _branchTimings;

  List<String> day = [];
  List<String> openFlag = [];
  List<TimeClass> fromTime = [];
  List<TimeClass> toTime = [];



  initialise() {
    _branchTimings = null;
  }

  setBranchTimings(List<BranchTimings> branchTimings) {
    day = branchTimings.map((e) => e.day).toList();
    openFlag = branchTimings.map((e) => e.openFlag).toList();
    fromTime = branchTimings.map((e) => e.fromTime).toList();
    toTime = branchTimings.map((e) => e.toTime).toList();
    _branchTimings = branchTimings;
    notifyListeners();
  }

  setDefaultBranchTimings(List<BranchTimings> branchTimings) {
    day = branchTimings.map((e) => e.day).toList();
    openFlag = branchTimings.map((e) => e.openFlag).toList();
    fromTime = branchTimings.map((e) => e.fromTime).toList();
    toTime = branchTimings.map((e) => e.toTime).toList();
    _branchTimings = branchTimings;
  }

  List<BranchTimings> getBranchTimings() {
    if (_branchTimings == null) {
      setDefaultBranchSchedule();
    }
    return _branchTimings;
  }

  void updateBranchTimings() {
    var weekDays = getDaysOfWeek();
    _branchTimings = List.generate(7, (index) =>
        BranchTimings(
          day: weekDays[index],
          openFlag: openFlag[index],
          fromTime: fromTime[index],
          toTime: toTime[index]
        ));
  }

  setDefaultBranchSchedule() {
    var weekDays = getDaysOfWeek();
    TimeClass _startTime = TimeClass(hour: 08, minute: 00, period: "AM");
    TimeClass _endTime = TimeClass(hour: 08, minute: 00, period: "PM");

    _branchTimings = List.generate(
        7, (index) => BranchTimings(day: weekDays[index], fromTime: _startTime, toTime: _endTime, openFlag: 'Y'));
    setDefaultBranchTimings(_branchTimings);
  }

  buildState() {
    notifyListeners();
  }
}
