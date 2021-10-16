import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:subbonline_storeadmin/enums/viewstate.dart';

final productOptionsViewModelProvider = ChangeNotifierProvider.autoDispose<ProductOptionsViewModel>((ref) => ProductOptionsViewModel());

class ProductOptionsViewModel with ChangeNotifier {

  ProductOptionsViewModel();

  String _selectedUnit;
  String _sizes;
  String _colors;
  String _accessory;
  String _salesTax;
  String _maintainInventory;

  List<String> selectedSizes = [];
  List<String> selectedColors = [];
  List<String> selectedUnits = [];
  List<String> selectedUnitValue = [];

  Set<Map<String, dynamic>> customUnitsValues = Set();

  ViewState _state = ViewState.Idle;

  ViewState get state => _state;


  String get selectedUnit => _selectedUnit;

  set selectedUnit(String value) {
    _selectedUnit = value;
  }

  String get sizes => _sizes;

  set sizes(String value) {
    _sizes = value;
  }

  String get colors => _colors;

  set colors(String value) {
    _colors = value;
  }

  String get salesTax => _salesTax;

  set salesTax(String value) {
    _salesTax = value;
  }

  String get accessory => _accessory;

  set accessory(String value) {
    _accessory = value;
  }


  String get maintainInventory => _maintainInventory;

  set maintainInventory(String value) {
    _maintainInventory = value;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  @override
  String toString() {
    return 'ProductOptionsViewModel{_selectedUnit: $_selectedUnit, _sizes: $_sizes, _colors: $_colors, _accessory: $_accessory, _salesTax: $_salesTax, selectedSizes: $selectedSizes, selectedColors: $selectedColors, selectedUnits: $selectedUnits, selectedUnitValue: $selectedUnitValue, customUnitsValues: $customUnitsValues, _state: $_state}';
  }
}
