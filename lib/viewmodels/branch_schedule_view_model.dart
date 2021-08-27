import 'package:flutter/foundation.dart';

import '../models/store.dart';
import '../utility/utility_functions.dart';

class BranchScheduleViewModel extends ChangeNotifier {
  List<BranchTimings> _branchTimings;

  List<String> day = [];
  List<String> openFlag = [];
  List<TimeClass> fromTime = [];
  List<TimeClass> toTime = [];

  setBranchTimings(List<BranchTimings> branchTimings) {
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

  setDefaultBranchSchedule() {
    var weekDays = getDaysOfWeek();
    TimeClass _startTime = TimeClass(hour: 08, minute: 00, period: "AM");
    TimeClass _endTime = TimeClass(hour: 20, minute: 00, period: "PM");

    _branchTimings = List.generate(
        7, (index) => BranchTimings(day: weekDays[index], fromTime: _startTime, toTime: _endTime, openFlag: 'Y'));
    setBranchTimings(_branchTimings);
  }

  buildState() {
    notifyListeners();
  }
}
