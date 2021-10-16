

import 'package:subbonline_storeadmin/models/product_colors.dart';
import 'package:subbonline_storeadmin/repository/product_colors_repository.dart';

class ProductColorService {

  List<ProductColors> getAvailableColors() {
    return productColors.map((e) => ProductColors.fromJson(e)).toList();
  }


}