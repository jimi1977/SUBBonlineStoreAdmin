class Measurements {
  String code;
  String name;
  String customSizeRequired;
  List<Units> units;

  Measurements({this.code, this.name, this.customSizeRequired, this.units});

  Measurements.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    customSizeRequired = json['customSizeRequired'];
    if (json['units'] != null) {
      units = [];
      json['units'].forEach((v) {
        units.add(new Units.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['customSizeRequired'] = this.customSizeRequired;
    if (this.units != null) {
      data['units'] = this.units.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Units {
  String unit;
  String name;

  Units({this.unit, this.name});

  Units.fromJson(Map<String, dynamic> json) {
    unit = json['unit'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unit'] = this.unit;
    data['name'] = this.name;
    return data;
  }
}
