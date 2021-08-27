

import 'package:flutter/foundation.dart';

class PastOrdersViewModel extends ChangeNotifier{

  DateTime _orderDateTime = DateTime.now();
  int _recordsLimit = 10;

  DateTime get orderDateTime => _orderDateTime;

  set orderDateTime(DateTime value) {
    _orderDateTime = value;
    print("DateTime Set");
    notifyListeners();
  }

  int get recordsLimit => _recordsLimit;

  set recordsLimit(int value) {
    _recordsLimit = value;
    notifyListeners();
  }
}