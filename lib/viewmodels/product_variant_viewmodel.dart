import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/models/product_variants.dart';
import 'package:subbonline_storeadmin/services/measurement_units_service.dart';
import 'package:subbonline_storeadmin/viewmodels/product_options_view_model.dart';

final productVariantViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) => ProductVariantViewModel(ref.watch(productOptionsViewModelProvider)));

class ProductVariantViewModel extends ChangeNotifier {
  ProductVariantViewModel(this.productOptionsViewModel);

  final ProductOptionsViewModel productOptionsViewModel;

  List<ProductVariants> variants;
  List<Widget> variantsLayout;

  ViewState _state = ViewState.Idle;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<ProductVariants> prepareVariants() {
    final MeasurementUnitsService _measurementUnitsService = MeasurementUnitsService();
    int _variantId = 0;
    List<ProductVariants> _productVariants = [];
    // if (productOptionsViewModel.selectedUnitValue != null) {
    //   productOptionsViewModel.selectedUnitValue.removeWhere((element) => element == null);
    // }
    if (productOptionsViewModel.selectedSizes != null) {
      productOptionsViewModel.selectedSizes.removeWhere((element) => element == null);
    }
    if (productOptionsViewModel.selectedColors != null) {
      productOptionsViewModel.selectedColors.removeWhere((element) => element == null);
    }
    print(
        "Inside Variant prep 1 ${productOptionsViewModel.selectedUnitValue} ${productOptionsViewModel.selectedUnitValue.length}");
    print("Inside Variant prep 2 ${productOptionsViewModel.selectedSizes}");
    print("Inside Variant prep 3 ${productOptionsViewModel.selectedUnits}");

    for (var size in productOptionsViewModel.selectedSizes) {
      var _measurementUnit = _measurementUnitsService.getMeasurementUnitOfSize(size);
      if (_measurementUnit == null) {
        return null;
      } else {
        if (_measurementUnit.customSizeRequired == 'Y') {
          if (productOptionsViewModel.selectedUnitValue == null ||
              productOptionsViewModel.selectedUnitValue.length == 0) {
            return null;
          }
        }
      }
    }

    if (productOptionsViewModel.selectedSizes != null &&
        productOptionsViewModel.selectedSizes.length == 1 &&
        (productOptionsViewModel.selectedColors.length == 0 && productOptionsViewModel.selectedUnits.length == 0)) {
      return null;
    }
    if (productOptionsViewModel.selectedSizes != null &&
        productOptionsViewModel.selectedSizes.length > 0 &&
        productOptionsViewModel.selectedColors != null &&
        productOptionsViewModel.selectedColors.length > 0) {
      productOptionsViewModel.selectedSizes.forEach((size) {
        productOptionsViewModel.selectedColors.forEach((color) {
          _variantId++;
          _productVariants.add(ProductVariants(
            productVariantId: _variantId,
            size: size,
            color: color,
          ));
        });
      });
      return _productVariants;
    } else if (productOptionsViewModel.selectedSizes != null &&
        productOptionsViewModel.selectedSizes.length > 0 &&
        productOptionsViewModel.selectedUnitValue != null &&
        productOptionsViewModel.selectedUnitValue.length > 0 &&
        productOptionsViewModel.selectedUnits != null &&
        productOptionsViewModel.selectedUnits.length > 0) {
      print(productOptionsViewModel.selectedUnits);
      int idx = 0;
      for (var unitValue in productOptionsViewModel.selectedUnitValue) {
        var size = productOptionsViewModel.selectedUnits[idx];
        idx++;
        if (unitValue == null) continue;
        _variantId++;
        _productVariants.add(ProductVariants(
          productVariantId: _variantId,
          size: size,
          unitValue: double.parse(unitValue),
        ));
      }

      return _productVariants;
    } else if (productOptionsViewModel.selectedSizes != null && productOptionsViewModel.selectedSizes.length > 0) {
      productOptionsViewModel.selectedSizes.forEach((size) {
        _variantId++;
        _productVariants.add(ProductVariants(
          productVariantId: _variantId,
          size: size,
        ));
      });

      return _productVariants;
    }

    return null;
  }
}

class PermutationAlgorithmStrings {
  final List<List<String>> elements;

  PermutationAlgorithmStrings(this.elements);

  List<List<String>> permutations() {
    List<List<String>> perms = [];
    generatePermutations(elements, perms, 0, []);
    return perms;
  }

  void generatePermutations(List<List<String>> lists, List<List<String>> result, int depth, List<String> current) {
    if (depth == lists.length) {
      result.add(current);
      return;
    }

    for (int i = 0; i < lists[depth].length; i++) {
      generatePermutations(lists, result, depth + 1, [...current, lists[depth][i]]);
    }
  }
}
