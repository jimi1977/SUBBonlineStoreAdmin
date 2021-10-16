class ProductColors {
  String color;
  String name;

  ProductColors({this.color, this.name});

  ProductColors.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['name'] = this.name;
    return data;
  }
}
