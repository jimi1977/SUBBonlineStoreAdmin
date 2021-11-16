






import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/product_variants.dart';
import 'package:subbonline_storeadmin/enums/viewstate.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_viewmodel.dart';

final productVariantImagesViewModelProvider = ChangeNotifierProvider((ref) =>
ProductVariantImagesViewModel(ref.watch(productVariantViewModelProvider.notifier))
  );

class ProductVariantImagesViewModel extends ChangeNotifier {



  final ProductVariantViewModel productVariantViewModel;

  ProductVariantImagesViewModel(this.productVariantViewModel);

  ViewState _state;


  List<Map<String, dynamic>> variantImages = [];
  List<ProductImage> retrievedImages = [];

  initialise() {
    retrievedImages = [];
    variantImages = [];
  }


  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<ProductVariants> getVariants() {
    return productVariantViewModel.variants;
  }

  List<ProductImage> getVariantImages(int productVariantId ) {
    List<ProductImage> productImages;
    // if (productVariantViewModel.variants != null) {
    //   var variant = productVariantViewModel.variants.firstWhere((element) => element.productVariantId == productVariantId);
    //   if (variant != null) {
    //     productImages = variant.imageUrl.map((e) => ProductImage(downloadURL: e)).toList();
    //   }
    // }

    var _productVariantImages = variantImages.firstWhere((element) => element['variantId'] == productVariantId.toString(), orElse: ()=> null );
    if (_productVariantImages != null && _productVariantImages.isNotEmpty) {
      productImages =_productVariantImages['images'];
    }
    return productImages;
  }

  List<ProductImage> getSavedVariantsImages(ProductVariants productVariant) {
    if (productVariant.imageUrl != null) {

        var productImages = productVariant.imageUrl.map((e) => ProductImage(downloadURL: e)).toList();
        return productImages;
    }
    return [];

  }

  setRetrievedImages(List<ProductVariants> productVariants) {
    if (productVariants == null) return;
    for (var productVariant in productVariants) {
      retrievedImages.addAll(getSavedVariantsImages(productVariant));
    }


  }

  setVariantImage(int variantId, List<ProductImage> productImages) {
    Map<String, dynamic> variantMap = new Map();
    variantMap["variantId"] = variantId.toString();
    variantMap["images"] = productImages;
    variantImages.add(variantMap);
  }

  setProductVariantsImages(int productVariantId, ProductVariants productVariants) {
    int index = productVariantViewModel.variants.indexWhere((element) => element.productVariantId == productVariantId);
    productVariantViewModel.variants[index] = productVariants;
  }


}