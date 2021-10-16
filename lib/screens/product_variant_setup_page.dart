





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/models/product_variants.dart';
import 'package:subbonline_storeadmin/viewmodels/product_variant_viewmodel.dart';
import 'package:subbonline_storeadmin/widgets/custom_form_input_field.dart';

class ProductVariantSetupPage extends StatefulWidget {
  const ProductVariantSetupPage({Key key}) : super(key: key);

  @override
  _ProductVariantSetupPageState createState() => _ProductVariantSetupPageState();
}

class _ProductVariantSetupPageState extends State<ProductVariantSetupPage> {
  static final _formKey = GlobalKey<FormState>();

  TextEditingController priceController = TextEditingController();
  TextEditingController surchargeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();


  @override
  void initState() {
    final model = context.read(productVariantViewModelProvider.notifier);
    model.variants = model.prepareVariants();
    if (model.variants != null) {
      model.variantsLayout = List.generate(model.variants.length, (index) => buildVariantInputLayout(model, index, model.variants[index]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: ((context, watch, _) {
        final state = watch(productVariantViewModelProvider);
        final model = watch(productVariantViewModelProvider.notifier);
        if (model.variants != null) {
          model.variantsLayout = List.generate(model.variants.length, (index) => buildVariantInputLayout(model, index, model.variants[index]));
        }
        return model.variantsLayout == null ? Center(
          child: Container(
              child: Text("Variants are not applicable based on your selection."),
          ),
        ) :Container(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: model.variantsLayout,
              ),
            ),
          )
        );

    })

    );

  }
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
  Widget buildVariantInputLayout(ProductVariantViewModel model, int index, ProductVariants productVariants) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("${productVariants.productVariantId}."),
          ),
          if (productVariants.unitValue != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(width: 40, child: Text("${productVariants.unitValue}")),
            ),
          if (productVariants.size != null)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(width: 30,child: FittedBox(
              fit: BoxFit.scaleDown,
                child: Text("${productVariants.size}"))),
          ),
          if (productVariants.color != null)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildColorBox(productVariants.color),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
            child: buildPriceInputWidget(model, index),
          ),
          Text("- OR -", style: TextStyle(color: Colors.grey, fontSize: 12),),
          Padding(
              padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
            child: buildSurchargeInputWidget(model,index)
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: buildSQuantityInputWidget(model, index),
          )

        ],

      ),
    );


  }

  Widget buildPriceInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      hintText: "0.0",
      labelText: "Price",
        labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      initialValue:  model.variants[index].price == null ? null : model.variants[index].price.toString(),
      //prefixIcon: Icons.attach_money,
      prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: priceController,
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: 70,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }
  Widget buildSurchargeInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      hintText: "0",
      labelText: "Surcharge",
      labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      initialValue:  model.variants[index].price == null ? null : model.variants[index].price.toString(),
      //prefixIcon: Icons.attach_money,
      prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: surchargeController,
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: 70,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }
  Widget buildSQuantityInputWidget(ProductVariantViewModel model, int index) {
    return CustomInputFormField(
      //hintText: "1",
      labelText: "Qty",
      labelTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      initialValue:  model.variants[index].price == null ? null : model.variants[index].price.toString(),
      //prefixIcon: Icons.attach_money,
      prefixIconConstraints: BoxConstraints.tight(Size(30, 40)),
      textEditingController: quantityController,
      textInputType: TextInputType.number,
      obscureText: false,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.end,
      autoFocus: false,
      enable: true,
      focusNode: null,
      maxLength: 12,
      width: 50,
      height: 50,
      padding: const EdgeInsets.only(bottom: 1, top: 1, left: 1, right: 1),
      //validateFunction: _validatePrice,
      //onSaveFunction: _priceSave,
      //onFieldSubmittedFunction: _node.nextFocus
    );
  }



}
