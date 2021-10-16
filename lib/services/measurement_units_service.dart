


import 'package:subbonline_storeadmin/models/measurements.dart';
import 'package:subbonline_storeadmin/repository/sizes_repository.dart';

class MeasurementUnitsService {


  List<Measurements> getUnits() {
    return sizes.map((e) => Measurements.fromJson(e)).toList();
  }

  Measurements getMeasurementUnitProperties(String measurementCode) {
    var units = getUnits();
    return units.firstWhere((element) => element.code == measurementCode, orElse: () => Measurements());

  }

  List<Units> getMeasurementUnitSizes(String unitCode) {
    var units = getUnits();
    var unit = units.firstWhere((element) => element.code == unitCode, orElse: () => null);

    return unit.units;
  }

  String getSizeName(String size) {
    String unitName;
    var units = getUnits();
    for (var unit in units) {
      var _unit = unit.units.firstWhere((element) => element.unit == size, orElse: () => null);
      if (_unit != null) {
        unitName = _unit.name;
      }
    }
    return unitName;
  }

  Measurements getMeasurementUnitOfSize(String size) {
    var units = getUnits();
    for (var unit in units) {
      var _unit = unit.units.firstWhere((element) => element.unit == size, orElse: () => null);
      if (_unit != null) {
        return unit;
      }
    }
    return null;

  }

  Units getUnitsProperties(String unitCode) {
    var units = getUnits();
    for (var unit in units) {
      var _unit = unit.units.firstWhere((element) => element.unit == unitCode, orElse: () => null);
      if (_unit != null) {
        return _unit;
      }
    }
    return null;
  }
}