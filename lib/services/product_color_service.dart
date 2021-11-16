

import 'package:subbonline_storeadmin/models/product_colors.dart';
import 'package:subbonline_storeadmin/repository/product_colors_repository.dart';

class ProductColorService {

  List<ProductColors> getAvailableColors() {
    return productColors.map((e) => ProductColors.fromJson(e)).toList();
  }

  String getColorName(String colorHex){
    var availableColors = getAvailableColors();
    var _productColor = availableColors.firstWhere((color) => color.color == colorHex);
    return _productColor.name;
  }

}