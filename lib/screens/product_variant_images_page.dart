



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/product_variants.dart';
import 'package:subbonline_storeadmin/viewmodels/product_image_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_images_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_viewmodel.dart';
import 'package:subbonline_storeadmin/widgets/product_images_view.dart';

import '../constants.dart';

class ProductVariantImagesPage extends ConsumerWidget {


  const ProductVariantImagesPage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context, ScopedReader watch ) {
    final model = watch(productVariantImagesViewModelProvider);

    List<Widget> generateVariantImageLayout(List<ProductVariants> variants) {
      if (variants == null) return List.generate(1, (index) => Container());
      return List.generate(variants.length, (index) => VariantImagesWidget(productVariants: variants[index],));
    }

    return model.getVariants() == null ? Center(child: Text("Variants are not setup."),):Container(
      child: SingleChildScrollView(
        child: Column(
          children: generateVariantImageLayout(model.getVariants()),
        ),
      ),
    );
  }
}

class VariantImagesWidget extends ConsumerWidget {

  final ProductVariants productVariants;

  VariantImagesWidget({Key key, this.productVariants}) : super(key: key);


  List<ProductImage>  productImages = [];

  Widget buildColorBox(String color) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, spreadRadius: 3)],
          color: Color(int.parse(color)),
          border: Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)),
    );
  }



  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(productVariantImagesViewModelProvider);

      productImages = model.getSavedVariantsImages(productVariants);

    void _copyImageOnModel(List<ProductImage> productImages) {
      model.setVariantImage(productVariants.productVariantId, productImages);
      this.productImages = productImages;
    }
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text("${productVariants.productVariantId}.", style: kNameTextStyle,),
              ),
              if (productVariants.unitValue != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text("${productVariants.unitValue}", style: kNameTextStyle15,),
                ),
              if (productVariants.size != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text("${productVariants.size}", style: kNameTextStyle15,),
                ),
              if (productVariants.color != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: buildColorBox(productVariants.color),

                ),
            ],
          ),
          ProductImagesView(productVariants.productVariantId, _copyImageOnModel, productImages ),
        ],
      ),

    );
  }
}

