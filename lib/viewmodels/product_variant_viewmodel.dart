import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/shelf.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/services/measurement_units_service.dart';
import 'package:subbonline_storeadmin/viewmodels/product_options_view_model.dart';

final productVariantViewModelProvider =
    ChangeNotifierProvider((ref) => ProductVariantViewModel(ref.watch(productOptionsViewModelProvider)));

class ProductVariantViewModel extends ChangeNotifier {
  ProductVariantViewModel(this.productOptionsViewModel);

  final ProductOptionsViewModel productOptionsViewModel;

  String errorMessage;

  List<ProductVariants> variants;
  List<ProductVariants> variantsToSave;
  List<Widget> variantsLayout;

  ViewState _state = ViewState.Idle;

  ViewState get state => _state;

  void initialise() {
    errorMessage = null;
    variants = null;
    variantsToSave = null;
    variantsLayout = null;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  rebuildVariants() {
    this.variants = prepareVariants();
    notifyListeners();
  }

  double _price = 0;
  double _surcharge = 0;
  int _quantity = 0;
  List<String> _imageUrl;

  setBaseProductVariant(int variantId) {
    productOptionsViewModel.baseProductVariantId = variantId;
  }

  int getBaseProductVariantId() {
    return productOptionsViewModel.baseProductVariantId;
  }

  removeVariant(int index) {
    //productOptionsViewModel.setState(ViewState.Busy);
    if (this.variants.length >= index+1) {
      this.variants.removeAt(index);
    }
    if (this.variantsToSave.length >= index+1) {
      this.variantsToSave.removeAt(index);
    }
    // if (productOptionsViewModel.selectedSizes.length >= index+1) {
    //   productOptionsViewModel.selectedSizes.removeAt(index);
    // }
    if (productOptionsViewModel.selectedColors.length >= index+1) {
      productOptionsViewModel.selectedColors.removeAt(index);
      if (productOptionsViewModel.selectedColors.length == 0) {
        productOptionsViewModel.colors = 'N';
      }
    }

    if (productOptionsViewModel.selectedUnits.length >= index+1) {
      productOptionsViewModel.selectedUnits.removeAt(index);
    }
    if (productOptionsViewModel.selectedUnitValue.length >= index+1) {
      productOptionsViewModel.selectedUnitValue.removeAt(index);
    }
    if (productOptionsViewModel.productVariantId.length >= index+1) {
      productOptionsViewModel.productVariantId.removeAt(index);
      if (productOptionsViewModel.productVariantId.length > 0) {
        for (int idx = 0; idx < productOptionsViewModel.productVariantId.length ; idx++ ) {
          productOptionsViewModel.productVariantId[idx] = idx+1;
        }
      }

    }
    if (productOptionsViewModel.imageUrl.length >= index+1) {
      productOptionsViewModel.imageUrl.removeAt(index);
    }
    if (productOptionsViewModel.quantity.length >= index+1) {
      productOptionsViewModel.quantity.removeAt(index);
    }
    if (productOptionsViewModel.price.length >= index+1) {
      productOptionsViewModel.price.removeAt(index);
    }
    if (productOptionsViewModel.surcharge.length >= index+1) {
      productOptionsViewModel.surcharge.removeAt(index);
    }
    productOptionsViewModel.selectedUnitValue.removeWhere((element) => element == null);
    if (productOptionsViewModel.selectedUnitValue.length == 0) {
      productOptionsViewModel.selectedUnits = [];
    }
    if (productOptionsViewModel.selectedUnits.length == 0 && productOptionsViewModel.selectedUnitValue.length ==0 ) {
      productOptionsViewModel.selectedSizes = [];
      productOptionsViewModel.sizes = 'N';
      print("Removed Sizes");
      productOptionsViewModel.setState(ViewState.Busy);
    }
    //setState(ViewState.Idle);

  }

  List<ProductVariants> prepareVariants() {
    final MeasurementUnitsService _measurementUnitsService = MeasurementUnitsService();
    int _variantId = 0;
    List<ProductVariants> _productVariants = [];

    // var _selectedUnitValue = productOptionsViewModel.selectedUnitValue;
    // if (_selectedUnitValue != null) {
    //   _selectedUnitValue.removeWhere((element) => element == null);
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

    if (productOptionsViewModel.sizes != "Y" && productOptionsViewModel.colors != "Y") {
      return null;
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
          if (productOptionsViewModel.price != null && productOptionsViewModel.price.length > _variantId) {
            _price = double.tryParse(productOptionsViewModel.price[_variantId]);
          } else
            _price = 0;
          if (productOptionsViewModel.surcharge != null && productOptionsViewModel.surcharge.length > _variantId) {
            _surcharge = double.tryParse(productOptionsViewModel.surcharge[_variantId]);
          } else
            _surcharge = 0;

          if (productOptionsViewModel.quantity != null && productOptionsViewModel.quantity.length > _variantId) {
            _quantity = int.tryParse(productOptionsViewModel.quantity[_variantId]);
          } else
            _quantity = 0;

          if (productOptionsViewModel.imageUrl != null && productOptionsViewModel.imageUrl.length > _variantId) {
            _imageUrl = productOptionsViewModel.imageUrl[_variantId];
          } else
            _imageUrl = null;

          if (productOptionsViewModel.productVariantId != null && productOptionsViewModel.productVariantId.length > _variantId) {
            _variantId = productOptionsViewModel.productVariantId[_variantId];
          } else
            _variantId++;

          _productVariants.add(ProductVariants(
              productVariantId: _variantId,
              baseProduct: productOptionsViewModel.baseProductVariantId == _variantId ? "Y": "N",
              size: size,
              color: color,
              price: _price ?? 0,
              surcharge: _surcharge ?? 0,
              quantity: _quantity ?? 0,
              imageUrl: _imageUrl));
        });
      });
      return _productVariants;
    } else if (productOptionsViewModel.selectedSizes != null &&
        productOptionsViewModel.selectedSizes.length > 0 &&
        productOptionsViewModel.selectedUnitValue != null &&
        productOptionsViewModel.selectedUnitValue.length > 0 &&
        productOptionsViewModel.selectedUnits != null &&
        productOptionsViewModel.selectedUnits.length > 0) {

      int idx = 0;
      for (var unitValue in productOptionsViewModel.selectedUnitValue) {
        var size = productOptionsViewModel.selectedUnits[idx];
        idx++;
        if (unitValue == null) continue;
        if (double.tryParse(unitValue) == null) {
          errorMessage = "Invalid value $unitValue";
          throw Exception(errorMessage);
        }
        if (productOptionsViewModel.price != null && productOptionsViewModel.price.length > _variantId) {
          _price = double.tryParse(productOptionsViewModel.price[_variantId]);
          print("Set Price ${_price}");
        } else
          _price = 0;
        if (productOptionsViewModel.surcharge != null && productOptionsViewModel.surcharge.length > _variantId) {
          _surcharge = double.tryParse(productOptionsViewModel.surcharge[_variantId]);
        } else
          _surcharge = 0;

        if (productOptionsViewModel.quantity != null && productOptionsViewModel.quantity.length > _variantId) {
          _quantity = int.tryParse(productOptionsViewModel.quantity[_variantId]);
        } else
          _quantity = 0;

        if (productOptionsViewModel.imageUrl != null && productOptionsViewModel.imageUrl.length > _variantId) {
          _imageUrl = productOptionsViewModel.imageUrl[_variantId];
        } else
          _imageUrl = null;

        if (productOptionsViewModel.productVariantId != null && productOptionsViewModel.productVariantId.length > _variantId) {
          _variantId = productOptionsViewModel.productVariantId[_variantId];
        } else
          _variantId++;

        _productVariants.add(ProductVariants(
            productVariantId: _variantId,
            baseProduct: productOptionsViewModel.baseProductVariantId == _variantId ? "Y": "N",
            size: size,
            unitValue: double.parse(unitValue),
            price: _price ?? 0,
            surcharge: _surcharge ?? 0,
            quantity: _quantity ?? 0,
            imageUrl: _imageUrl));
      }

      return _productVariants;
    } else if (productOptionsViewModel.selectedSizes != null && productOptionsViewModel.selectedSizes.length > 0) {
      print("Size Only Variant");
      productOptionsViewModel.selectedSizes.forEach((size) {

        if (productOptionsViewModel.price != null && productOptionsViewModel.price.length > _variantId) {
          _price = double.tryParse(productOptionsViewModel.price[_variantId]);
        } else
          _price = 0;
        if (productOptionsViewModel.surcharge != null && productOptionsViewModel.surcharge.length > _variantId) {
          _surcharge = double.tryParse(productOptionsViewModel.surcharge[_variantId]);
        } else
          _surcharge = 0;

        if (productOptionsViewModel.quantity != null && productOptionsViewModel.quantity.length > _variantId) {
          _quantity = int.tryParse(productOptionsViewModel.quantity[_variantId]);
        } else
          _quantity = 0;

        if (productOptionsViewModel.imageUrl != null && productOptionsViewModel.imageUrl.length > _variantId) {
          _imageUrl = productOptionsViewModel.imageUrl[_variantId];
        } else
          _imageUrl = null;

        if (productOptionsViewModel.productVariantId != null && productOptionsViewModel.productVariantId.length > _variantId) {
          _variantId = productOptionsViewModel.productVariantId[_variantId];
        } else
          _variantId++;

        _variantId++;
        _productVariants.add(ProductVariants(
            productVariantId: _variantId,
            baseProduct: productOptionsViewModel.baseProductVariantId == _variantId ? "Y": "N",
            size: size,
            price: _price ?? 0,
            surcharge: _surcharge ?? 0,
            quantity: _quantity ?? 0,
            imageUrl: _imageUrl));
      });
      print("Product Variants Prepared");
      variantsToSave = _productVariants;
      return _productVariants;
    }

    return null;
  }

  saveVariants(ProductVariants productVariant, double price, double surcharge, int qty, String baseProduct) {
    if (variantsToSave == null) {
      variantsToSave = [];
    }
    ProductVariants _productVariant = ProductVariants(
        productVariantId: productVariant.productVariantId,
        size: productVariant.size,
        color: productVariant.color,
        baseProduct: baseProduct,
        unitValue: productVariant.unitValue,
        imageUrl: productVariant.imageUrl,
        price: price,
        surcharge: surcharge,
        quantity: qty);
    variantsToSave.add(_productVariant);
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
