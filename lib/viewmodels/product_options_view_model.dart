import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';


import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/services/measurement_units_service.dart';

final productOptionsViewModelProvider = ChangeNotifierProvider<ProductOptionsViewModel>((ref) => ProductOptionsViewModel());

class ProductOptionsViewModel with ChangeNotifier {

  final MeasurementUnitsService _measurementUnitsService = MeasurementUnitsService();

  ProductOptionsViewModel();

  String _selectedUnit;
  String _sizes;
  String _colors;
  String _accessory;
  String _salesTax;
  String _maintainInventory;

  List<int> productVariantId = [];
  List<String> selectedSizes = [];
  List<String> selectedColors = [];
  List<String> selectedUnits = [];
  List<String> selectedUnitValue = [];
  List<String> price      = [];
  List<String> surcharge  = [];
  List<String> quantity   = [];
  int baseProductVariantId;
  List<List<String>> imageUrl = [];
  List<ProductVariants> retrievedVariants = [];

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

  void initialise() {
    _selectedUnit = null;
    _sizes = null;
    _colors = null;
    _accessory = null;
    _salesTax = null;
    _maintainInventory = null;
    baseProductVariantId = null;
    selectedSizes = [];
    selectedColors = [];
    selectedUnits = [];
    selectedUnitValue = [];
    price      = [];
    surcharge  = [];
    quantity   = [];
    imageUrl = [];
    productVariantId = [];
    retrievedVariants = [];

  }

  @override
  String toString() {
    return 'ProductOptionsViewModel{_selectedUnit: $_selectedUnit, _sizes: $_sizes, _colors: $_colors, _accessory: $_accessory, _salesTax: $_salesTax, _maintainInventory: $_maintainInventory, selectedSizes: $selectedSizes, selectedColors: $selectedColors, selectedUnits: $selectedUnits, selectedUnitValue: $selectedUnitValue}';
  }
}
