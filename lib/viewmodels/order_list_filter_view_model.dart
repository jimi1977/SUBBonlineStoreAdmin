



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrderListFilterViewModel extends ChangeNotifier {

  bool filterApplied = false;

  String receiverName;
  double fromPrice;
  double toPrice;
  DateTime orderDate;
  TimeOfDay fromTime;
  TimeOfDay toTime;

  setFilterApplied() {

    filterApplied = true;
    notifyListeners();
  }

  removeFilter() {
    filterApplied = false;
    notifyListeners();
  }

  bool filterValuesProvided() {
    bool _filterProvided = false;

    if (receiverName != null || fromPrice != null || toPrice != null || fromTime != null || toTime != null) {
      _filterProvided = true;
    }
    return _filterProvided;

  }

  clearFilter() {
    receiverName = null;
    fromPrice = null;
    toPrice = null;
    orderDate = null;
    fromTime = null;
    toTime = null;
    if (filterApplied) {
      filterApplied = false;
      notifyListeners();
    }

  }



}